import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import 'notification_router.dart';

/// Background FCM handler — MUST be a top-level function, registered in main()
/// via FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler).
/// Runs in a separate isolate; do NOT import main.dart state here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
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

  // Новый id канала (v2) — чтобы применился кастомный звук: Android кэширует
  // настройки канала по id, поэтому смена звука требует НОВОГО id.
  static const _androidChannelId = 'wawat_alerts';
  static const _androidChannelName = 'Wawat Air';
  static const _androidSound =
      'airplane'; // android/app/src/main/res/raw/airplane.mp3

  /// FCM token для отправки на бэкенд (обновляется при refresh).
  String? get fcmToken => _fcmToken;
  String? _fcmToken;

  /// Инициализация: канал уведомлений, локальные уведомления, FCM handlers, запрос прав, токен.
  Future<void> initialize() async {
    await _initLocalNotifications();
    await _createAndroidChannel();
    _setForegroundPresentationOptions();
    // onBackgroundMessage is registered in main() before runApp() — do not register again here.

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
    final channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: 'Уведомления Wawat Air',
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound(_androidSound),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _setForegroundPresentationOptions() {
    _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    _logger.d('FCM foreground: ${message.messageId}');
    final notification = message.notification;
    if (notification == null) return;

    // On iOS, setForegroundNotificationPresentationOptions already handles
    // displaying the notification natively — using flutter_local_notifications
    // on top would cause duplicates. Only show local notification on Android.
    if (Platform.isAndroid) {
      final android = message.notification?.android;
      _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data.isEmpty ? null : jsonEncode(message.data),
        channelId: android?.channelId ?? _androidChannelId,
      );
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = _androidChannelId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: 'Уведомления Wawat Air',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_androidSound),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  void _handleMessageOpened(RemoteMessage message) {
    _logger.d('Notification opened: ${message.messageId}');
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
