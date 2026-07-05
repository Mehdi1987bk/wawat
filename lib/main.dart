import 'package:buking/data/network/response/type_option.dart';
import 'package:buking/screens/home/tabs/profile_tab/unread_chat_bloc.dart';
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
import 'data/network/api/chat_api.dart';
import 'data/network/response/language.dart';
import 'data/network/response/notifications.dart';
import 'data/network/response/packet_type_resp.dart';
import 'data/network/response/privacy.dart';
import 'data/network/response/professional.dart';
import 'data/network/response/profile_info.dart';
import 'data/network/response/rating.dart';
import 'data/network/response/stats.dart';
import 'data/network/response/user.dart';
import 'data/repositories/data_auth_repository.dart';
import 'domain/repositories/auth_repository.dart';
 import 'wawat_app.dart';
import 'services/theme_manager.dart';
import 'wawat/wawat_app.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/push_notification_service.dart';

final GetIt sl = GetIt.instance;
final logger = Logger(printer: SimplePrinter());
const baseUrl = 'https://api.wawatair.com/api/v1';
final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

late ThemeManager themeManager;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase и пуши требуют Google Play Services. На устройствах без них или с отключённым Play — не падаем, работаем без пушей.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Must be registered immediately after Firebase.initializeApp(), before runApp().
    // Must be a top-level function — see push_notification_service.dart.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e, st) {
    logger.w('Firebase init failed (device may lack Google Play Services): $e');
  }


  final dir = await getApplicationDocumentsDirectory();

  await Hive.initFlutter(dir.path);

  Hive
    ..init(dir.path)
    ..registerAdapter(UserAdapter())
    ..registerAdapter(RatingAdapter())
    ..registerAdapter(NotificationsAdapter())
    ..registerAdapter(PrivacyAdapter())
    ..registerAdapter(LanguageAdapter())
    ..registerAdapter(StatsAdapter())
    ..registerAdapter(ProfessionalAdapter())
    ..registerAdapter(ProfileInfoAdapter())
    ..registerAdapter(PacketTypeRespAdapter())
    ..registerAdapter(TypeOptionAdapter());

  _registerDependency();

  themeManager = await ThemeManager.create();

  try {
    await PushNotificationService().initialize();
    PushNotificationService().setOnTokenUpdated((token) {
      sl.get<AuthRepository>().registerFcmToken(token).catchError((e, st) {
        logger.d('FCM token send to backend failed: $e');
      });
    });
    final fcmToken = await PushNotificationService().refreshToken();
    if (fcmToken != null) {
      sl.get<AuthRepository>().registerFcmToken(fcmToken).catchError((e, st) {
        logger.d('FCM mock send to backend failed: $e');
      });
    }
  } catch (e, st) {
    logger.w('Push notifications init failed (Google Play Services may be missing): $e');
  }

  runApp(WawatApp());
}

void _registerDependency() {
  final dio = _initDio();
  sl.registerLazySingleton<AuthApi>(() => AuthApi(dio));
  sl.registerLazySingleton<ChatApi>(() => ChatApi(dio));
  sl.registerLazySingleton<AuthRepository>(() => DataAuthRepository());
  sl.registerLazySingleton<CacheManager>(() => DataCacheManager());
  sl.get<AuthRepository>().getOfferTypes();
  sl.registerLazySingleton<UnreadChatBloc>(() {
    final bloc = UnreadChatBloc();
    bloc.init();
    return bloc;
  });
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
  sl.registerLazySingleton<Dio>(() => dio);

  return dio;
}
