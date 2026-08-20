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
import 'services/telemetry/telemetry.dart';
import 'services/telemetry/telemetry_events.dart';
import 'services/telemetry/telemetry_interceptor.dart';
import 'services/telemetry/telemetry_route_observer.dart';

final GetIt sl = GetIt.instance;
final logger = Logger(printer: SimplePrinter());
const baseUrl = 'https://api.wawatair.com/api/v1';
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// Навигационные хлебные крошки для Crashlytics — см. wawat_app.dart.
final telemetryRouteObserver = TelemetryRouteObserver();

late ThemeManager themeManager;

void main() {
  // Всё — инициализация биндинга и runApp — внутри одной зоны.
  //
  // runZonedGuarded ловит асинхронные ошибки, до которых не дотягивается
  // PlatformDispatcher.onError (таймеры, стримы, Future без catchError).
  // Но если вызвать ensureInitialized() снаружи зоны, а runApp внутри,
  // Flutter репортит «Zone mismatch» (BindingBase.debugCheckZone) — и этот
  // отчёт уходил бы в Crashlytics при каждом запуске отладочной сборки.
  Telemetry.runGuarded(_bootstrap);
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase и пуши требуют Google Play Services. На устройствах без них или с отключённым Play — не падаем, работаем без пушей.
  // Тот же флаг решает, поднимутся ли Crashlytics/Analytics/Performance:
  // без Firebase телеметрия уходит только на собственный бэкенд.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // Must be registered immediately after Firebase.initializeApp(), before runApp().
    // Must be a top-level function — see push_notification_service.dart.
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

  // Телеметрия поднимается до пушей и до runApp, чтобы поймать ошибки самого
  // старта. Зависит от CacheManager (токен) и NetworkStatusService (не слать
  // пачки в офлайне), поэтому идёт после _registerDependency().
  await Telemetry.instance.init(
    firebaseReady: firebaseReady,
    baseUrl: baseUrl,
    tokenProvider: () => sl.get<CacheManager>().getAccessToken(),
    isOffline: () => NetworkStatusService.instance.isOffline,
  );
  _bindUserIdentity();

  // Локализация из CMS: диск-кэш грузится мгновенно, затем рефетч по ETag.
  // Не блокируем старт — UI пересоберётся, когда карта готова (notifyListeners).
  final savedLocale = await sl.get<CacheManager>().getLocaleAsync();
  unawaited(
      LocalizationService.instance.load(savedLocale?.languageCode ?? 'az'));

  try {
    final pushService = PushNotificationService();
    pushService.setOnTokenUpdated((token) {
      sl.get<AuthRepository>().registerFcmToken(token).catchError((e, st) {
        logger.d('FCM token send to backend failed: $e');
      });
    });
    await pushService.initialize();
  } catch (e, st) {
    logger.w(
        'Push notifications init failed (Google Play Services may be missing): $e');
    Telemetry.instance.error(e, st, reason: 'push_init_failed');
    Telemetry.instance.event(TelemetryEvents.featureUnavailable,
        params: {TelemetryParams.reason: 'push_init_failed'});
  }

  runApp(WawatApp());
  // NOTE: a cold-start push tap is NOT flushed here. At first frame the only
  // route is SpleshScreen, and SpleshScreen replaces the top route with Home
  // after its delay — which would destroy any screen pushed now. The pending
  // tap is flushed from HomeScreen.initState instead, so the target lands on
  // top of Home. See flushPendingNotificationNavigation() / notification_router.
}

void _registerDependency() {
  final dio = _initDio();
  sl.registerLazySingleton<AuthApi>(() => AuthApi(dio));
  sl.registerLazySingleton<ChatApi>(() => ChatApi(dio));
  sl.registerLazySingleton<AuthRepository>(() => DataAuthRepository());
  sl.registerLazySingleton<CacheManager>(() => DataCacheManager());
  unawaited(_prefetchOfferTypes());
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

  // Global new-message banner + badge over the shared Reverb socket. Adds the
  // app-resume observer and makes the first (idempotent) connect attempt; the
  // realtime loop keeps the personal channel joined after login.
  NotificationSocketService.instance.init();
}

/// Прогревает словарь типов объявлений на старте.
///
/// Раньше вызов стоял без обработчика ошибок. Любой сбой (`/dictionaries/
/// offer-types` сейчас отвечает 404) уходил необработанной ошибкой `Future`
/// в зону — то есть считался бы падением приложения при **каждом** запуске.
/// Экран и так перезапрашивает словарь, поэтому здесь ошибку достаточно
/// зафиксировать: она уже видна в панели как `api_failure`.
Future<void> _prefetchOfferTypes() async {
  try {
    await sl.get<AuthRepository>().getOfferTypes();
  } catch (e, st) {
    Telemetry.instance.error(e, st, reason: 'prefetch_offer_types');
  }
}

/// Привязывает поток телеметрии к текущему пользователю.
///
/// Слушаем кэш, а не точки логина: `saveUser` вызывается и при логине, и при
/// регистрации, и при каждом `/auth/me`, поэтому один подписчик покрывает все
/// пути входа — включая восстановление сессии при холодном старте.
///
/// В `setUserId` уходит **внутренний id**, не телефон и не e-mail: Firebase
/// прямо запрещает класть туда персональные данные, и на этом ловятся ревью
/// в сторах.
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
          TelemetryUserProps.appLocale:
              user.preferredLocale ?? sl.get<CacheManager>().getLocale()?.languageCode,
          TelemetryUserProps.themeMode: themeManager.isDarkMode ? 'dark' : 'light',
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
  dio.options.connectTimeout = Duration(seconds: 120);
  dio.options.receiveTimeout = Duration(seconds: 120);
  dio.options.sendTimeout = Duration(seconds: 120);
  dio.interceptors.add(CallInterceptor());
  // Тела запросов/ответов содержат токены, телефоны и переписку. В релизе они
  // попадали бы в logcat/os_log, откуда их читает любое приложение с доступом
  // к логам устройства — это прямое нарушение того, что мы декларируем в
  // App Privacy и Data safety. Поэтому подробный лог только в debug.
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
        requestBody: true, responseBody: true, logPrint: logger.d));
  }
  // Ставится последним: видит финальные заголовки от CallInterceptor и все
  // ошибки, пропущенные им дальше по цепочке.
  dio.interceptors.add(TelemetryInterceptor());
  sl.registerLazySingleton<Dio>(() => dio);

  return dio;
}
