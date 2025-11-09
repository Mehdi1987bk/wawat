import 'dart:async';

import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class HomeBloc extends BaseBloc {
  final _authRepository = sl.get<AuthRepository>();

  // @override
  // Future<void> raiting(RaitingRequest raitingRequest) {
  //   return _authRepository.raiting(raitingRequest);
  // }


}
