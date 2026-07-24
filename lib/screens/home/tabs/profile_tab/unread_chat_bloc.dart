import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../../data/cache/cache_manager.dart';
import '../../../../../data/network/api/chat_api.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';
import '../../../../../services/pusher_service.dart';

class UnreadChatBloc extends BaseBloc {
  final _chatApi = sl.get<ChatApi>();
  final _cacheManager = sl.get<CacheManager>();
  final _pusherService = PusherService();

  final _unreadCountSubject = BehaviorSubject<int>.seeded(0);
  final Set<String> _subscribedConversationIds = {};
  Timer? _fallbackTimer;
  bool _initialized = false;
  bool _syncingRealtime = false;
  int? _myUserId;

  Stream<int> get unreadCountStream => _unreadCountSubject.stream;

  int get unreadCount => _unreadCountSubject.value;

  @override
  void init() {
    if (_initialized) return;
    _initialized = true;
    super.init();
    unawaited(fetchUnreadCount());
    unawaited(reconnectRealtime());
    _fallbackTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(fetchUnreadCount());
      unawaited(reconnectRealtime());
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      final token = await _cacheManager.getToken();
      if (token == null || token.isEmpty) {
        if (!_unreadCountSubject.isClosed) {
          _unreadCountSubject.add(0);
        }
        return;
      }
      final response = await _chatApi.getUnreadCount();
      if (!_unreadCountSubject.isClosed) {
        _unreadCountSubject.add(response);
      }
    } catch (e) {
      dispatchError(e);
    }
  }

  Future<void> reconnectRealtime() async {
    if (_syncingRealtime) return;
    _syncingRealtime = true;
    try {
      final token = await _cacheManager.getToken();
      if (token == null || token.isEmpty) return;

      await _pusherService.initialize(token);

      _myUserId ??= await _cacheManager.getUserId();
      if (_myUserId != null) {
        await _pusherService.subscribeToUserChannel(
          _myUserId!,
          _onRealtimeEvent,
        );
      }

      final response = await _chatApi.getConversations(50, 1);
      await _syncConversationSubscriptions(
        response.data.map((item) => item.id).toSet(),
      );
    } catch (_) {
      // The polling fallback still keeps the badge current.
    } finally {
      _syncingRealtime = false;
    }
  }

  void _onRealtimeEvent(Map<String, dynamic> data) {
    unawaited(fetchUnreadCount());
    final conversationId = data['conversation_id']?.toString();
    if (conversationId != null &&
        !_subscribedConversationIds.contains(conversationId)) {
      unawaited(reconnectRealtime());
    }
  }

  Future<void> _syncConversationSubscriptions(Set<String> desiredIds) async {
    final removed = _subscribedConversationIds.difference(desiredIds);
    final added = desiredIds.difference(_subscribedConversationIds);

    for (final id in removed) {
      await _pusherService.unsubscribeFromConversation(id, _onRealtimeEvent);
    }
    for (final id in added) {
      await _pusherService.subscribeToConversation(id, _onRealtimeEvent);
    }

    _subscribedConversationIds
      ..clear()
      ..addAll(desiredIds);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    for (final id in _subscribedConversationIds) {
      unawaited(
        _pusherService.unsubscribeFromConversation(id, _onRealtimeEvent),
      );
    }
    if (_myUserId != null) {
      unawaited(
        _pusherService.unsubscribeFromUserChannel(
          _myUserId!,
          _onRealtimeEvent,
        ),
      );
    }
    _subscribedConversationIds.clear();
    _unreadCountSubject.close();
    super.dispose();
  }
}
