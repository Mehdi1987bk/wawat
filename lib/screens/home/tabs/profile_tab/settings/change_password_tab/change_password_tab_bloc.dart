import 'package:dio/dio.dart';

import '../../../../../../data/network/api/auth_api.dart';
import '../../../../../../data/network/request/change_password_request.dart';
import '../../../../../../main.dart';
import '../../../../../../presentation/bloc/base_bloc.dart';

class ChangePasswordTabBloc extends BaseBloc {
  final AuthApi _authApi = sl.get<AuthApi>();

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    loadingSink.add(true);

    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      password: newPassword,
      passwordConfirmation: confirmPassword,
    );

    try {
      await _authApi.changePassword(request);
      return true;
    } on DioException catch (e) {
      final message = _parseDioError(e);
      errorSink.add(message);
      return false;
    } catch (_) {
      errorSink.add('Ошибка смены пароля');
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
}
