import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../../data/network/response/notification_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';

class NotificationBloc extends BaseBloc{
  final userRepository = sl.get<AuthRepository>();

  Future<NotificationResponse> notifications() => userRepository.notifications();
}