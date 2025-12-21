import 'package:buking/presentation/bloc/base_bloc.dart';
import 'package:dio/dio.dart';
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

    userRepository.notificationsRead(notificationId);

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


  /// 🔥 Теперь возвращает bool
  Future<bool> sendReviews(CreateReviewRequest request) async {
    _loadingSubject.add(true);  // ✅ Используем локальный subject
    _errorSubject.add(null);    // ✅ Сбрасываем предыдущую ошибку

    try {
      await userRepository.sendReviews(request);
      print('✅ Review sent successfully');
      return true;
    } on DioException catch (e) {
      final message = _parseDioError(e);
      print('❌ DioException: $message'); // Для отладки
      _errorSubject.add(message);  // ✅ Используем локальный subject
      return false;
    } catch (e) {
      print('❌ Unknown error: $e');
      _errorSubject.add('Ошибка отправки отзыва');
      return false;
    } finally {
      _loadingSubject.add(false);  // ✅ Используем локальный subject
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      // Сначала проверяем message
      if (data['message'] != null) {
        return data['message'].toString();
      }

      // Потом errors
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }
        }
      }
    }

    return 'Ошибка запроса (${e.response?.statusCode ?? "неизвестно"})';
  }

  @override
  void dispose() {
    _notificationsSubject.close();
    _loadingSubject.close();
    _errorSubject.close();
    super.dispose();
  }
}