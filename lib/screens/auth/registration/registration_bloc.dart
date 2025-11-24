import 'dart:async';

import '../../../data/network/request/registration_request.dart';
import '../../../data/network/response/language_response.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';

class RegistrationBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  late final Future<LanguageResponse> getLanguages =
  _authRepository.getLanguages();

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool acceptedTerms,
    required List<int> communicationLanguageIds,
  }) {
    final request = RegistrationRequest(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      acceptedTerms: acceptedTerms,
      communicationLanguageIds: communicationLanguageIds,
    );
    return run(_authRepository.registration(request));
  }
}