import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/cache/cache_manager.dart';
import '../../../data/network/api/chat_api.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../data/network/response/review_submit_result.dart';
import '../../../data/network/response/target_user_request.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/network_failure.dart';
import 'chat_realtime.dart';
import 'typing_signal.dart';

class ChatConversationBloc extends BaseBloc {
  ChatConversationBloc({
    ChatApi? chatApi,
    ChatRealtime? realtime,
    CacheManager? cacheManager,
    DateTime Function()? clock,
  })  : _chatApi = chatApi ?? ChatApi(sl.get<Dio>()),
        _realtime = realtime ??
            (sl.isRegistered<ChatRealtime>()
                ? sl.get<ChatRealtime>()
                : PusherChatRealtime()),
        _cacheManager = cacheManager ?? sl.get<CacheManager>(),
        _now = clock ?? DateTime.now;

  final ChatApi _chatApi;
  final ChatRealtime _realtime;
  final CacheManager _cacheManager;
  final DateTime Function() _now;

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

  final BehaviorSubject<Conversation?> _conversationSubject =
      BehaviorSubject.seeded(null);
  Stream<Conversation?> get conversationHeaderStream =>
      _conversationSubject.stream;

  Stream<List<ChatMessage>> get messagesStream => _messagesSubject.stream;
  Stream<bool> get isLoadingMoreStream => _isLoadingMoreSubject.stream;
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;
  Stream<Map<String, ShipmentData>> get shipmentsStream =>
      _shipmentsSubject.stream;
  Stream<ShipmentData?> get activeShipmentStream =>
      _activeShipmentSubject.stream;
  Stream<bool> get otherUserTypingStream => _otherUserTypingSubject.stream;

  final PublishSubject<Object> _sendErrorsSubject = PublishSubject<Object>();
  Stream<Object> get sendErrorsStream => _sendErrorsSubject.stream;

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

  int _loadSeq = 0;
  int _appliedLoadSeq = 0;
  int _minValidLoadSeq = 0;

  final Map<String, String> _wantedShipmentSignatures = {};
  final Map<String, String> _loadedShipmentSignatures = {};
  final Map<String, String> _loadingShipmentSignatures = {};
  int? _myUserId;
  String? _myUserPublicId;

  DateTime? _peerLastReadAt;
  final Map<String, _PendingMessage> _pendingMessages = {};
  Timer? _remoteTypingTimeout;
  Timer? _fallbackRefreshTimer;
  int _fallbackTick = 0;
  bool _disposed = false;

  late final ChatRealtimeHandlers _handlers = ChatRealtimeHandlers(
    onMessage: _onNewMessage,
    onTyping: _onTyping,
    onRead: _onMessageRead,
    onDeleted: _onMessageDeleted,
  );

  late final TypingSignal _typing =
      TypingSignal(send: _sendTyping, clock: _now);

  bool _refreshing = false;
  bool _refreshWanted = false;

  int _sendsInFlight = 0;

  final List<String?> _undecidedEvents = [];

  final List<DateTime> _owedEchoes = [];
  static const _echoWindow = Duration(seconds: 10);

  bool _readSent = false;
  String? _readFor;

  DateTime? _optionalPausedUntil;
  static const _defaultRateLimitPause = Duration(seconds: 30);

  DateTime? _sendBlockedUntil;
  Object? _sendBlockAnswer;

  static const _longestSendWait = Duration(seconds: 10);

  Future<void> initChat(String conversationId) async {
    _conversationId = conversationId;
    _myUserId = await _cacheManager.getUserId();
    try {
      final user = await _cacheManager.userDetails.first;
      _myUserPublicId = user?.id?.toString();
    } catch (_) {}

    final token = await _cacheManager.getToken();
    if (token != null && !_disposed) {
      await _realtime.join(token, conversationId, _handlers);
    }
    if (_disposed) return;
    _fallbackRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _fallbackTick++;
      if (_realtime.isConnected && _fallbackTick % 3 != 0) return;
      unawaited(_quietRefresh());
    });
  }

  void _onNewMessage(Map<String, dynamic> data) {
    if (!_isSystemCard(data)) {
      if (_isOwnEcho(data)) return;
      _clearPeerTyping();
    }
    unawaited(_quietRefresh());
  }

  Future<void> _quietRefresh() async {
    if (_refreshing) {
      _refreshWanted = true;
      return;
    }
    _refreshing = true;
    try {
      do {
        _refreshWanted = false;
        await loadMessages(showLoading: false, emitError: false);
      } while (_refreshWanted && !_disposed);
    } finally {
      _refreshing = false;
    }
  }

  bool _isOwnEcho(Map<String, dynamic> data) {
    final id = _eventMessageId(data);
    if (_eventAuthorIsMe(data) || (id != null && _hasMessage(id))) {
      if (_owedEchoes.isNotEmpty) _owedEchoes.removeAt(0);
      return true;
    }
    if (_sendsInFlight > 0) {
      _undecidedEvents.add(id);
      return true;
    }
    if (id != null) return false;
    final now = _now();
    _owedEchoes.removeWhere((deadline) => !deadline.isAfter(now));
    if (_owedEchoes.isEmpty) return false;
    _owedEchoes.removeAt(0);
    return true;
  }

  void _sendFinished(String? savedId) {
    _sendsInFlight--;
    if (savedId != null) {
      final echoed = _undecidedEvents.remove(savedId) ||
          _undecidedEvents.remove(null);
      if (!echoed) _owedEchoes.add(_now().add(_echoWindow));
    }
    if (_sendsInFlight > 0 || _undecidedEvents.isEmpty) return;
    final foreign =
        _undecidedEvents.any((id) => id == null || !_hasMessage(id));
    _undecidedEvents.clear();
    if (foreign) {
      _clearPeerTyping();
      unawaited(_quietRefresh());
    }
  }

  bool _hasMessage(String id) =>
      !_messagesSubject.isClosed &&
      _messagesSubject.value.any((message) => message.id == id);

  static String? _eventMessageId(Map<String, dynamic> data) {
    final nested = data['message'];
    final candidates = [
      if (nested is Map) nested['id'],
      data['message_id'],
      data['messageId'],
      data['id'],
    ];
    for (final candidate in candidates) {
      final id = candidate?.toString() ?? '';
      if (id.isNotEmpty) return id;
    }
    return null;
  }

  bool _eventAuthorIsMe(Map<String, dynamic> data) {
    final nested = data['message'];
    for (final source in [data, if (nested is Map) nested]) {
      for (final key in const ['sender_id', 'senderId', 'user_id', 'userId']) {
        if (_isMyUser(source[key])) return true;
      }
      for (final key in const ['sender', 'user']) {
        final author = source[key];
        if (author is Map &&
            (_isMyUser(author['id']) || _isMyUser(author['public_id']))) {
          return true;
        }
      }
    }
    return false;
  }

  void _clearPeerTyping() {
    _remoteTypingTimeout?.cancel();
    if (!_otherUserTypingSubject.isClosed && _otherUserTypingSubject.value) {
      _otherUserTypingSubject.add(false);
    }
  }

  static bool _isSystemCard(Map<String, dynamic> data) {
    final nested = data['message'];
    for (final source in [data, if (nested is Map) nested]) {
      if (source['type'] == 'system_card' ||
          source['messageType'] == 'system_card' ||
          source['message_type'] == 'system_card' ||
          source['card'] is Map) {
        return true;
      }
    }
    return false;
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

  void _onMessageRead(Map<String, dynamic> data) {
    if (_isMyUser(data['user_id'])) return;
    final raw = data['last_read_at']?.toString();
    final cursor = raw == null ? null : DateTime.tryParse(raw);
    if (!_advancePeerLastReadAt(cursor)) return;
    if (_messagesSubject.isClosed) return;
    _messagesSubject.add(_newestFirst(_messagesSubject.value));
  }

  bool _advancePeerLastReadAt(DateTime? value) {
    if (value == null) return false;
    final current = _peerLastReadAt;
    if (current != null && !value.isAfter(current)) return false;
    _peerLastReadAt = value;
    return true;
  }

  List<ChatMessage> _applyPeerRead(List<ChatMessage> messages) {
    final cursor = _peerLastReadAt;
    if (cursor == null) return messages;
    return messages.map((message) {
      if (!isMyMessage(message) ||
          message.isRead == true ||
          message.createdAtDateTime.isAfter(cursor)) {
        return message;
      }
      return message.copyWith(isRead: true);
    }).toList();
  }

  void onComposerChanged(String value) {
    if (_conversationId == null) return;
    _typing.onInput(value);
  }

  Future<void> stopTyping() async => _typing.stop();

  Future<void> _sendTyping(bool typing) async {
    final conversationId = _conversationId;
    if (conversationId == null || _optionalPaused) return;
    try {
      await _chatApi.sendTyping(conversationId, typing: typing);
    } catch (e) {
      _noteRateLimit(e);
    }
  }

  bool get _optionalPaused {
    final until = _optionalPausedUntil;
    return until != null && _now().isBefore(until);
  }

  void _noteRateLimit(Object error) {
    if (error is! DioException || error.response?.statusCode != 429) return;
    _optionalPausedUntil =
        _now().add(_retryAfterOf(error) ?? _defaultRateLimitPause);
  }

  Duration? _retryAfterOf(Object error) {
    if (error is! DioException || error.response?.statusCode != 429) {
      return null;
    }
    final response = error.response!;
    final fromHeader = NetworkFailure.retryAfter(
      response.headers.value('retry-after'),
      _now(),
    );
    if (fromHeader != null) return fromHeader;
    final data = response.data;
    final raw = data is Map ? data['retry_after'] : null;
    final seconds = raw is num ? raw.ceil() : int.tryParse('${raw ?? ''}');
    if (seconds == null || seconds <= 0) return null;
    final pause = Duration(seconds: seconds);
    return pause > NetworkFailure.maxRetryAfter
        ? NetworkFailure.maxRetryAfter
        : pause;
  }

  Future<void> loadMessages({
    bool showLoading = true,
    bool emitError = true,
  }) async {
    if (_conversationId == null || _disposed) return;

    final seq = ++_loadSeq;
    _currentPage = 1;
    if (showLoading && !_isLoadingSubject.isClosed) {
      _isLoadingSubject.add(true);
    }

    try {
      final response =
          await _chatApi.getMessages(_conversationId!, 50, _currentPage);
      if (seq < _appliedLoadSeq || seq < _minValidLoadSeq) return;
      _appliedLoadSeq = seq;
      _advancePeerLastReadAt(response.meta.peerLastReadAt);
      if (response.meta.conversation != null &&
          !_conversationSubject.isClosed) {
        _conversationSubject.add(response.meta.conversation);
      }
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
      await _markReadIfNeeded();
    } catch (e) {
      print('Error loading messages: $e');
      final isStale = seq < _appliedLoadSeq || seq < _minValidLoadSeq;
      if (emitError && !isStale && !_messagesSubject.isClosed) {
        _messagesSubject.addError(e);
      }
    } finally {
      if (showLoading && !_isLoadingSubject.isClosed) {
        _isLoadingSubject.add(false);
      }
    }
  }

  Future<void> _markReadIfNeeded() async {
    final conversationId = _conversationId;
    if (conversationId == null || _messagesSubject.isClosed) return;
    String? newestIncoming;
    for (final message in _messagesSubject.value) {
      if (message.id.startsWith('local-') || isMyMessage(message)) continue;
      newestIncoming = message.id;
      break;
    }
    if ((_readSent && _readFor == newestIncoming) || _optionalPaused) return;

    final wasSent = _readSent;
    final wasFor = _readFor;
    _readSent = true;
    _readFor = newestIncoming;
    try {
      await _chatApi.markConversationRead(conversationId);
    } catch (e) {
      _readSent = wasSent;
      _readFor = wasFor;
      _noteRateLimit(e);
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
      _advancePeerLastReadAt(response.meta.peerLastReadAt);

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

  Future<void> sendMessage(String? body, File? file,
      {ChatReplyRef? replyTo}) async {
    if (_conversationId == null) return;
    final text = body?.trim() ?? '';
    if (text.isEmpty && file == null) return;
    _typing.onMessageSent();

    if (file != null) {
      await _queueImage(file,
          caption: text.isEmpty ? null : text, replyTo: replyTo);
    } else if (text.isNotEmpty) {
      await _queueText(text, replyTo: replyTo);
    }
  }

  Future<void> _queueText(String body, {ChatReplyRef? replyTo}) {
    final pending = _PendingMessage(
      localId: _localId(),
      body: body,
      replyTo: replyTo,
    );
    return _sendPending(pending);
  }

  Future<void> _queueImage(File file,
      {String? caption, ChatReplyRef? replyTo}) {
    final pending = _PendingMessage(
      localId: _localId(),
      image: file,
      body: caption,
      replyTo: replyTo,
    );
    return _sendPending(pending);
  }

  Future<void> _sendPending(_PendingMessage pending) async {
    _pendingMessages[pending.localId] = pending;
    _upsertMessage(pending.optimisticMessage());

    final refusal = await _waitForSendLimit();
    if (_disposed) return;
    if (refusal != null) {
      _failPending(pending, refusal);
      return;
    }

    _sendsInFlight++;
    String? savedId;
    try {
      final response = pending.image == null
          ? await _chatApi.sendTextMessage(
              _conversationId!,
              {
                'body': pending.body,
                if (pending.replyTo != null)
                  'reply_to_message_id': pending.replyTo!.messageId,
              },
            )
          : await _chatApi.sendMessageWithFile(
              _conversationId!,
              pending.image!,
              caption: pending.body,
            );
      _pendingMessages.remove(pending.localId);
      final saved = response.data;
      if (saved.id.isNotEmpty) savedId = saved.id;
      _replaceMessage(
        pending.localId,
        pending.replyTo != null && saved.replyTo == null
            ? saved.copyWith(replyTo: pending.replyTo)
            : saved,
      );
    } catch (e) {
      _rememberSendLimit(e);
      _failPending(pending, e);
    } finally {
      _sendFinished(savedId);
    }
  }

  void _failPending(_PendingMessage pending, Object error) {
    _replaceMessage(
      pending.localId,
      pending.optimisticMessage(
        status: ChatMessageDeliveryStatus.failed,
      ),
    );
    if (!_sendErrorsSubject.isClosed) _sendErrorsSubject.add(error);
  }

  void _rememberSendLimit(Object error) {
    final pause = _retryAfterOf(error);
    if (pause == null) return;
    _sendBlockedUntil = _now().add(pause);
    _sendBlockAnswer = error;
  }

  Future<Object?> _waitForSendLimit() async {
    final until = _sendBlockedUntil;
    if (until == null) return null;
    final wait = until.difference(_now());
    if (wait <= Duration.zero) {
      _sendBlockedUntil = null;
      _sendBlockAnswer = null;
      return null;
    }
    if (wait > _longestSendWait) return _sendBlockAnswer;
    await Future<void>.delayed(wait);
    return null;
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
    _markMessageDeleted(messageId);
  }

  void _onMessageDeleted(Map<String, dynamic> data) {
    final id = data['id']?.toString();
    if (id != null && id.isNotEmpty) _markMessageDeleted(id);
  }

  void _markMessageDeleted(String messageId) {
    if (_messagesSubject.isClosed) return;
    final current = _messagesSubject.value;
    if (!current.any((message) => message.id == messageId)) return;
    _messagesSubject.add(
      current
          .map((message) =>
              message.id == messageId ? message.asDeleted() : message)
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
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final message =
        await _chatApi.shipmentAction(shipmentId, endpoint, body: body);
    _minValidLoadSeq = _loadSeq + 1;
    _loadedShipmentSignatures.remove(shipmentId);
    _dropDealActions(shipmentId);
    unawaited(loadMessages(showLoading: false, emitError: false));
    return message;
  }

  void _dropDealActions(String shipmentId) {
    if (_messagesSubject.isClosed) return;
    var changed = false;
    final messages = _messagesSubject.value.map((message) {
      final card = message.card;
      if (card == null ||
          card.shipmentId != shipmentId ||
          card.actions.isEmpty) {
        return message;
      }
      changed = true;
      return message.copyWith(card: card.withoutActions());
    }).toList();
    if (changed) _messagesSubject.add(messages);
  }

  Future<ReviewSubmitResult> submitShipmentReview(
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
    return _applyPeerRead(messages);
  }

  Future<void> _loadShipmentStates(List<ChatMessage> messages) async {
    final signatures = <String, String>{};
    for (final message in messages) {
      final card = message.card;
      final id = card?.shipmentId;
      if (card == null || id == null || id.isEmpty) continue;
      signatures.putIfAbsent(
          id, () => '${message.id}|${card.shipmentStatus ?? ''}');
    }
    if (signatures.isEmpty || _shipmentsSubject.isClosed) return;
    _wantedShipmentSignatures.addAll(signatures);

    final stale = [
      for (final entry in signatures.entries)
        if (_loadedShipmentSignatures[entry.key] != entry.value &&
            _loadingShipmentSignatures[entry.key] != entry.value)
          entry.key,
    ];
    final fetched = <String, ShipmentData>{};
    await Future.wait(
      stale.map((id) async {
        final signature = signatures[id]!;
        _loadingShipmentSignatures[id] = signature;
        try {
          final response = await _chatApi.getShipment(id);
          final data = response.data;
          if (data == null || _wantedShipmentSignatures[id] != signature) {
            return;
          }
          fetched[id] = data;
          _loadedShipmentSignatures[id] = signature;
        } catch (_) {
        } finally {
          if (_loadingShipmentSignatures[id] == signature) {
            _loadingShipmentSignatures.remove(id);
          }
        }
      }),
    );
    if (_shipmentsSubject.isClosed) return;
    if (fetched.isNotEmpty) {
      _shipmentsSubject.add({..._shipmentsSubject.value, ...fetched});
    }
    _recomputeActiveShipment(_messagesSubject.value, _shipmentsSubject.value);
  }

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
    await _realtime.join(token, _conversationId!, _handlers);
    await loadMessages();
  }

  @override
  void dispose() {
    _disposed = true;
    _typing.dispose();
    _remoteTypingTimeout?.cancel();
    _fallbackRefreshTimer?.cancel();
    if (_conversationId != null) {
      unawaited(_realtime.leave(_conversationId!, _handlers));
    }
    _messagesSubject.close();
    _isLoadingMoreSubject.close();
    _isLoadingSubject.close();
    _shipmentsSubject.close();
    _activeShipmentSubject.close();
    _otherUserTypingSubject.close();
    _conversationSubject.close();
    _sendErrorsSubject.close();
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
  final ChatReplyRef? replyTo;

  const _PendingMessage({
    required this.localId,
    this.body,
    this.image,
    this.replyTo,
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
      replyTo: replyTo,
    );
  }
}
