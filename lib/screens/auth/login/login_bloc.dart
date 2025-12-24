import 'dart:async';
import 'package:dio/dio.dart';

import '../../../data/network/request/login_request.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';

class LoginBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  /// 🔥 Теперь возвращает bool
  Future<bool> login(String email, String password) async {
    loadingSink.add(true);

    final request = LoginRequest(
      login: email,
      password: password,
    );

    try {
      await _authRepository.login(request);
      return true; // ✅ Успех
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return false; // ❌ Ошибка
    } catch (_) {
      errorSink.add('Ошибка входа');
      return false;
    } finally {
      loadingSink.add(false);
    }
  }

  /// 🔧 Парсер ошибок API
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
