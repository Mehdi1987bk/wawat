import 'dart:async';

import '../../data/network/request/login_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/bloc/base_bloc.dart';

class LoginBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  Future<void> login(String phone, String password) {
    final request = LoginRequest(
      phone: phone,
      password: password,
    );
    return run(_authRepository.login(request));
  }
}
