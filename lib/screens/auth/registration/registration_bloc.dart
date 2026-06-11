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

class RegistrationBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();
  final AuthApi _authApi = sl.get<AuthApi>();

  late final Future<LanguageResponse> getLanguages =
      _authRepository.getLanguages();

  Future<CountriesResponse> getCountries() {
    return _authApi.getCountries();
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
    loadingSink.add(true);

    final request = RegistrationRequest(
      fullname: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      acceptedTerms: acceptedTerms,
      languages: communicationLanguageCodes,
      callingCode: callingCode,
    );

    try {
      await _authRepository.registration(request);
      await _syncFcmTokenAfterAuth();
      return true;
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return false;
    } catch (_) {
      return false;
    } finally {
      loadingSink.add(false);
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }

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

    return 'Ошибка запроса';
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
