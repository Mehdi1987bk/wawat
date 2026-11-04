import 'dart:async';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/cache/cache_manager.dart';
import '../../../data/network/api/chat_api.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/notification_socket_service.dart';
import '../../../services/pusher_service.dart';

class ChatListBloc extends BaseBloc {
  ChatListBloc({
    ChatApi? chatApi,
    PusherService? pusher,
    CacheManager? cacheManager,
  })  : _chatApi = chatApi ?? ChatApi(sl.get<Dio>()),
        _pusherService = pusher ?? PusherService(),
        _cacheManager = cacheManager ?? sl.get<CacheManager>();

  final ChatApi _chatApi;
  final PusherService _pusherService;
  final CacheManager _cacheManager;
  final NotificationSocketService _notifications =
      NotificationSocketService.instance;

  final BehaviorSubject<List<Conversation>> _conversationsSubject =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> _isLoadingMoreSubject =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isLoadingSubject = BehaviorSubject.seeded(true);
  final PublishSubject<Object> _actionErrorsSubject = PublishSubject<Object>();

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsSubject.stream;
  Stream<bool> get isLoadingMoreStream => _isLoadingMoreSubject.stream;
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  Stream<Object> get actionErrorsStream => _actionErrorsSubject.stream;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  bool _showArchived = false;
  bool _isInitialized = false;
  bool _isFallbackRefreshing = false;
  bool _refreshWanted = false;
  int? _myUserId;
  Timer? _realtimeRefreshTimer;
  Timer? _fallbackRefreshTimer;
  int _fallbackTick = 0;
  final List<StreamSubscription<void>> _liveSubscriptions = [];

  bool _staleUnderChat = false;

  bool get _coveredByChat => _notifications.activeConversationId != null;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _myUserId = await _cacheManager.getUserId();
    final token = await _cacheManager.getToken();
    if (token != null) {
      await _pusherService.initialize(token);
      if (_myUserId != null) {
        await _pusherService.subscribeToUserChannel(
          _myUserId!,
          _onConversationEvent,
        );
      }
    }
    _liveSubscriptions
      ..add(_notifications.onChatActivity.listen((_) => _onLiveEvent()))
      ..add(_notifications.onNotificationsChanged.listen((_) => _onLiveEvent()));
    _notifications.activeConversation.addListener(_onActiveChatChanged);
    _fallbackRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fallbackTick++;
      if (!_pusherService.isConnected || _fallbackTick % 3 == 0) {
        unawaited(refreshIfVisible());
      }
    });
  }

  void _onConversationEvent(Map<String, dynamic> data) => _onLiveEvent();

  void _onLiveEvent() {
    if (_coveredByChat) {
      _staleUnderChat = true;
      return;
    }
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(refreshIfVisible());
    });
  }

  void _onActiveChatChanged() {
    if (_coveredByChat || !_staleUnderChat) return;
    unawaited(refreshIfVisible());
  }

  Future<void> refreshIfVisible() async {
    if (_coveredByChat) {
      _staleUnderChat = true;
      return;
    }
    if (_isFallbackRefreshing) {
      _refreshWanted = true;
      return;
    }
    _isFallbackRefreshing = true;
    try {
      do {
        _refreshWanted = false;
        await refreshCurrent();
      } while (_refreshWanted &&
          !_coveredByChat &&
          !_conversationsSubject.isClosed);
    } finally {
      _isFallbackRefreshing = false;
    }
  }

  Future<void> loadConversations() async {
    _showArchived = false;
    _currentPage = 1;
    _isLoadingSubject.add(true);

    try {
      final response = await _chatApi.getConversations(20, _currentPage);
      _conversationsSubject.add(response.data);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading conversations: $e');
      _conversationsSubject.addError(e);
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<void> blockUser(Object userId) async {
    try {
      await _chatApi.blockUser({'user_id': userId});
      await loadConversations();
    } catch (e) {
      _actionErrorsSubject.add(e);
    }
  }

  Future<void> unblockUser(Object userId) async {
    try {
      await _chatApi.unblockUser({'user_id': userId});
      await loadConversations();
    } catch (e) {
      _actionErrorsSubject.add(e);
    }
  }

  Future<void> loadArchivedConversations() async {
    _showArchived = true;
    _currentPage = 1;
    _isLoadingSubject.add(true);

    try {
      final response =
          await _chatApi.getArchivedConversations(20, _currentPage);
      _conversationsSubject.add(response.data);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading archived conversations: $e');
      _conversationsSubject.addError(e);
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    _isLoadingMore = true;
    _isLoadingMoreSubject.add(true);

    try {
      _currentPage++;
      final response = _showArchived
          ? await _chatApi.getArchivedConversations(20, _currentPage)
          : await _chatApi.getConversations(20, _currentPage);

      final currentConversations = _conversationsSubject.value;
      final conversations = [...currentConversations, ...response.data];
      _conversationsSubject.add(conversations);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading more: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      _isLoadingMoreSubject.add(false);
    }
  }

  Future<void> togglePin(String conversationId) async {
    try {
      final currentConversations = _conversationsSubject.value;
      final conversation =
          currentConversations.firstWhere((c) => c.id == conversationId);

      if (conversation.isPinned) {
        await _chatApi.unpinConversation(conversationId);
      } else {
        await _chatApi.pinConversation(conversationId);
      }

      await loadConversations();
    } catch (e) {
      print('Error toggling pin: $e');
    }
  }

  Future<void> toggleArchive(String conversationId) async {
    try {
      final currentConversations = _conversationsSubject.value;
      final conversation =
          currentConversations.firstWhere((c) => c.id == conversationId);

      if (conversation.isArchived) {
        await _chatApi.unarchiveConversation(conversationId);
      } else {
        await _chatApi.archiveConversation(conversationId);
      }

      _conversationsSubject.add(
        currentConversations.where((c) => c.id != conversationId).toList(),
      );
    } catch (e) {
      print('Error toggling archive: $e');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _chatApi.deleteConversation(conversationId);

      final currentConversations = _conversationsSubject.value;
      _conversationsSubject.add(
        currentConversations.where((c) => c.id != conversationId).toList(),
      );
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  Future<void> refreshCurrent() async {
    _staleUnderChat = false;
    try {
      final response = _showArchived
          ? await _chatApi.getArchivedConversations(20, 1)
          : await _chatApi.getConversations(20, 1);
      _lastPage = response.meta.lastPage;

      final fresh = response.data;
      final existing = _conversationsSubject.value;
      if (existing.isEmpty) {
        _currentPage = 1;
        _conversationsSubject.add(fresh);
        return;
      }

      final freshById = {for (final c in fresh) c.id: c};
      final seen = <String>{};
      final merged = <Conversation>[];
      for (final c in existing) {
        merged.add(freshById[c.id] ?? c);
        seen.add(c.id);
      }
      for (final c in fresh) {
        if (!seen.contains(c.id)) merged.add(c);
      }

      _conversationsSubject.add(merged);
    } catch (e) {
      print('Error refreshing conversations: $e');
    }
  }

  Future<void> reconnectRealtime() async {
    final token = await _cacheManager.getToken();
    if (token == null) return;
    await _pusherService.initialize(token);
    _myUserId ??= await _cacheManager.getUserId();
    if (_myUserId != null) {
      await _pusherService.subscribeToUserChannel(
        _myUserId!,
        _onConversationEvent,
      );
    }
  }

  @override
  void dispose() {
    _realtimeRefreshTimer?.cancel();
    _fallbackRefreshTimer?.cancel();
    _notifications.activeConversation.removeListener(_onActiveChatChanged);
    for (final subscription in _liveSubscriptions) {
      unawaited(subscription.cancel());
    }
    if (_myUserId != null) {
      unawaited(
        _pusherService.unsubscribeFromUserChannel(
          _myUserId!,
          _onConversationEvent,
        ),
      );
    }
    _conversationsSubject.close();
    _isLoadingMoreSubject.close();
    _isLoadingSubject.close();
    _actionErrorsSubject.close();
    super.dispose();
  }
}
