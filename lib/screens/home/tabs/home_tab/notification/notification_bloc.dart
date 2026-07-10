import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/response/notification_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class NotificationBloc extends BaseBloc {
  final AuthRepository _repository = sl.get<AuthRepository>();

  final BehaviorSubject<List<NotificationItem>> notifications =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<bool> loading = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> unreadOnly = BehaviorSubject.seeded(false);
  final BehaviorSubject<int> unreadCount = BehaviorSubject.seeded(0);
  final PublishSubject<String> errors = PublishSubject();

  int _page = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  Future<void> loadNotifications({bool refresh = true}) async {
    if (_isLoadingMore) return;
    if (!refresh && _page > _lastPage) return;

    _isLoadingMore = true;
    if (refresh) {
      _page = 1;
      loading.add(true);
    }

    try {
      final response = await _repository.notifications(
        unread: unreadOnly.value ? true : null,
        page: _page,
        perPage: 20,
      );
      _lastPage = response.meta?.lastPage ?? 1;
      final next =
          refresh ? response.data : [...notifications.value, ...response.data];
      notifications.add(next);
      _page++;
      await fetchUnreadCount();
    } catch (e) {
      errors.add(e.toString());
    } finally {
      _isLoadingMore = false;
      if (refresh) loading.add(false);
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _repository.notifUnread();
      unreadCount.add(response.data.unreadCount);
    } catch (_) {}
  }

  Future<void> setUnreadOnly(bool value) async {
    if (unreadOnly.value == value) return;
    unreadOnly.add(value);
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    final current = notifications.value;
    notifications.add(current
        .map((item) => item.id == id
            ? item.copyWith(readAt: DateTime.now().toIso8601String())
            : item)
        .toList());
    try {
      await _repository.notificationsRead(id);
      await fetchUnreadCount();
    } catch (e) {
      errors.add(e.toString());
      notifications.add(current);
    }
  }

  Future<void> markAllAsRead() async {
    final current = notifications.value;
    notifications.add(current
        .map((item) => item.copyWith(readAt: DateTime.now().toIso8601String()))
        .toList());
    unreadCount.add(0);
    try {
      await _repository.notificationsReadAll();
      await loadNotifications();
    } catch (e) {
      errors.add(e.toString());
      notifications.add(current);
      await fetchUnreadCount();
    }
  }

  Future<void> delete(String id) async {
    final current = notifications.value;
    notifications.add(current.where((item) => item.id != id).toList());
    try {
      await _repository.deleteNotification(id);
      await fetchUnreadCount();
    } catch (e) {
      errors.add(e.toString());
      notifications.add(current);
    }
  }

  @override
  void dispose() {
    notifications.close();
    loading.close();
    unreadOnly.close();
    unreadCount.close();
    errors.close();
    super.dispose();
  }
}
