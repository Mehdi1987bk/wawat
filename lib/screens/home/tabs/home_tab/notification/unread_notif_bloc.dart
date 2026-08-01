import 'package:rxdart/rxdart.dart';

import '../../../../../data/cache/cache_manager.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class UnreadNotificationBloc extends BaseBloc {
  final userRepository = sl.get<AuthRepository>();
  final _cacheManager = sl.get<CacheManager>();

  final _unreadCountSubject = BehaviorSubject<int>.seeded(0);
  bool _initialized = false;

  Stream<int> get unreadCountStream => _unreadCountSubject.stream;

  int get unreadCount => _unreadCountSubject.value;

  /// Single source of truth for the badge — pushed here from the realtime
  /// `new_notification` payload (`unread_count`) so every screen updates
  /// instantly without an extra API round-trip. Mirrors [UnreadChatBloc].
  void setUnreadCount(int value) {
    if (!_unreadCountSubject.isClosed) {
      _unreadCountSubject.add(value < 0 ? 0 : value);
    }
  }

  @override
  void init() {
    if (_initialized) return;
    _initialized = true;
    super.init();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    try {
      // Singleton lives app-wide; without a token (logged out) the badge must
      // self-clear so it can't show the previous user's count to a guest.
      final token = await _cacheManager.getToken();
      if (token == null || token.isEmpty) {
        setUnreadCount(0);
        return;
      }
      final response = await userRepository.notifUnread();
      // The singleton is never disposed, so guard the late write: if auth
      // changed during the request (logout OR user-switch), drop this result so
      // it can't re-show the previous session's count.
      final tokenAfter = await _cacheManager.getToken();
      if (tokenAfter != token) return;
      if (!_unreadCountSubject.isClosed) {
        _unreadCountSubject.add(response.data.unreadCount);
      }
    } catch (e) {
      dispatchError(e);
    }
  }

  @override
  void dispose() {
    _unreadCountSubject.close();
    super.dispose();
  }
}
