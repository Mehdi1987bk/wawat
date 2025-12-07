import 'dart:ui';

import 'package:buking/data/network/response/user.dart';
import 'package:buking/presentation/bloc/base_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/cache/cache_manager.dart';
import '../../../../data/network/response/offer_models.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';

class ProfileTabBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();
  final CacheManager _cacheManager = sl.get<CacheManager>();

  late final Stream<User> userDetails =
      ValueConnectableStream(authRepository.userDetails).autoConnect();
  late final Future<void> logout = authRepository.logout();

 }
