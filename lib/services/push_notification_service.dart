import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import '../firebase_options.dart';
import 'notification_router.dart';

// Android не позволяет менять звук уже созданного notification channel.
// Новый id гарантирует, что после обновления канал создастся именно с
// airplane.mp3, даже если старый канал был создан с default sound.
// Канал ТАКЖЕ создаётся нативно в WawatApplication.onCreate() — до того как
// FirebaseMessagingService успеет обработать пуш, — чтобы звук был правильным
// даже для notification-пушей, пришедших пока приложение убито. Держи этот id в
// синхроне с WawatApplication.kt и default_notification_channel_id в манифесте.
const _androidChannelId = 'wawat_airplane_v4';
const _legacyAndroidChannelIds = [
  'high_importance_channel',
  'wawat_high_importance',
  'wawat_alerts',
  'wawat_airplane_v2',
  'wawat_airplane_v3',
];
const _androidChannelName = 'Wawat Air';
const _androidChannelDescription = 'Уведомления Wawat Air';
const _androidSound = 'airplane';

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
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
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
  // to an old id falls back to the manifest default channel (wawat_airplane_v4),
  // which carries the airplane sound. The definitive fix is native creation in
  // WawatApplication.onCreate() (runs before FirebaseMessagingService); this is
  // the Flutter-side mirror of the same channel.
  for (final channelId in _legacyAndroidChannelIds) {
    await android.deleteNotificationChannel(channelId);
  }
}

/// Сервис Firebase Push Notifications: инициализация, права, показ в foreground,
/// обработка нажатий и получение FCM токена.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;

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

    await requestPermission();
    await _refreshToken();
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _logger.d('FCM token refreshed');
      _onTokenUpdated?.call(token);
    });
  }

  /// Вызывается при обновлении FCM токена — можно отправить токен на бэкенд.
  void Function(String token)? onTokenUpdated;
  void setOnTokenUpdated(void Function(String token)? callback) {
    _onTokenUpdated = callback;
  }

  void Function(String token)? _onTokenUpdated;

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
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
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    _logIncomingMessage('foreground', message);
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

    // On iOS, setForegroundNotificationPresentationOptions already handles
    // displaying the notification natively — using flutter_local_notifications
    // on top would cause duplicates for notification payloads. Data-only pushes
    // still need a local notification.
    if (Platform.isAndroid) {
      _showLocalNotification(
        id: message.hashCode,
        title: title ?? 'Wawat Air',
        body: body ?? '',
        payload: message.data.isEmpty ? null : jsonEncode(message.data),
      );
    } else if (Platform.isIOS && notification == null) {
      _showLocalNotification(
        id: message.hashCode,
        title: title ?? 'Wawat Air',
        body: body ?? '',
        payload: message.data.isEmpty ? null : jsonEncode(message.data),
      );
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
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'airplane.mp3',
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  void _handleMessageOpened(RemoteMessage message) {
    _logIncomingMessage('opened', message);
    if (message.data.isNotEmpty) {
      handleNotificationNavigation(Map<String, dynamic>.from(message.data));
    }
  }

  /// Запрос разрешения на уведомления (iOS и Android 13+).
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
    return granted;
  }

  /// Получить текущий FCM token (и сохранить в сервисе).
  Future<String?> refreshToken() async {
    await _refreshToken();
    return _fcmToken;
  }

  Future<void> _refreshToken() async {
    try {
      if (Platform.isIOS) {
        await _waitForApnsToken();
      }
      _fcmToken = await _messaging.getToken();
      _logger.d('FCM token: ${_fcmToken != null ? "ok" : "null"}');
      if (_fcmToken != null) _onTokenUpdated?.call(_fcmToken!);
    } catch (e, st) {
      _logger.e('FCM getToken error', e, st);
    }
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
