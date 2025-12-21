import 'package:buking/presentation/bloc/base_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/request/create_review_request.dart';
import '../../../../../data/network/response/notification_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';

class NotificationBloc extends BaseBloc {
  final userRepository = sl.get<AuthRepository>();

  // Координация - управление состоянием UI
  final _notificationsSubject = BehaviorSubject<NotificationResponse?>();
  final _loadingSubject = BehaviorSubject<bool>.seeded(false);
  final _errorSubject = PublishSubject<String?>();

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
  void markAsRead(int notificationId) {
    print('Marking notification as read: $notificationId');

    // TODO: Вызвать API для пометки как прочитанной
    // await userRepository.markNotificationAsRead(notificationId);

    // Обновляем локально
    final currentNotifications = _notificationsSubject.valueOrNull;
    if (currentNotifications != null) {
      final updatedData = currentNotifications.data.map((item) {
        if (item.id == notificationId) {
          // Создаем новый объект с обновленным isRead
          return NotificationItem(
            id: item.id,
            type: item.type,
            title: item.title,
            body: item.body,
            icon: item.icon,
            data: item.data,
            createdAt: item.createdAt,
            isRead: true, // Помечаем как прочитанную
          );
        }
        return item;
      }).toList();

      _notificationsSubject.add(
        NotificationResponse(data: updatedData),
      );

      print('Notification $notificationId marked as read');
    }
  }

  Future<void> sendReviews(CreateReviewRequest request) =>
      run(userRepository.sendReviews(request));

  @override
  void dispose() {
    _notificationsSubject.close();
    _loadingSubject.close();
    _errorSubject.close();
    super.dispose();
  }
}