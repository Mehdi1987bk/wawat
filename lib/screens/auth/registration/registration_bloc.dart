import 'dart:async';
import 'package:dio/dio.dart';

import '../../../data/network/api/auth_api.dart';
import '../../../data/network/request/registration_request.dart';
import '../../../data/network/response/countries_response.dart';
import '../../../data/network/response/language_response.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/push_notification_service.dart';
import '../auth_action_result.dart';

class RegistrationBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();
  final AuthApi _authApi = sl.get<AuthApi>();

  late final Future<LanguageResponse> getLanguages =
      _authRepository.getLanguages();

  Future<CountriesResponse> getCountries() {
    return _authApi.getCountries();
  }

  Future<AuthActionResult> registerWithResult({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    List<String>? communicationLanguageCodes,
    String? preferredLocale,
  }) async {
    loadingSink.add(true);

    final request = RegistrationRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      termsAccepted: termsAccepted,
      languages: communicationLanguageCodes?.isEmpty == true
          ? null
          : communicationLanguageCodes,
      preferredLocale: preferredLocale,
      deviceName: _deviceName,
    );

    try {
      await _authRepository.registration(request);
      await _syncFcmTokenAfterAuth();
      return const AuthActionResult.success();
    } on DioException catch (e) {
      final result = _parseDioError(e);
      errorSink.add(result.message ?? 'Ошибка запроса');
      return result;
    } catch (_) {
      return const AuthActionResult.failure(message: 'Ошибка регистрации');
    } finally {
      loadingSink.add(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool acceptedTerms,
    required List<String> communicationLanguageCodes,
    String? callingCode,
  }) async {
    final nameParts = name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty ? nameParts.first : name.trim();
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '-';
    final result = await registerWithResult(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      termsAccepted: acceptedTerms,
      communicationLanguageCodes: communicationLanguageCodes,
    );
    return result.isSuccess;
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
        logger.d('FCM token is null/empty right after registration');
        return;
      }
      await _authRepository.registerFcmToken(token);
      logger.d('FCM token sent to backend right after registration');
    } catch (e) {
      logger.d('FCM token send after registration failed: $e');
    }
  }
}
