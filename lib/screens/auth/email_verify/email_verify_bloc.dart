import 'package:dio/dio.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/localization_service.dart';
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
      final message = tr(
          'auth.resend_link_failed', 'Təsdiq linkini göndərmək mümkün olmadı.');
      errorSink.add(message);
      return AuthActionResult.failure(message: message);
    } finally {
      loadingSink.add(false);
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          tr('common.request_error', 'Sorğu xətası');
    }
    return tr('common.request_error', 'Sorğu xətası');
  }
}
