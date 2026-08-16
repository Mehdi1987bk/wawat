import 'dart:async';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/cache/cache_manager.dart';
import '../../../data/network/api/chat_api.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/pusher_service.dart';
import '../../home/tabs/profile_tab/unread_chat_bloc.dart';

class ChatListBloc extends BaseBloc {
  final ChatApi _chatApi = ChatApi(sl.get<Dio>());
  final PusherService _pusherService = PusherService();
  final CacheManager _cacheManager = sl.get<CacheManager>();

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

  /// Block/unblock failures (e.g. 422 "can't block yourself", missing id).
  /// Surfaced so the list screen can show them instead of failing silently.
  Stream<Object> get actionErrorsStream => _actionErrorsSubject.stream;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  bool _showArchived = false;
  bool _isInitialized = false;
  bool _isFallbackRefreshing = false;
  int? _myUserId;
  final Set<String> _subscribedConversationIds = {};
  Timer? _realtimeRefreshTimer;
  Timer? _fallbackRefreshTimer;

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
    _fallbackRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(_fallbackRefresh());
    });
  }

  void _onConversationEvent(Map<String, dynamic> data) {
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(_fallbackRefresh());
    });
  }

  Future<void> _fallbackRefresh() async {
    if (_isFallbackRefreshing) return;
    _isFallbackRefreshing = true;
    try {
      await refreshCurrent();
      await sl.get<UnreadChatBloc>().fetchUnreadCount();
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
      await _syncRealtimeSubscriptions(response.data);
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
      await _syncRealtimeSubscriptions(response.data);
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
      await _syncRealtimeSubscriptions(conversations);
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

  /// Non-destructive refresh for the realtime / 15s-timer / app-resume paths and
  /// when returning to the list from a chat. Unlike [loadConversations] it keeps
  /// pagination and the current item count intact: it refetches the first page
  /// and MERGES it into the already-loaded set (updating changed rows, adding
  /// brand-new ones) rather than replacing everything with page 1. Replacing
  /// used to shrink an 80-item paginated list back to 20 and yank a scrolled-down
  /// user violently back up. Ordering is owned by the UI sort (pinned + recency),
  /// so here we only preserve the count. Full resets stay on
  /// [loadConversations]/[loadArchivedConversations] (tab switch, pull-to-refresh)
  /// where the list is at the top anyway.
  Future<void> refreshCurrent() async {
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
        await _syncRealtimeSubscriptions(fresh);
        return;
      }

      final freshById = {for (final c in fresh) c.id: c};
      final seen = <String>{};
      final merged = <Conversation>[];
      for (final c in existing) {
        // Replace an already-loaded row with its fresh copy (new last message,
        // unread count, pin state…); keep older paginated rows untouched.
        merged.add(freshById[c.id] ?? c);
        seen.add(c.id);
      }
      // Conversations that appeared on page 1 since the last load.
      for (final c in fresh) {
        if (!seen.contains(c.id)) merged.add(c);
      }

      _conversationsSubject.add(merged);
      await _syncRealtimeSubscriptions(merged);
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
    await _syncRealtimeSubscriptions(_conversationsSubject.value);
  }

  Future<void> _syncRealtimeSubscriptions(
    List<Conversation> conversations,
  ) async {
    final desiredIds = conversations.map((item) => item.id).toSet();
    final removed = _subscribedConversationIds.difference(desiredIds);
    final added = desiredIds.difference(_subscribedConversationIds);

    for (final id in removed) {
      await _pusherService.unsubscribeFromConversation(
        id,
        _onConversationEvent,
      );
    }
    for (final id in added) {
      await _pusherService.subscribeToConversation(
        id,
        _onConversationEvent,
      );
    }

    _subscribedConversationIds
      ..clear()
      ..addAll(desiredIds);
  }

  @override
  void dispose() {
    _realtimeRefreshTimer?.cancel();
    _fallbackRefreshTimer?.cancel();
    for (final id in _subscribedConversationIds) {
      unawaited(
        _pusherService.unsubscribeFromConversation(
          id,
          _onConversationEvent,
        ),
      );
    }
    if (_myUserId != null) {
      unawaited(
        _pusherService.unsubscribeFromUserChannel(
          _myUserId!,
          _onConversationEvent,
        ),
      );
    }
    _subscribedConversationIds.clear();
    _conversationsSubject.close();
    _isLoadingMoreSubject.close();
    _isLoadingSubject.close();
    _actionErrorsSubject.close();
    super.dispose();
  }
}
