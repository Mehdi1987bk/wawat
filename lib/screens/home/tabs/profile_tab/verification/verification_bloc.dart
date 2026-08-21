import 'dart:io';

import '../../../../../data/network/response/document_type.dart';
import '../../../../../data/network/response/verification_state.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class VerificationBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  /// Current verification state + intro fee (`GET /verification`).
  Future<VerificationSnapshot> getVerification() =>
      authRepository.getVerification();

  /// Pay the activation fee (`POST /verification/pay`, mock for now).
  Future<VerificationPayResult> payVerification() =>
      authRepository.payVerification();

  Future<List<DocumentType>> loadDocumentTypes() =>
      authRepository.getDocumentTypes();

  /// Submit the chosen ID document type + selfie in one request.
  Future<void> submitVerification({
    required String idType,
    required File idFile,
    required File selfie,
  }) async {
    await run(authRepository.submitVerificationDocs(
      idType: idType,
      idFile: idFile,
      selfie: selfie,
    ));
  }
}
