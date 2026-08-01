import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/api/chat_api.dart';
import '../../../../../data/network/response/notification_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

/// Thrown by [NotificationBloc.runInlineShipmentAction] when the notification
/// carries no shipment id, so the caller can fall back to opening the deal
/// screen instead of surfacing an error.
class MissingShipmentException implements Exception {
  const MissingShipmentException();
}

class NotificationBloc extends BaseBloc {
  final AuthRepository _repository = sl.get<AuthRepository>();
  final ChatApi _chatApi = sl.get<ChatApi>();

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

  /// Live refresh for realtime/app-resume: re-reads the freshest page and
  /// updates ONLY the `is_interactive` flag on already-loaded items (a deal
  /// accepted/declined/confirmed elsewhere flips it to false, hiding the inline
  /// buttons). Unlike [loadNotifications] with refresh:true, this never resets
  /// pagination, truncates the list, moves the scroll, or overwrites local
  /// read-state — so an unrelated notification or an in-flight mark-as-read is
  /// left untouched. Pending-deal notifications live on the newest page, so a
  /// single page-1 read covers them.
  Future<void> refreshInteractiveFlags() async {
    try {
      final response = await _repository.notifications(
        unread: unreadOnly.value ? true : null,
        page: 1,
        perPage: 20,
      );
      final freshById = {for (final n in response.data) n.id: n};
      final current = notifications.value;
      var changed = false;
      final updated = current.map((item) {
        final fresh = freshById[item.id];
        if (fresh != null && fresh.isInteractive != item.isInteractive) {
          changed = true;
          return item.copyWith(isInteractive: fresh.isInteractive);
        }
        return item;
      }).toList();
      if (changed) notifications.add(updated);
      await fetchUnreadCount();
    } catch (_) {
      // Best-effort — a manual pull-to-refresh still reconciles everything.
    }
  }

  /// Performs the REAL proposal accept/decline behind an inline notification
  /// button — the same one-tap path the chat deal card uses (accept/decline
  /// never need a body). On success it optimistically resolves the item (marks
  /// it read and clears `is_interactive`) so the buttons vanish at once, and
  /// returns the server's message. Throws [MissingShipmentException] when the
  /// notification has no shipment id (caller opens the deal screen instead), and
  /// rethrows API errors (caller shows them and leaves the buttons in place).
  Future<String?> runInlineShipmentAction(
    NotificationItem item,
    String action,
  ) async {
    final shipmentId = item.data.shipmentId ??
        item.target.params['shipment_id']?.toString() ??
        (item.target.type == 'shipment' ? item.target.id : null);
    if (shipmentId == null || shipmentId.isEmpty) {
      throw const MissingShipmentException();
    }
    final message = await _chatApi.shipmentAction(shipmentId, action);
    notifications.add(notifications.value
        .map((n) => n.id == item.id
            ? n.copyWith(
                isInteractive: false,
                readAt: DateTime.now().toIso8601String(),
              )
            : n)
        .toList());
    await fetchUnreadCount();
    return message;
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
