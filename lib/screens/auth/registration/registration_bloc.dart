import 'dart:async';

import '../../../data/network/request/registration_request.dart';
import '../../../data/network/response/registration_response.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';



class RegistrationBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  Future<void> register(
      String name,
      String email,
      String password,
       ) {
    final request = RegistrationRequest(
      name: name,
      email: email,
      password: password,
     );
    return run(_authRepository.registration(request));
  }
}