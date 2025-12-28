import 'dart:async';
import 'package:dio/dio.dart';

import '../../../data/network/api/auth_api.dart';
import '../../../data/network/request/forgot_password_request_email.dart';
import '../../../data/network/request/forgot_password_verify_request.dart';
import '../../../data/network/request/forgot_password_reset_request.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';

class ForgotPasswordBloc extends BaseBloc {
  final AuthApi _authApi = sl.get<AuthApi>();

  String? _verificationToken;
  String? get verificationToken => _verificationToken;

  /// Шаг 1: Запрос OTP по email
  Future<bool> requestOtp(String email) async {
    loadingSink.add(true);

    final request = ForgotPasswordRequestEmail(email: email);

    try {
      final response = await _authApi.forgotPasswordRequest(request);
      _verificationToken = response.data.verificationToken;
      return true;
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return false;
    } catch (_) {
      errorSink.add('Ошибка отправки кода');
      return false;
    } finally {
      loadingSink.add(false);
    }
  }

  /// Шаг 2: Проверка OTP
  Future<bool> verifyOtp(String otp) async {
    if (_verificationToken == null) {
      errorSink.add('Токен не найден');
      return false;
    }

    loadingSink.add(true);

    final request = ForgotPasswordVerifyRequest(
      verificationToken: _verificationToken!,
      otp: otp,
    );

    try {
      await _authApi.forgotPasswordVerify(request);
      return true;
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return false;
    } catch (_) {
      errorSink.add('Неверный код');
      return false;
    } finally {
      loadingSink.add(false);
    }
  }

  /// Шаг 3: Сброс пароля
  Future<bool> resetPassword(String password, String passwordConfirmation) async {
    if (_verificationToken == null) {
      errorSink.add('Токен не найден');
      return false;
    }

    loadingSink.add(true);

    final request = ForgotPasswordResetRequest(
      verificationToken: _verificationToken!,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    try {
      await _authApi.forgotPasswordReset(request);
      return true;
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return false;
    } catch (_) {
      errorSink.add('Ошибка сброса пароля');
      return false;
    } finally {
      loadingSink.add(false);
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
    }

    return 'Ошибка запроса';
  }
}
