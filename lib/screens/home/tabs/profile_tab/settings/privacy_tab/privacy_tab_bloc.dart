import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../../../data/network/request/notification_settings.dart';
import '../../../../../../data/network/request/privacy_settings.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';

class PrivacyTabBloc extends BaseBloc{
  final authRepository = sl.get<AuthRepository>();
  Future<void> customersMe() => authRepository.customersMe();

  Future<void> privacyProfile(PrivacySettings request) =>
      authRepository.privacyProfile(request) ;

  Future<void> notificationsProfile(  NotificationSettings request) =>
      authRepository.notificationsProfile(request) ;
}

