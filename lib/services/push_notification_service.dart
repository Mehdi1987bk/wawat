import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
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

const _androidChannelId = 'wawat_airplane_v5';
const _legacyAndroidChannelIds = [
  'high_importance_channel',
  'wawat_high_importance',
  'wawat_alerts',
  'wawat_airplane_v2',
  'wawat_airplane_v3',
  'wawat_airplane_v4',
];
const _androidChannelName = 'Wawat Air';
const _androidChannelDescription = 'Уведомления Wawat Air';
const _androidSound = 'airplane';
const _androidSmallIcon = 'ic_stat_wawat';
const _androidLargeIcon = 'ic_notification_large';
const _brandColor = Color(0xFF007AFE);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _logIncomingMessage('background', message);

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

  for (final channelId in _legacyAndroidChannelIds) {
    await android.deleteNotificationChannel(channelId);
  }
}

class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;

  static const _lastSyncKey = 'push_token_last_sync_ms';

  static const _resyncInterval = Duration(hours: 24);

  static const _retryAfterFailure = Duration(minutes: 15);

  static const _openChatChannel = MethodChannel('az.buking.buking/open_chat');

  int _syncsInFlight = 0;
  DateTime? _lastSendFailedAt;

  static final _logger = Logger(printer: SimplePrinter());
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  String? get fcmToken => _fcmToken;
  String? _fcmToken;

  Future<void> initialize() async {
    await _initLocalNotifications();
    await _createAndroidChannel();
    await _setForegroundPresentationOptions();

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
    if (Platform.isIOS) {
      NotificationSocketService.instance.activeConversation
          .addListener(_syncOpenChat);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    if (Platform.isAndroid) {
      await requestPermission();
    }
    if (Platform.isAndroid || await hasPermission()) {
      unawaited(syncToken(reason: 'cold_start'));
    }

    WidgetsBinding.instance.addObserver(this);

    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _logger.d('FCM token refreshed');
      unawaited(_sendToBackend(token, reason: 'token_refresh'));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_syncOnResume());
  }

  Future<void> _syncOnResume() async {
    if (Platform.isIOS && !await hasPermission()) return;
    final lastSync = await _lastSyncAt();
    if (lastSync != null &&
        DateTime.now().difference(lastSync) < _resyncInterval) {
      return;
    }
    final failedAt = _lastSendFailedAt;
    if (failedAt != null &&
        DateTime.now().difference(failedAt) < _retryAfterFailure) {
      return;
    }
    if (_syncsInFlight > 0) return;
    await syncToken(reason: 'resume');
  }

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
    if (_isOpenChat(message.data)) return;

    _showInAppBanner(message, title: title, body: body);

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

  bool _isOpenChat(Map<String, dynamic> data) {
    final type = (data['target_type'] ?? data['type'] ?? '').toString().trim();
    if (type != 'conversation') return false;
    final convId = _firstNonEmpty([data['conversation_id'], data['target_id']]);
    return convId != null &&
        NotificationSocketService.instance.activeConversationId == convId;
  }

  void _syncOpenChat() {
    unawaited(_openChatChannel
        .invokeMethod<void>(
            'set', NotificationSocketService.instance.activeConversationId)
        .catchError((_) {}));
  }

  final AudioPlayer _foregroundSoundPlayer = AudioPlayer();

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
      presentAlert: false,
      presentBadge: true,
      presentSound: true,
      sound: 'airplane.caf',
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  void _handleMessageOpened(RemoteMessage message) {
    _logIncomingMessage('opened', message);
    Telemetry.instance.event(TelemetryEvents.pushOpened, params: {
      TelemetryParams.source: message.data['type'] ?? 'unknown',
    });
    if (message.data.isNotEmpty) {
      handleNotificationNavigation(Map<String, dynamic>.from(message.data));
    }
  }

  Future<AuthorizationStatus> permissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<bool> hasPermission() async {
    final status = await permissionStatus();
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

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
    Telemetry.instance.event(TelemetryEvents.pushPermissionResult, params: {
      TelemetryParams.result: settings.authorizationStatus.name,
    });
    Telemetry.instance.setUserProperties({
      TelemetryUserProps.pushEnabled: granted ? 'true' : 'false',
    });
    return granted;
  }

  Future<String?> refreshToken() async {
    await syncToken(reason: 'manual');
    return _fcmToken;
  }

  Future<void> syncToken({required String reason}) async {
    _syncsInFlight++;
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
    } finally {
      _syncsInFlight--;
    }
  }

  Future<void> _sendToBackend(String token, {required String reason}) async {
    final send = _onTokenUpdated;
    if (send == null) return;
    try {
      await send(token);
      _lastSendFailedAt = null;
      await _markSynced();
      _logger.d('FCM token sent to backend ($reason)');
    } catch (e) {
      _lastSendFailedAt = DateTime.now();
      _logger.d('FCM token send failed ($reason): $e');
    }
  }

  Future<void> clearTokenAfterLogout() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
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
