import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../data/cache/cache_manager.dart';
import '../../../../../data/network/api/chat_api.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';
import '../../../../../services/network_status_service.dart';
import '../../../../../services/notification_socket_service.dart';
import '../../../../../services/pusher_service.dart';

class UnreadChatBloc extends BaseBloc {
  UnreadChatBloc({
    ChatApi? chatApi,
    CacheManager? cacheManager,
    PusherService? pusher,
  })  : _chatApi = chatApi ?? sl.get<ChatApi>(),
        _cacheManager = cacheManager ?? sl.get<CacheManager>(),
        _pusherService = pusher ?? PusherService();

  final ChatApi _chatApi;
  final CacheManager _cacheManager;
  final PusherService _pusherService;
  final _notifications = NotificationSocketService.instance;

  final _unreadCountSubject = BehaviorSubject<int>.seeded(0);
  final _archivedUnreadCountSubject = BehaviorSubject<int>.seeded(0);

  Future<void>? _fetching;
  Timer? _fallbackTimer;
  int _fallbackTick = 0;
  bool _initialized = false;
  bool _syncingRealtime = false;
  int? _myUserId;

  int _session = 0;

  Stream<int> get unreadCountStream => _unreadCountSubject.stream;

  Stream<int> get archivedUnreadCountStream =>
      _archivedUnreadCountSubject.stream;

  int get unreadCount => _unreadCountSubject.value;
  int get archivedUnreadCount => _archivedUnreadCountSubject.value;

  void setUnreadCount(int value) {
    if (!_unreadCountSubject.isClosed) {
      _unreadCountSubject.add(value < 0 ? 0 : value);
    }
  }

  void onLogout() {
    _session++;
    _myUserId = null;
    _fetching = null;
    setUnreadCount(0);
    if (!_archivedUnreadCountSubject.isClosed) {
      _archivedUnreadCountSubject.add(0);
    }
  }

  @override
  void init() {
    if (_initialized) return;
    _initialized = true;
    super.init();
    _notifications.activeConversation.addListener(_onActiveChatChanged);
    unawaited(fetchUnreadCount());
    unawaited(reconnectRealtime());
    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_inBackground) return;
      _fallbackTick++;
      final healthy = _pusherService.isConnected;
      if (!healthy || _fallbackTick % 3 == 0) {
        unawaited(fetchUnreadCount());
      }
      if (!healthy) {
        unawaited(reconnectRealtime());
      }
    });
  }

  bool get _inBackground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
  }

  bool get _chatOpen => _notifications.activeConversationId != null;

  void _onActiveChatChanged() {
    if (!_chatOpen) unawaited(fetchUnreadCount());
  }

  Future<void> fetchUnreadCount() {
    if (_chatOpen && !NetworkStatusService.instance.isOffline) {
      return Future<void>.value();
    }
    return _fetching ??= _fetch().whenComplete(() => _fetching = null);
  }

  Future<void> _fetch() async {
    final session = _session;
    try {
      final token = await _cacheManager.getToken();
      if (token == null || token.isEmpty) {
        if (!_unreadCountSubject.isClosed) _unreadCountSubject.add(0);
        if (!_archivedUnreadCountSubject.isClosed) {
          _archivedUnreadCountSubject.add(0);
        }
        return;
      }
      final counts = await _chatApi.getUnreadCount();
      if (session != _session) return;
      if (!_unreadCountSubject.isClosed) {
        _unreadCountSubject.add(counts.unread);
      }
      if (!_archivedUnreadCountSubject.isClosed) {
        _archivedUnreadCountSubject.add(counts.archived);
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

      unawaited(_notifications.ensureConnected());
    } catch (_) {
    } finally {
      _syncingRealtime = false;
    }
  }

  void _onRealtimeEvent(Map<String, dynamic> data) {
    unawaited(fetchUnreadCount());
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _notifications.activeConversation.removeListener(_onActiveChatChanged);
    if (_myUserId != null) {
      unawaited(
        _pusherService.unsubscribeFromUserChannel(
          _myUserId!,
          _onRealtimeEvent,
        ),
      );
    }
    _unreadCountSubject.close();
    _archivedUnreadCountSubject.close();
    super.dispose();
  }
}
