import 'package:dio/dio.dart';

import '../../../data/network/request/login_request.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/push_notification_service.dart';
import '../auth_action_result.dart';

class LoginBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  Future<AuthActionResult> login(
    String email,
    String password, {
    bool remember = true,
  }) async {
    loadingSink.add(true);

    final request = LoginRequest(
      email: email,
      password: password,
      remember: remember,
      deviceName: _deviceName,
    );

    try {
      await _authRepository.login(request);
      // Access token уже сохранён репозиторием. До завершения login flow сразу
      // регистрируем актуальный FCM token авторизованным запросом.
      await _syncFcmTokenAfterAuth();
      return const AuthActionResult.success();
    } on DioException catch (e) {
      final result = _parseDioError(e);
      errorSink.add(result.message ?? 'Ошибка запроса');
      return result;
    } catch (_) {
      errorSink.add('Ошибка входа');
      return const AuthActionResult.failure(message: 'Ошибка входа');
    } finally {
      loadingSink.add(false);
    }
  }

  String get _deviceName => 'Wawatair mobile';

  AuthActionResult _parseDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final fieldErrors = <String, String>{};

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            fieldErrors[entry.key.toString()] = value.first.toString();
          } else if (value != null) {
            fieldErrors[entry.key.toString()] = value.toString();
          }
        }
      }

      final message = data['message']?.toString() ??
          (fieldErrors.isNotEmpty ? fieldErrors.values.first : null);

      return AuthActionResult.failure(
        message: message,
        fieldErrors: fieldErrors,
      );
    }

    return const AuthActionResult.failure(message: 'Ошибка запроса');
  }

  Future<void> _syncFcmTokenAfterAuth() async {
    try {
      final token = await PushNotificationService().refreshToken();
      if (token == null || token.isEmpty) {
        logger.d('FCM token is null/empty right after login');
        return;
      }
      await _authRepository.registerFcmToken(token);
      logger.d('FCM token sent to backend right after login');
    } catch (e) {
      logger.d('FCM token send after login failed: $e');
    }
  }
}
