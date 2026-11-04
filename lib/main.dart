import 'package:buking/data/network/response/type_option.dart';
import 'package:buking/screens/home/tabs/home_tab/notification/unread_notif_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/unread_chat_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';

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
import 'services/localization_service.dart';
import 'services/theme_manager.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/push_notification_service.dart';
import 'services/network_status_service.dart';
import 'services/notification_socket_service.dart';
import 'services/retry_gate.dart';
import 'services/telemetry/telemetry.dart';
import 'services/telemetry/telemetry_events.dart';
import 'services/telemetry/telemetry_interceptor.dart';
import 'services/telemetry/telemetry_route_observer.dart';
import 'screens/payments/iap/iap_catalog.dart';
import 'screens/payments/iap/iap_service.dart';

final GetIt sl = GetIt.instance;
final logger = Logger(printer: SimplePrinter());
const baseUrl = 'https://api.wawatair.com/api/v1';
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final telemetryRouteObserver = TelemetryRouteObserver();

late ThemeManager themeManager;

void main() {
  Telemetry.runGuarded(_bootstrap);
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (e) {
    logger.w('Firebase init failed (device may lack Google Play Services): $e');
  }

  final dir = await getApplicationDocumentsDirectory();

  await Hive.initFlutter(dir.path);

  Hive
    ..init(dir.path)
    ..registerAdapter(UserAdapter())
    ..registerAdapter(ListingQuotaAdapter())
    ..registerAdapter(ListingQuotaItemAdapter())
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
  await NetworkStatusService.instance.initialize();

  await Telemetry.instance.init(
    firebaseReady: firebaseReady,
    baseUrl: baseUrl,
    tokenProvider: () => sl.get<CacheManager>().getAccessToken(),
    isOffline: () => NetworkStatusService.instance.isOffline,
  );
  _bindUserIdentity();

  if (kIapEnabled) {
    unawaited(_initializeIap());
  }

  final savedLocale = await sl.get<CacheManager>().getLocaleAsync();
  unawaited(
      LocalizationService.instance.load(savedLocale?.languageCode ?? 'az'));

  try {
    final pushService = PushNotificationService();
    pushService.setOnTokenUpdated(
      (token) => sl.get<AuthRepository>().registerFcmToken(token),
    );
    await pushService.initialize();
  } catch (e, st) {
    logger.w(
        'Push notifications init failed (Google Play Services may be missing): $e');
    Telemetry.instance.error(e, st, reason: 'push_init_failed');
    Telemetry.instance.event(TelemetryEvents.featureUnavailable,
        params: {TelemetryParams.reason: 'push_init_failed'});
  }

  runApp(WawatApp());
}

Future<void> _initializeIap() async {
  final iap = IapService.instance;
  iap.useCatalogLoader(BackendIapCatalogLoader(sl.get<Dio>()));
  iap.useValidator(BackendPurchaseValidator(sl.get<Dio>()));
  try {
    await iap.init();
  } catch (error, stackTrace) {
    logger.w('IAP initialization failed: $error');
    Telemetry.instance.error(error, stackTrace, reason: 'iap_init_failed');
  }
}

void _registerDependency() {
  final dio = _initDio();
  sl.registerLazySingleton<AuthApi>(() => AuthApi(dio));
  sl.registerLazySingleton<ChatApi>(() => ChatApi(dio));
  sl.registerLazySingleton<AuthRepository>(() => DataAuthRepository());
  sl.registerLazySingleton<CacheManager>(() => DataCacheManager());
  sl.registerLazySingleton<UnreadChatBloc>(() {
    final bloc = UnreadChatBloc();
    bloc.init();
    return bloc;
  });
  sl.registerLazySingleton<UnreadNotificationBloc>(() {
    final bloc = UnreadNotificationBloc();
    bloc.init();
    return bloc;
  });

  NotificationSocketService.instance.init();
}

void _bindUserIdentity() {
  sl.get<CacheManager>().userDetails.listen(
    (user) {
      if (user == null) {
        unawaited(Telemetry.instance.clearIdentity());
        return;
      }
      unawaited(Telemetry.instance.identify(
        user.id?.toString(),
        properties: {
          TelemetryUserProps.userType:
              user.professional != null ? 'courier' : 'user',
          TelemetryUserProps.isVerified:
              (user.isVerified ?? false) ? 'true' : 'false',
          TelemetryUserProps.tierLevel: user.tier,
          TelemetryUserProps.hasListings:
              ((user.stats?.offersTotal ?? 0) > 0) ? 'true' : 'false',
          TelemetryUserProps.appLocale: user.preferredLocale ??
              sl.get<CacheManager>().getLocale()?.languageCode,
          TelemetryUserProps.themeMode:
              themeManager.isDarkMode ? 'dark' : 'light',
        },
      ));
    },
    onError: (Object e, StackTrace st) =>
        Telemetry.instance.error(e, st, reason: 'user_stream'),
  );
}

Dio _initDio() {
  final dio = Dio();

  dio.options.headers["content-type"] = "application/json";
  dio.options.headers["accept"] = "application/json";
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 20);
  dio.options.sendTimeout = const Duration(seconds: 60);
  dio.interceptors.add(RetryGate());
  dio.interceptors.add(CallInterceptor());
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
        requestBody: true, responseBody: true, logPrint: logger.d));
  }
  dio.interceptors.add(TelemetryInterceptor());
  sl.registerLazySingleton<Dio>(() => dio);

  return dio;
}
