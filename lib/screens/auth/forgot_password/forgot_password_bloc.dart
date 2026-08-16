import 'dart:async';
import 'package:dio/dio.dart';

import '../../../data/network/api/auth_api.dart';
import '../../../data/network/request/forgot_password_request_email.dart';
import '../../../data/network/request/forgot_password_verify_request.dart';
import '../../../data/network/request/forgot_password_reset_request.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/localization_service.dart';
import '../auth_action_result.dart';

class ForgotPasswordBloc extends BaseBloc {
  final AuthApi _authApi = sl.get<AuthApi>();

  String? _verificationToken;
  String? get verificationToken => _verificationToken;
  int _expiresInSeconds = 600;
  int get expiresInSeconds => _expiresInSeconds;

  Future<AuthActionResult> requestOtp(String email) async {
    loadingSink.add(true);

    final request = ForgotPasswordRequestEmail(email: email);

    try {
      final response = await _authApi.forgotPasswordRequest(request);
      _verificationToken = response.data.verificationToken;
      _expiresInSeconds = response.data.expiresInSeconds;
      if (_verificationToken == null || _verificationToken!.isEmpty) {
        return AuthActionResult.failure(
          message: response.message ??
              tr('auth.otp_sent_to_email',
                  'Təsdiq kodu email-inizə göndərildi.'),
        );
      }
      return AuthActionResult.success(message: response.message);
    } on DioException catch (e) {
      final result = _parseDioError(e);
      errorSink
          .add(result.message ?? tr('common.request_error', 'Sorğu xətası'));
      return result;
    } catch (_) {
      final message =
          tr('auth.send_code_failed', 'Kod göndərmək mümkün olmadı.');
      errorSink.add(message);
      return AuthActionResult.failure(message: message);
    } finally {
      loadingSink.add(false);
    }
  }

  Future<AuthActionResult> verifyOtp(String otp) async {
    if (_verificationToken == null) {
      final message = tr('auth.invalid_reset_token', 'Bərpa tokeni yanlışdır.');
      errorSink.add(message);
      return AuthActionResult.failure(message: message);
    }

    loadingSink.add(true);

    final request = ForgotPasswordVerifyRequest(
      verificationToken: _verificationToken!,
      otp: otp,
    );

    try {
      await _authApi.forgotPasswordVerify(request);
      return const AuthActionResult.success();
    } on DioException catch (e) {
      final result = _parseDioError(e);
      errorSink
          .add(result.message ?? tr('common.request_error', 'Sorğu xətası'));
      return result;
    } catch (_) {
      final message = tr('auth.invalid_code', 'Kod yanlışdır.');
      errorSink.add(message);
      return AuthActionResult.failure(message: message);
    } finally {
      loadingSink.add(false);
    }
  }

  Future<AuthActionResult> resetPassword(
      String password, String passwordConfirmation) async {
    if (_verificationToken == null) {
      final message = tr('auth.invalid_reset_token', 'Bərpa tokeni yanlışdır.');
      errorSink.add(message);
      return AuthActionResult.failure(message: message);
    }

    loadingSink.add(true);

    final request = ForgotPasswordResetRequest(
      verificationToken: _verificationToken!,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    try {
      await _authApi.forgotPasswordReset(request);
      return const AuthActionResult.success();
    } on DioException catch (e) {
      final result = _parseDioError(e);
      errorSink
          .add(result.message ?? tr('common.request_error', 'Sorğu xətası'));
      return result;
    } catch (_) {
      final message =
          tr('auth.reset_password_failed', 'Şifrəni yeniləmək mümkün olmadı.');
      errorSink.add(message);
      return AuthActionResult.failure(message: message);
    } finally {
      loadingSink.add(false);
    }
  }

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

    return AuthActionResult.failure(
        message: tr('common.request_error', 'Sorğu xətası'));
  }
}
