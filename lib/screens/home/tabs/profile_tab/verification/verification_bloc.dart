import 'dart:io';

import '../../../../../data/network/response/verification_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class VerificationBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  Future<VerificationResponse> verificationStatus( ) =>
      authRepository.verificationStatus( );

  Future<void> submitVerification({
    required File passport,
    required File selfie,
  }) async {
    try {
      await authRepository.submitVerification(
        passport: passport,
        selfie: selfie,
      );
    } catch (e) {
      rethrow;
    }
  }
}
