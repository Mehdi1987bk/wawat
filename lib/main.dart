import 'package:buking/data/network/response/type_option.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'call_interceptor.dart';
import 'data/cache/cache_manager.dart';
import 'data/cache/data_cache_manager.dart';
import 'data/network/api/auth_api.dart';
import 'data/network/response/language.dart';
import 'data/network/response/notifications.dart';
import 'data/network/response/privacy.dart';
import 'data/network/response/professional.dart';
import 'data/network/response/profile_info.dart';
import 'data/network/response/rating.dart';
import 'data/network/response/user.dart';
import 'data/repositories/data_auth_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'kango_app.dart';
import 'wawat/wawat_app.dart';

import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;
final logger = Logger(printer: SimplePrinter());
const baseUrl = 'https://wawat.tahirguliyev.com';
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  Hive
    ..init(dir.path)
    ..registerAdapter(UserAdapter())
    ..registerAdapter(RatingAdapter())
    ..registerAdapter(NotificationsAdapter())
    ..registerAdapter(PrivacyAdapter())
    ..registerAdapter(LanguageAdapter())
    ..registerAdapter(ProfessionalAdapter())
    ..registerAdapter(ProfileInfoAdapter())
    ..registerAdapter(TypeOptionAdapter());
  _registerDependency();

  runApp(WawatApp());

  // runApp(GrandWayApp());
}

void _registerDependency() {
  // ✅ СНАЧАЛА регистрируем CacheManager (до создания Dio!)
  sl.registerLazySingleton<CacheManager>(() => DataCacheManager());

  // ✅ ТЕПЕРЬ создаём Dio (CallInterceptor сможет получить CacheManager)
  final dio = _initDio();

  sl.registerLazySingleton<AuthApi>(() => AuthApi(dio));
  sl.registerLazySingleton<AuthRepository>(() => DataAuthRepository());
}


Dio _initDio() {
  final dio = Dio();

  dio.options.headers["content-type"] = "application/json";
  dio.options.headers["accept"] = "application/json";
  dio.options.connectTimeout = Duration(seconds: 120);
  dio.options.receiveTimeout = Duration(seconds: 120);
  dio.options.sendTimeout = Duration(seconds: 120);
  dio.interceptors.add(CallInterceptor());
  dio.interceptors.add(LogInterceptor(
      requestBody: true, responseBody: true, logPrint: logger.d));
  // dio.interceptors
  //     .add(DioCacheManager(CacheConfig(baseUrl: baseUrl)).interceptor);
  // dio.interceptors.add(InterceptorsWrapper(
  //     onError: (DioError dioError) => _errorInterceptor(dioError)));
  sl.registerLazySingleton<Dio>(() => dio);

  return dio;
}
