import 'package:dio/dio.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../auth_action_result.dart';

class EmailVerifyBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  Future<AuthActionResult> resendVerificationLink() async {
    loadingSink.add(true);
    try {
      await _authRepository.resendEmailVerification();
      return const AuthActionResult.success();
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return AuthActionResult.failure(message: message);
    } catch (_) {
      const message = 'Təsdiq linkini göndərmək mümkün olmadı.';
      errorSink.add(message);
      return const AuthActionResult.failure(message: message);
    } finally {
      loadingSink.add(false);
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Sorğu xətası';
    }
    return 'Sorğu xətası';
  }
}
