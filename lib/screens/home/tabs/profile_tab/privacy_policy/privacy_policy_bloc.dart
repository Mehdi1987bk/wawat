import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../../data/network/response/privacy_policy_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';

class PrivacyPolicyBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  Future<PrivacyPolicyResponse> privacyPolicy() =>
      authRepository.privacyPolicy();
}
