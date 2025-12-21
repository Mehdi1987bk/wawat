import 'dart:async';
import 'package:dio/dio.dart';

import '../../../data/network/request/registration_request.dart';
import '../../../data/network/response/language_response.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';

class RegistrationBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  late final Future<LanguageResponse> getLanguages =
  _authRepository.getLanguages();

  /// 🔥 ВАЖНО: теперь возвращает bool
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool acceptedTerms,
    required List<String> communicationLanguageCodes,
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
    );

    try {
      await _authRepository.registration(request);
      return true; // ✅ УСПЕХ
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return false; // ❌ ОШИБКА
    } catch (_) {
      errorSink.add('Ошибка регистрации');
      return false;
    } finally {
      loadingSink.add(false);
    }
  }

  /// 🔧 Парсер ошибок API
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
}
