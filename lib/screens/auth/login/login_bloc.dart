// lib/screens/login/login_bloc.dart
import 'dart:async';

import '../../../data/network/request/login_request.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import 'dart:async';


class LoginBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  Future<void> login(String email, String password) {
    final request = LoginRequest(
      email: email,
      password: password,
    );
    return run(_authRepository.login(request));
  }
}