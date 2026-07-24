import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/cache/cache_manager.dart';
import '../../../data/network/api/chat_api.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../data/network/response/target_user_request.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/pusher_service.dart';

class ChatConversationBloc extends BaseBloc {
  final ChatApi _chatApi = ChatApi(sl.get<Dio>());
  final PusherService _pusherService = PusherService();
  final CacheManager _cacheManager = sl.get<CacheManager>();

  final BehaviorSubject<List<ChatMessage>> _messagesSubject =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> _isLoadingMoreSubject =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isLoadingSubject = BehaviorSubject.seeded(true);
  final BehaviorSubject<Map<String, ShipmentData>> _shipmentsSubject =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<ShipmentData?> _activeShipmentSubject =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> _otherUserTypingSubject =
      BehaviorSubject.seeded(false);

  Stream<List<ChatMessage>> get messagesStream => _messagesSubject.stream;
  Stream<bool> get isLoadingMoreStream => _isLoadingMoreSubject.stream;
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;
  Stream<Map<String, ShipmentData>> get shipmentsStream =>
      _shipmentsSubject.stream;
  Stream<ShipmentData?> get activeShipmentStream =>
      _activeShipmentSubject.stream;
  Stream<bool> get otherUserTypingStream => _otherUserTypingSubject.stream;

  /// Statuses that keep a deal "active" for the pinned bar (§3A.2).
  /// completed/auto_completed stay (review nudge); terminal declined/cancelled/
  /// expired do not.
  static const _pinbarStatuses = {
    'proposal_pending',
    'accepted',
    'picked_up',
    'delivered',
    'disputed',
    'completed',
    'auto_completed',
  };

  String? _conversationId;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  int? _myUserId;
  String? _myUserPublicId;
  final Map<String, _PendingMessage> _pendingMessages = {};
  Timer? _typingStopTimer;
  Timer? _remoteTypingTimeout;
  Timer? _fallbackRefreshTimer;
  DateTime? _lastTypingSentAt;
  bool _typingActive = false;

  Future<void> initChat(String conversationId) async {
    _conversationId = conversationId;
    _myUserId = await _cacheManager.getUserId();
    try {
      final user = await _cacheManager.userDetails.first;
      _myUserPublicId = user?.id?.toString();
    } catch (_) {}

    final token = await _cacheManager.getToken();
    if (token != null) {
      await _pusherService.initialize(token);
      await _pusherService.subscribeToConversation(
        conversationId,
        _onNewMessage,
      );
      await _pusherService.subscribeToConversationTyping(
        conversationId,
        _onTyping,
      );
    }
    _fallbackRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(
        loadMessages(
          showLoading: false,
          emitError: false,
        ),
      );
    });
  }

  void _onNewMessage(Map<String, dynamic> data) {
    if (_isMyUser(data['sender_id'])) return;
    unawaited(
      loadMessages(
        showLoading: false,
        emitError: false,
      ),
    );
  }

  void _onTyping(Map<String, dynamic> data) {
    if (_isMyUser(data['user_id'])) return;

    final typing = _boolValue(data['typing']);
    _remoteTypingTimeout?.cancel();
    if (!_otherUserTypingSubject.isClosed) {
      _otherUserTypingSubject.add(typing);
    }
    if (typing) {
      _remoteTypingTimeout = Timer(const Duration(seconds: 5), () {
        if (!_otherUserTypingSubject.isClosed) {
          _otherUserTypingSubject.add(false);
        }
      });
    }
  }

  void onComposerChanged(String value) {
    if (_conversationId == null) return;
    _typingStopTimer?.cancel();

    if (value.trim().isEmpty) {
      unawaited(stopTyping());
      return;
    }

    final now = DateTime.now();
    final shouldSend = !_typingActive ||
        _lastTypingSentAt == null ||
        now.difference(_lastTypingSentAt!) >= const Duration(seconds: 2);
    if (shouldSend) {
      _typingActive = true;
      _lastTypingSentAt = now;
      unawaited(_sendTyping(true));
    }

    _typingStopTimer = Timer(
      const Duration(seconds: 3),
      () => unawaited(stopTyping()),
    );
  }

  Future<void> stopTyping() async {
    _typingStopTimer?.cancel();
    _typingStopTimer = null;
    if (!_typingActive) return;
    _typingActive = false;
    _lastTypingSentAt = null;
    await _sendTyping(false);
  }

  Future<void> _sendTyping(bool typing) async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    try {
      await _chatApi.sendTyping(conversationId, typing: typing);
    } catch (_) {
      // Typing is ephemeral and must never block message sending.
    }
  }

  Future<void> loadMessages({
    bool showLoading = true,
    bool emitError = true,
  }) async {
    if (_conversationId == null) return;

    _currentPage = 1;
    if (showLoading && !_isLoadingSubject.isClosed) {
      _isLoadingSubject.add(true);
    }

    try {
      final response =
          await _chatApi.getMessages(_conversationId!, 50, _currentPage);
      if (!_messagesSubject.isClosed) {
        final localMessages = _messagesSubject.value
            .where((message) => message.id.startsWith('local-'));
        final messages = _newestFirst([
          ...response.data,
          ...localMessages,
        ]);
        _messagesSubject.add(messages);
        unawaited(_loadShipmentStates(messages));
      }
      _lastPage = response.meta.lastPage;
      try {
        await _chatApi.markConversationRead(_conversationId!);
      } catch (_) {
        // GET messages already marks the conversation as read.
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (emitError && !_messagesSubject.isClosed) {
        _messagesSubject.addError(e);
      }
    } finally {
      if (showLoading && !_isLoadingSubject.isClosed) {
        _isLoadingSubject.add(false);
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore ||
        _currentPage >= _lastPage ||
        _conversationId == null) {
      return;
    }

    _isLoadingMore = true;
    if (!_isLoadingMoreSubject.isClosed) {
      _isLoadingMoreSubject.add(true);
    }

    try {
      _currentPage++;
      final response =
          await _chatApi.getMessages(_conversationId!, 50, _currentPage);

      if (!_messagesSubject.isClosed) {
        final currentMessages = _messagesSubject.value;
        final messages = _newestFirst([
          ...currentMessages,
          ...response.data,
        ]);
        _messagesSubject.add(messages);
        unawaited(_loadShipmentStates(messages));
      }
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading more: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      if (!_isLoadingMoreSubject.isClosed) {
        _isLoadingMoreSubject.add(false);
      }
    }
  }

  Future<void> sendMessage(String? body, File? file) async {
    if (_conversationId == null) return;
    final text = body?.trim() ?? '';
    if (text.isEmpty && file == null) return;
    unawaited(stopTyping());

    final futures = <Future<void>>[];
    if (file != null) {
      futures.add(_queueImage(file));
    }
    if (text.isNotEmpty) {
      futures.add(_queueText(text));
    }
    await Future.wait(futures);
  }

  Future<void> _queueText(String body) {
    final pending = _PendingMessage(
      localId: _localId(),
      body: body,
    );
    return _sendPending(pending);
  }

  Future<void> _queueImage(File file) {
    final pending = _PendingMessage(
      localId: _localId(),
      image: file,
    );
    return _sendPending(pending);
  }

  Future<void> _sendPending(_PendingMessage pending) async {
    _pendingMessages[pending.localId] = pending;
    _upsertMessage(pending.optimisticMessage());

    try {
      final response = pending.image == null
          ? await _chatApi.sendTextMessage(
              _conversationId!,
              {'body': pending.body},
            )
          : await _chatApi.sendMessageWithFile(
              _conversationId!,
              pending.image!,
            );
      _pendingMessages.remove(pending.localId);
      _replaceMessage(pending.localId, response.data);
    } catch (_) {
      _replaceMessage(
        pending.localId,
        pending.optimisticMessage(
          status: ChatMessageDeliveryStatus.failed,
        ),
      );
    }
  }

  Future<void> retryMessage(String localId) async {
    final pending = _pendingMessages[localId];
    if (pending == null) return;
    _replaceMessage(
      localId,
      pending.optimisticMessage(),
    );
    await _sendPending(pending);
  }

  Future<void> editMessage(String messageId, String body) async {
    final response = await _chatApi.editMessage(messageId, body.trim());
    _replaceMessage(messageId, response.data);
  }

  Future<void> deleteMessage(String messageId) async {
    await _chatApi.deleteMessage(messageId);
    if (_messagesSubject.isClosed) return;
    _messagesSubject.add(
      _messagesSubject.value
          .where((message) => message.id != messageId)
          .toList(),
    );
  }

  Future<void> setPinned(bool value) async {
    if (_conversationId == null) return;
    await _chatApi.updateConversation(
      _conversationId!,
      {'is_pinned': value},
    );
  }

  Future<void> setArchived(bool value) async {
    if (_conversationId == null) return;
    await _chatApi.updateConversation(
      _conversationId!,
      {'is_archived': value},
    );
  }

  Future<void> setUserBlocked(Object userId, bool value) async {
    if (value) {
      await _chatApi.blockUser({'user_id': userId});
    } else {
      await _chatApi.unblockUser({'user_id': userId});
    }
  }

  Future<void> deleteConversation() async {
    if (_conversationId == null) return;
    await _chatApi.deleteConversation(_conversationId!);
  }

  Future<String?> runShipmentAction(
    String shipmentId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    final message =
        await _chatApi.shipmentAction(shipmentId, action, body: body);
    await loadMessages();
    return message;
  }

  Future<String?> submitShipmentReview(
    String shipmentId, {
    required int rating,
    String? comment,
  }) {
    return _chatApi.submitShipmentReview(
      shipmentId,
      rating: rating,
      comment: comment,
    );
  }

  Future<bool> sendReviews(int id) async {
    if (_conversationId == null) return false;
    try {
      await run(_chatApi.sendReviews(TargetUserRequest(targetUserId: id)));
      // Если дошли сюда без ошибки - значит успешно
      return true;
    } catch (e) {
      print('Error sending reviews: $e');
      return false;
    }
  }

  bool isMyMessage(ChatMessage message) {
    return message.isMine || _isMyUser(message.user?.apiId);
  }

  bool _isMyUser(dynamic value) {
    final id = value?.toString();
    if (id == null || id.isEmpty) return false;
    return id == _myUserId?.toString() || id == _myUserPublicId;
  }

  void _upsertMessage(ChatMessage message) {
    if (_messagesSubject.isClosed) return;
    final messages = [
      message,
      ..._messagesSubject.value.where((item) => item.id != message.id),
    ];
    _messagesSubject.add(_newestFirst(messages));
  }

  void _replaceMessage(String id, ChatMessage replacement) {
    if (_messagesSubject.isClosed) return;
    final messages = _messagesSubject.value
        .map((message) => message.id == id ? replacement : message)
        .toList();
    _messagesSubject.add(_newestFirst(messages));
  }

  List<ChatMessage> _newestFirst(List<ChatMessage> source) {
    final byId = <String, ChatMessage>{};
    for (final message in source) {
      byId[message.id] = message;
    }
    final messages = byId.values.toList();
    messages.sort(
      (a, b) => b.createdAtDateTime.compareTo(a.createdAtDateTime),
    );
    return messages;
  }

  Future<void> _loadShipmentStates(List<ChatMessage> messages) async {
    final ids = messages
        .map((message) => message.card?.shipmentId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty || _shipmentsSubject.isClosed) return;

    final states = Map<String, ShipmentData>.from(_shipmentsSubject.value);
    await Future.wait(
      ids.map((id) async {
        try {
          final response = await _chatApi.getShipment(id);
          if (response.data != null) states[id] = response.data!;
        } catch (_) {}
      }),
    );
    if (!_shipmentsSubject.isClosed) {
      _shipmentsSubject.add(states);
    }
    _recomputeActiveShipment(messages, states);
  }

  /// The pinned bar shows the deal from the newest live system card (§3A.2).
  void _recomputeActiveShipment(
    List<ChatMessage> messages,
    Map<String, ShipmentData> states,
  ) {
    if (_activeShipmentSubject.isClosed) return;
    ShipmentData? active;
    for (final message in messages) {
      final id = message.card?.shipmentId;
      if (id == null || id.isEmpty) continue;
      final state = states[id];
      if (state != null && _pinbarStatuses.contains(state.status)) {
        active = state;
        break;
      }
    }
    _activeShipmentSubject.add(active);
  }

  String _localId() =>
      'local-${DateTime.now().microsecondsSinceEpoch}-${_pendingMessages.length}';

  Future<void> reconnectRealtime() async {
    final token = await _cacheManager.getToken();
    if (token == null || _conversationId == null) return;
    await _pusherService.initialize(token);
    await _pusherService.subscribeToConversation(
      _conversationId!,
      _onNewMessage,
    );
    await _pusherService.subscribeToConversationTyping(
      _conversationId!,
      _onTyping,
    );
    await loadMessages();
  }

  @override
  void dispose() {
    _typingStopTimer?.cancel();
    _remoteTypingTimeout?.cancel();
    _fallbackRefreshTimer?.cancel();
    if (_typingActive) {
      _typingActive = false;
      unawaited(_sendTyping(false));
    }
    if (_conversationId != null) {
      unawaited(
        _pusherService.unsubscribeFromConversation(
          _conversationId!,
          _onNewMessage,
        ),
      );
      unawaited(
        _pusherService.unsubscribeFromConversationTyping(
          _conversationId!,
          _onTyping,
        ),
      );
    }
    _messagesSubject.close();
    _isLoadingMoreSubject.close();
    _isLoadingSubject.close();
    _shipmentsSubject.close();
    _activeShipmentSubject.close();
    _otherUserTypingSubject.close();
    super.dispose();
  }
}

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}

class _PendingMessage {
  final String localId;
  final String? body;
  final File? image;

  const _PendingMessage({
    required this.localId,
    this.body,
    this.image,
  });

  ChatMessage optimisticMessage({
    ChatMessageDeliveryStatus status = ChatMessageDeliveryStatus.sending,
  }) {
    return ChatMessage(
      id: localId,
      type: image == null ? 'text' : 'image',
      body: body,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      isMine: true,
      deliveryStatus: status,
      localImagePath: image?.path,
    );
  }
}
