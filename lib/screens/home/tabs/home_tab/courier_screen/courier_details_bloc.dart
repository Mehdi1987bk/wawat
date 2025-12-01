import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../../data/network/response/partner_user_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';

class CourierDetailsBloc extends BaseBloc{
  final authRepository = sl.get<AuthRepository>();

  Future<PartnerUserResponse> getUserById(int date) => authRepository.getUserById(date);
}