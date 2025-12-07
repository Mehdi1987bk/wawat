import 'package:buking/presentation/bloc/base_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/response/notification_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';

class NotificationBloc extends BaseBloc {
  final userRepository = sl.get<AuthRepository>();

  // Координация - управление состоянием UI
  final _notificationsSubject = BehaviorSubject<NotificationResponse?>();
  final _loadingSubject = BehaviorSubject<bool>.seeded(false);
  final _errorSubject = BehaviorSubject<String?>();

  // Streams для UI
  Stream<NotificationResponse?> get notificationsStream =>
      _notificationsSubject.stream;
  Stream<bool> get loadingStream => _loadingSubject.stream;
  Stream<String?> get errorStream => _errorSubject.stream;

  // Загрузка нотификаций
  Future<void> loadNotifications() async {
    try {
      _loadingSubject.add(true);
      _errorSubject.add(null);

      final response = await userRepository.notifications();
      _notificationsSubject.add(response);
    } catch (e) {
      _errorSubject.add(e.toString());
    } finally {
      _loadingSubject.add(false);
    }
  }

  // Пометить нотификацию как прочитанную
  Future<void> markAsRead(int notificationId) async {
    // TODO: Вызвать API для пометки как прочитанной
    // Пока просто обновим локально
    final currentNotifications = _notificationsSubject.value;
    if (currentNotifications != null) {
      final updatedData = currentNotifications.data.map((item) {
        if (item.id == notificationId) {
          return NotificationItem(
            id: item.id,
            type: item.type,
            title: item.title,
            body: item.body,
            icon: item.icon,
            createdAt: item.createdAt,
            isRead: true,
          );
        }
        return item;
      }).toList();

      _notificationsSubject.add(
        NotificationResponse(data: updatedData),
      );
    }
  }

  @override
  void dispose() {
    _notificationsSubject.close();
    _loadingSubject.close();
    _errorSubject.close();
    super.dispose();
  }
}
