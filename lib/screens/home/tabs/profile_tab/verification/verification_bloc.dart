import 'dart:io';

import '../../../../../data/network/response/document_type.dart';
import '../../../../../data/network/response/verification_state.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class VerificationBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  Future<VerificationSnapshot> getVerification() =>
      authRepository.getVerification();

  Future<VerificationPayResult> payVerification({
    String method = 'card',
    String? idempotencyKey,
  }) =>
      authRepository.payVerification(
        method: method,
        idempotencyKey: idempotencyKey,
      );

  Future<List<DocumentType>> loadDocumentTypes() =>
      authRepository.getDocumentTypes();

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
