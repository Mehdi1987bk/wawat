import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import 'notification_banner.dart';
import 'notification_router.dart';
import 'notification_socket_service.dart';
import 'telemetry/telemetry.dart';
import 'telemetry/telemetry_events.dart';

// Android не позволяет менять звук уже созданного notification channel.
// Новый id гарантирует, что после обновления канал создастся именно с
// airplane.mp3, даже если старый канал был создан с default sound.
// Канал ТАКЖЕ создаётся нативно в WawatApplication.onCreate() — до того как
// FirebaseMessagingService успеет обработать пуш, — чтобы звук был правильным
// даже для notification-пушей, пришедших пока приложение убито. Держи этот id в
// синхроне с WawatApplication.kt и default_notification_channel_id в манифесте.
const _androidChannelId = 'wawat_airplane_v5';
const _legacyAndroidChannelIds = [
  'high_importance_channel',
  'wawat_high_importance',
  'wawat_alerts',
  'wawat_airplane_v2',
  'wawat_airplane_v3',
  // v4 was PINNED by the backend before the app guaranteed native channel
  // creation, so on devices that received a v4 push first Android auto-created
  // it with the DEFAULT sound (immutable). Escape to v5 and delete v4.
  'wawat_airplane_v4',
];
const _androidChannelName = 'Wawat Air';
const _androidChannelDescription = 'Уведомления Wawat Air';
const _androidSound = 'airplane';
// White silhouette shown as the (small) status-bar icon; res/drawable-*.
const _androidSmallIcon = 'ic_stat_wawat';
// Full-colour brand mark shown large on the right of app-built notifications;
// res/drawable-nodpi. Only applies when the app builds the notification
// (foreground, or every state once the backend switches to data-only pushes).
const _androidLargeIcon = 'ic_notification_large';
// Brand blue the system tints the small icon / header with.
const _brandColor = Color(0xFF007AFE);

/// Background FCM handler — MUST be a top-level function, registered in main()
/// via FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler).
/// Runs in a separate isolate; do NOT import main.dart state here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _logIncomingMessage('background', message);

  // notification + data payloads are displayed by Android/iOS themselves.
  // A data-only push needs a local notification to remain visible.
  if (!Platform.isAndroid || message.notification != null) return;

  final title = _firstNonEmpty([
    message.data['title'],
    message.data['notification_title'],
  ]);
  final body = _firstNonEmpty([
    message.data['body'],
    message.data['message'],
    message.data['notification_body'],
  ]);
  if (title == null && body == null) return;

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings(_androidSmallIcon),
    ),
  );
  await _createAndroidNotificationChannels(localNotifications);
  await localNotifications.show(
    message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
    title ?? 'Wawat Air',
    body ?? '',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_androidSound),
        icon: _androidSmallIcon,
        largeIcon: DrawableResourceAndroidBitmap(_androidLargeIcon),
        color: _brandColor,
      ),
    ),
    payload: message.data.isEmpty ? null : jsonEncode(message.data),
  );
}

String? _firstNonEmpty(Iterable<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return null;
}

/// TEMP push diagnostics — prints the channel/sound the backend actually routed
/// this push to, plus its lifecycle phase. This is how we see the real on-device
/// payload without backend access: if `android.channelId` is a legacy id (or
/// `android.sound` is "default"), the backend is the fault, not the app. Never
/// logs the FCM token. Remove once the sound is confirmed.
void _logIncomingMessage(String phase, RemoteMessage message) {
  final android = message.notification?.android;
  debugPrint(
    'FCM[$phase] id=${message.messageId} '
    'hasNotification=${message.notification != null} '
    'android.channelId=${android?.channelId} '
    'android.sound=${android?.sound} '
    'data=${message.data}',
  );
}

Future<void> _createAndroidNotificationChannels(
  FlutterLocalNotificationsPlugin plugin,
) async {
  final android = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android == null) return;

  const primaryChannel = AndroidNotificationChannel(
    _androidChannelId,
    _androidChannelName,
    description: _androidChannelDescription,
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(_androidSound),
  );
  await android.createNotificationChannel(primaryChannel);

  // The legacy channels have an IMMUTABLE sound on devices where they were first
  // created with the system default (old builds / FCM auto-create) — recreating
  // them can never change it. Delete them so any push the backend still routes
  // to an old id falls back to the manifest default channel (wawat_airplane_v5),
  // which carries the airplane sound. The definitive fix is native creation in
  // WawatApplication.onCreate() (runs before FirebaseMessagingService); this is
  // the Flutter-side mirror of the same channel.
  for (final channelId in _legacyAndroidChannelIds) {
    await android.deleteNotificationChannel(channelId);
  }
}

/// Сервис Firebase Push Notifications: инициализация, права, показ в foreground,
/// обработка нажатий и получение FCM токена.
class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;

  /// Когда токен последний раз успешно ушёл на бэкенд. Лежит в
  /// SharedPreferences, а не в Hive: Hive-бокс целиком чистится при выходе из
  /// аккаунта, а нам нужно переживать и выход, и смену пользователя.
  static const _lastSyncKey = 'push_token_last_sync_ms';

  /// На возврате из фона токен пересылаем не чаще раза в сутки — этого хватает,
  /// чтобы на бэкенде было видно живые установки, и не создаёт лишних запросов.
  static const _resyncInterval = Duration(hours: 24);

  static final _logger = Logger(printer: SimplePrinter());
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// FCM token для отправки на бэкенд (обновляется при refresh).
  String? get fcmToken => _fcmToken;
  String? _fcmToken;

  /// Инициализация: канал уведомлений, локальные уведомления, FCM handlers, запрос прав, токен.
  Future<void> initialize() async {
    await _initLocalNotifications();
    await _createAndroidChannel();
    await _setForegroundPresentationOptions();
    // onBackgroundMessage is registered in main() before runApp() — do not register again here.

    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchPayload != null &&
        launchPayload.isNotEmpty) {
      _handleLocalNotificationPayload(launchPayload);
    }

    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleMessageOpened(message);
    });

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Разрешение НЕ спрашивается на первом экране.
    //
    // На iOS отказ необратим: без разрешения нет APNs-токена, а без APNs-токена
    // getToken() возвращает null — устройство навсегда остаётся без пушей, и
    // именно поэтому живых ios-токенов 16 против 400 android. Поэтому на iOS
    // спрашиваем после осмысленного действия (maybeAskPushPermission), а здесь
    // только синхронизируем токен, если разрешение уже выдано.
    //
    // На Android токен выдаётся и без разрешения, а системный диалог можно
    // показать повторно — там поведение не меняем.
    if (Platform.isAndroid) {
      await requestPermission();
    }
    if (Platform.isAndroid || await hasPermission()) {
      await syncToken(reason: 'cold_start');
    }

    // Возврат из фона: FCM меняет токен сам (обновление приложения,
    // восстановление из бэкапа, очистка данных), поэтому раз в сутки
    // перепроверяем и переотправляем.
    WidgetsBinding.instance.addObserver(this);

    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _logger.d('FCM token refreshed');
      // Старый токен на бэкенде уже мёртв — отправляем новый сразу.
      unawaited(_sendToBackend(token, reason: 'token_refresh'));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_syncOnResume());
  }

  Future<void> _syncOnResume() async {
    // На iOS без разрешения getToken() всё равно вернёт null — не дёргаем.
    if (Platform.isIOS && !await hasPermission()) return;
    final lastSync = await _lastSyncAt();
    if (lastSync != null &&
        DateTime.now().difference(lastSync) < _resyncInterval) {
      return;
    }
    await syncToken(reason: 'resume');
  }

  /// Отправка токена на бэкенд. Колбэк обязан вернуть Future, который падает
  /// при неудаче: по нему сервис решает, помечать ли синхронизацию успешной.
  /// Если отправка не удалась, метка не ставится и следующий возврат из фона
  /// попробует снова.
  void setOnTokenUpdated(Future<void> Function(String token)? callback) {
    _onTokenUpdated = callback;
  }

  Future<void> Function(String token)? _onTokenUpdated;

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings(_androidSmallIcon);
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Разрешение здесь НЕ запрашивается: это делает requestPermission() через
    // FirebaseMessaging (он же покрывает POST_NOTIFICATIONS на Android 13+).
    // Раньше диалог всплывал прямо на первом кадре — ровно то поведение, из-за
    // которого на iOS отказываются и устройство остаётся без пушей навсегда.
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    _handleLocalNotificationPayload(payload);
  }

  void _handleLocalNotificationPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        handleNotificationNavigation(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      _logger.d('Notification payload parse failed: $e');
    }
  }

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    await _createAndroidNotificationChannels(_localNotifications);
  }

  Future<void> _setForegroundPresentationOptions() {
    // In-app (foreground): play the push sound but do NOT show the OS banner —
    // the in-app banner handles the visual. `alert: false` drops the top
    // drop-down; `sound: true` still plays it. Background/killed are unaffected.
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    _logIncomingMessage('foreground', message);
    Telemetry.instance.event(TelemetryEvents.pushReceivedForeground, params: {
      TelemetryParams.source: message.data['type'] ?? 'unknown',
    });
    final notification = message.notification;
    final title = notification?.title ??
        _firstNonEmpty([
          message.data['title'],
          message.data['notification_title'],
        ]);
    final body = notification?.body ??
        _firstNonEmpty([
          message.data['body'],
          message.data['message'],
          message.data['notification_body'],
        ]);
    if (title == null && body == null) return;

    // Foreground = inside the app. Show OUR in-app banner (the visual) and keep
    // the OS/system notification suppressed. This guarantees the banner appears
    // even if the realtime socket didn't deliver its own; showNotificationBanner
    // replaces any current banner, so the two paths never stack.
    _showInAppBanner(message, title: title, body: body);

    // Sound only — no OS notification:
    //  • Android: FCM never auto-shows in foreground, so play the sound ourselves.
    //  • iOS notification payload: the OS plays the sound via the presentation
    //    options above (alert:false → no banner), so nothing to do here.
    //  • iOS data-only: no OS notification exists, so a silent local one
    //    (presentAlert:false) plays the sound without a banner.
    if (Platform.isAndroid) {
      _playForegroundSound();
    } else if (Platform.isIOS && notification == null) {
      _showLocalNotification(
        id: message.hashCode,
        title: title ?? 'Wawat Air',
        body: body ?? '',
        payload: message.data.isEmpty ? null : jsonEncode(message.data),
      );
    }
  }

  /// Builds and shows the in-app banner for a foreground push, from the FCM
  /// `data` map. Mirrors the realtime-socket banner so both look identical; tap
  /// routes by `target_type` via [handleNotificationNavigation].
  void _showInAppBanner(
    RemoteMessage message, {
    required String? title,
    required String? body,
  }) {
    final data = Map<String, dynamic>.from(message.data);
    final type = (data['target_type'] ?? data['type'] ?? '').toString().trim();
    final actorName = _firstNonEmpty([data['actor_name']]);
    final actorAvatar = _firstNonEmpty([data['actor_avatar_thumb_url']]);

    if (type == 'conversation') {
      final convId =
          _firstNonEmpty([data['conversation_id'], data['target_id']]);
      // Already reading this thread → the chat updates live, no banner needed.
      if (convId != null &&
          NotificationSocketService.instance.activeConversationId == convId) {
        return;
      }
      showNotificationBanner(
        NotificationBannerData.notification(
          title: actorName ?? title ?? 'Wawat Air',
          body: body,
          type: 'new_message',
          actorName: actorName,
          actorAvatarUrl: actorAvatar,
        ),
        onTap: () => handleNotificationNavigation(data),
      );
      return;
    }

    // review_received carries stars + comment; other types use the type icon.
    final rating = int.tryParse(data['rating']?.toString() ?? '');
    showNotificationBanner(
      NotificationBannerData.notification(
        title: title ?? 'Wawat Air',
        body: body,
        type: type.isEmpty ? 'none' : type,
        actorName: actorName,
        actorAvatarUrl: actorAvatar,
        rating: rating,
        comment: _firstNonEmpty([data['comment']]),
      ),
      onTap: () => handleNotificationNavigation(data),
    );
  }

  final AudioPlayer _foregroundSoundPlayer = AudioPlayer();

  /// Plays the push sound in-app (foreground) with NO OS notification. Routed to
  /// the notification stream and requests no audio focus, so it's a short blip
  /// that doesn't pause the user's music.
  Future<void> _playForegroundSound() async {
    try {
      await _foregroundSoundPlayer.setReleaseMode(ReleaseMode.stop);
      await _foregroundSoundPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      await _foregroundSoundPlayer.stop();
      await _foregroundSoundPlayer.play(AssetSource('airplane.mp3'));
    } catch (e) {
      _logger.d('Foreground push sound failed: $e');
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_androidSound),
      icon: _androidSmallIcon,
      largeIcon: DrawableResourceAndroidBitmap(_androidLargeIcon),
      color: _brandColor,
    );
    const iosDetails = DarwinNotificationDetails(
      // Foreground data-only push: sound only, no banner (the in-app banner is
      // the visual). Background/killed pushes are notification payloads rendered
      // by the OS, unaffected by this.
      presentAlert: false,
      presentBadge: true,
      presentSound: true,
      // iOS only plays caf/aiff/wav for notifications (never mp3) and matches
      // the file by exact name — this is the same airplane.caf the backend puts
      // in apns.payload.aps.sound, bundled in the Runner target.
      sound: 'airplane.caf',
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  void _handleMessageOpened(RemoteMessage message) {
    _logIncomingMessage('opened', message);
    // Доля открытий по типу пуша — единственный способ понять, какие
    // уведомления полезны, а какие люди просто смахивают.
    Telemetry.instance.event(TelemetryEvents.pushOpened, params: {
      TelemetryParams.source: message.data['type'] ?? 'unknown',
    });
    if (message.data.isNotEmpty) {
      handleNotificationNavigation(Map<String, dynamic>.from(message.data));
    }
  }

  /// Текущий статус системного разрешения — без показа диалога.
  Future<AuthorizationStatus> permissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Разрешение уже выдано (в том числе provisional на iOS).
  Future<bool> hasPermission() async {
    final status = await permissionStatus();
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  /// Показывает системный диалог разрешения (iOS и Android 13+).
  ///
  /// Сам токен НЕ отправляет — это делает вызывающая сторона через
  /// [syncToken], чтобы на холодном старте не уходило два запроса.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    _logger.d('Notification permission: ${settings.authorizationStatus}');
    // Доля отказов — прямой ограничитель для всей пуш-механики; без этой
    // цифры непонятно, почему падает доставка.
    Telemetry.instance.event(TelemetryEvents.pushPermissionResult, params: {
      TelemetryParams.result: settings.authorizationStatus.name,
    });
    Telemetry.instance.setUserProperties({
      TelemetryUserProps.pushEnabled: granted ? 'true' : 'false',
    });
    return granted;
  }

  /// Получить текущий FCM token (и сохранить в сервисе).
  Future<String?> refreshToken() async {
    await syncToken(reason: 'manual');
    return _fcmToken;
  }

  /// Берёт текущий токен и отправляет его на бэкенд.
  ///
  /// Вызывается на каждом холодном старте, после логина и регистрации, при
  /// onTokenRefresh и на возврате из фона (не чаще раза в сутки). Повторная
  /// отправка того же токена безопасна — на бэкенде updateOrCreate — и именно
  /// она двигает `updated_at`, по которому на сервере видно живые установки.
  Future<void> syncToken({required String reason}) async {
    try {
      if (Platform.isIOS) {
        await _waitForApnsToken();
      }
      final token = await _messaging.getToken();
      _fcmToken = token;
      _logger.d('FCM token ($reason): ${token != null ? "ok" : "null"}');
      if (token == null || token.isEmpty) return;
      await _sendToBackend(token, reason: reason);
    } catch (e, st) {
      _logger.e('FCM getToken error', e, st);
    }
  }

  Future<void> _sendToBackend(String token, {required String reason}) async {
    final send = _onTokenUpdated;
    if (send == null) return;
    try {
      await send(token);
      await _markSynced();
      _logger.d('FCM token sent to backend ($reason)');
    } catch (e) {
      _logger.d('FCM token send failed ($reason): $e');
    }
  }

  /// Выход из аккаунта: снимаем токен с устройства, чтобы следующий вход получил
  /// новый. Иначе два аккаунта на одном телефоне остаются привязаны к одному
  /// токену, и прежний владелец продолжает получать пуши на чужой телефон.
  Future<void> clearTokenAfterLogout() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      // iOS без APNs-токена здесь бросает — выход из аккаунта это не ломает.
      _logger.d('FCM deleteToken failed: $e');
    }
    _fcmToken = null;
    await _clearSyncMark();
  }

  Future<DateTime?> _lastSyncAt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt(_lastSyncKey);
      if (millis == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (_) {
      return null;
    }
  }

  Future<void> _markSynced() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // Метка — только оптимизация частоты. Не смогли сохранить — переотправим.
    }
  }

  Future<void> _clearSyncMark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncKey);
    } catch (_) {}
  }

  Future<void> _waitForApnsToken() async {
    const retries = 8;
    for (var i = 0; i < retries; i++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        _logger.d('APNs token: ok');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    _logger.w('APNs token: null (FCM token may be unavailable on iOS)');
  }
}
