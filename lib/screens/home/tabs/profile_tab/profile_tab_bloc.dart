import 'dart:ui';

import 'package:buking/data/network/response/user.dart';
import 'package:buking/presentation/bloc/base_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/cache/cache_manager.dart';
import '../../../../data/network/request/support_request.dart';
import '../../../../data/network/response/offer_models.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';

class ProfileTabBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();
  final CacheManager _cacheManager = sl.get<CacheManager>();


  late final Stream<Locale?> locale = _cacheManager.locale;

  Future<void> support(SupportRequest request)=> authRepository.support(request);

  void setLocale(Locale locale) {
    _cacheManager.saveLocale(locale);
  }
  late final Stream<User> userDetails =
  ValueConnectableStream(authRepository.userDetails).autoConnect();

   Future<void> logout() => authRepository.logout();
}