import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../../data/network/response/faq_response.dart';
import '../../../../../data/network/response/privacy_policy_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';

class FaqBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

 late final Future<FaqResponse> faqs = authRepository.faqs();
}
