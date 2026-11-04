import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'localization_service.dart';
import 'network_failure.dart';
import 'network_status_service.dart';

typedef PusherMessageCallback = void Function(Map<String, dynamic> data);

class PusherService {
  static const _appKey = 'cbfef40b803a09357669';
  static const _host = 'api.wawatair.com';
  static const _authUrl = 'https://api.wawatair.com/api/broadcasting/auth';

  static final PusherService _instance = PusherService._internal();

  factory PusherService() => _instance;

  PusherService._internal({
    Uri? socketUri,
    Uri? authUri,
    Duration authRetryPause = const Duration(seconds: 5),
  })  : _socketUriOverride = socketUri,
        _authUri = authUri ?? Uri.parse(_authUrl),
        _authRetryPause = authRetryPause;

  @visibleForTesting
  factory PusherService.forTest({
    required Uri socketUri,
    required Uri authUri,
    Duration authRetryPause = const Duration(seconds: 5),
  }) =>
      PusherService._internal(
        socketUri: socketUri,
        authUri: authUri,
        authRetryPause: authRetryPause,
      );

  final Uri? _socketUriOverride;
  final Uri _authUri;

  static const _stableConnection = Duration(seconds: 30);

  static const _authRateLimitPause = Duration(minutes: 1);

  static const _connectTimeout = Duration(seconds: 10);

  static const _upgradeTimeout = Duration(seconds: 15);
  static const _authTimeout = Duration(seconds: 15);

  final Duration _authRetryPause;

  static const _authRetryLimit = 3;

  final Map<String, Set<PusherMessageCallback>> _conversationCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _typingCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _readCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _deletedCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _userCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _notificationCallbacks = {};
  final Set<String> _activeChannels = {};
  final Set<String> _subscribingChannels = {};
  final Map<String, DateTime> _authFailedAt = {};
  final Map<String, int> _authFailures = {};
  final Map<String, Timer> _authRetryTimers = {};

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  Timer? _resubscribeTimer;
  String? _authToken;
  String? _socketId;
  bool _isConnecting = false;
  bool _manuallyDisconnected = false;
  int _reconnectAttempt = 0;
  DateTime? _connectedAt;
  DateTime? _authBlockedUntil;
  bool _watchingNetwork = false;
  final _random = Random();

  bool get isInitialized => _authToken != null;

  bool get isConnected =>
      _socket != null && _socketId != null && !_manuallyDisconnected;

  Uri get socketUri =>
      _socketUriOverride ??
      Uri(
        scheme: 'wss',
        host: _host,
        port: 443,
        path: '/app/$_appKey',
        queryParameters: const {
          'protocol': '7',
          'client': 'wawatair-flutter',
          'version': '1.0',
          'flash': 'false',
        },
      );

  Future<void> initialize(String token) async {
    final changed = _authToken != null && _authToken != token;
    if (changed) {
      await _closeSocket();
      _activeChannels.clear();
      _subscribingChannels.clear();
      _forgetAuthFailures();
      _reconnectAttempt = 0;
    }

    _authToken = token;
    _manuallyDisconnected = false;
    _watchNetwork();
    await reconnect(force: changed);
  }

  void _watchNetwork() {
    if (_watchingNetwork || _socketUriOverride != null) return;
    _watchingNetwork = true;
    NetworkStatusService.instance.addListener(_onNetworkChanged);
  }

  void _onNetworkChanged() {
    if (NetworkStatusService.instance.isOffline) return;
    if (isConnected || _isConnecting) return;
    _reconnectTimer?.cancel();
    _reconnectAttempt = 0;
    _scheduleReconnect();
  }

  Future<void> reconnect({bool force = false}) async {
    if (_authToken == null ||
        _authToken!.isEmpty ||
        _isConnecting ||
        isConnected) {
      return;
    }
    if (!force && (_reconnectTimer?.isActive ?? false)) return;

    _reconnectTimer?.cancel();
    _isConnecting = true;
    final connected = Completer<void>();

    try {
      final uri = socketUri;
      _log('Connecting to $uri');
      final client = HttpClient()..connectionTimeout = _connectTimeout;
      final pending = WebSocket.connect(
        uri.toString(),
        headers: const {'Origin': 'https://api.wawatair.com'},
        customClient: client,
      );
      final WebSocket socket;
      try {
        socket = await pending.timeout(_upgradeTimeout);
      } on TimeoutException {
        client.close(force: true);
        unawaited(pending.then<void>(
          (orphan) => orphan.close(),
          onError: (Object _) {},
        ));
        rethrow;
      }
      if (_manuallyDisconnected) {
        unawaited(socket.close().catchError((_) {}));
        return;
      }
      socket.pingInterval = const Duration(seconds: 20);
      _socket = socket;
      _socketSubscription = socket.listen(
        (event) => _handleSocketEvent(event, connected),
        onError: (Object error, StackTrace stackTrace) {
          if (!connected.isCompleted) {
            connected.completeError(error, stackTrace);
          }
          _handleDisconnect();
        },
        onDone: () {
          if (!connected.isCompleted) {
            connected.completeError(
              const SocketException('WebSocket closed before handshake'),
            );
          }
          _handleDisconnect();
        },
        cancelOnError: true,
      );

      await connected.future.timeout(const Duration(seconds: 12));
      _connectedAt = DateTime.now();
      _log('Connected');
    } catch (error, stackTrace) {
      _log('Connection failed', error: error, stackTrace: stackTrace);
      await _closeSocket();
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _handleSocketEvent(dynamic rawEvent, Completer<void> connected) {
    try {
      final envelope = _decodeMap(rawEvent);
      final eventName = envelope['event']?.toString();

      if (eventName == 'pusher:error') {
        _log(
          'Server error',
          error: _decodeMap(envelope['data']),
        );
        return;
      }

      if (eventName == 'pusher:connection_established') {
        final data = _decodeMap(envelope['data']);
        _socketId = data['socket_id']?.toString();
        if (_socketId == null || _socketId!.isEmpty) {
          throw const FormatException('Missing Reverb socket id');
        }
        _log('Handshake succeeded');
        if (!connected.isCompleted) connected.complete();
        unawaited(_resubscribeAll());
        return;
      }

      if (eventName == 'pusher:ping') {
        _send({'event': 'pusher:pong', 'data': const {}});
        return;
      }

      if (eventName == 'pusher_internal:subscription_succeeded' ||
          eventName == 'pusher:subscription_succeeded') {
        final channel = envelope['channel']?.toString();
        if (channel != null) {
          _subscribingChannels.remove(channel);
          _forgetAuthFailures(channel);
          _activeChannels.add(channel);
          _log('Subscribed to $channel');
        }
        return;
      }

      if (eventName == 'new_message_notification' ||
          eventName == 'new_notification') {
        final channel = envelope['channel']?.toString();
        const prefix = 'private-notifications.';
        if (channel != null && channel.startsWith(prefix)) {
          final publicId = channel.substring(prefix.length);
          final data = _decodeMap(envelope['data']);
          data['_event'] = eventName;
          final callbacks = List<PusherMessageCallback>.from(
            _notificationCallbacks[publicId] ?? const {},
          );
          for (final callback in callbacks) {
            callback(data);
          }
        }
        return;
      }

      if (eventName != 'message.sent' &&
          eventName != 'user.typing' &&
          eventName != 'message.read' &&
          eventName != 'message.deleted') {
        return;
      }
      final data = _decodeMap(envelope['data']);
      final conversationId = _conversationId(envelope, data);
      if (conversationId != null) {
        final source = switch (eventName) {
          'user.typing' => _typingCallbacks,
          'message.read' => _readCallbacks,
          'message.deleted' => _deletedCallbacks,
          _ => _conversationCallbacks,
        };
        final callbacks = List<PusherMessageCallback>.from(
          source[conversationId] ?? const {},
        );
        for (final callback in callbacks) {
          callback(data);
        }
      }

      if (eventName != 'message.sent') return;
      final channel = envelope['channel']?.toString();
      if (channel != null && channel.startsWith('private-user.')) {
        final userId = channel.substring('private-user.'.length);
        final callbacks = List<PusherMessageCallback>.from(
          _userCallbacks[userId] ?? const {},
        );
        for (final callback in callbacks) {
          callback(data);
        }
      }
    } catch (error, stackTrace) {
      _log(
        'Failed to handle socket event',
        error: error,
        stackTrace: stackTrace,
      );
      if (!connected.isCompleted) {
        connected.completeError(error, stackTrace);
      }
    }
  }

  Future<void> subscribeToConversation(
    String conversationId,
    PusherMessageCallback onMessage,
  ) async {
    _conversationCallbacks
        .putIfAbsent(conversationId, () => <PusherMessageCallback>{})
        .add(onMessage);
    await _subscribe('private-conversation.$conversationId');
  }

  Future<void> unsubscribeFromConversation(
    String conversationId, [
    PusherMessageCallback? onMessage,
  ]) async {
    final callbacks = _conversationCallbacks[conversationId];
    if (onMessage == null) {
      callbacks?.clear();
    } else {
      callbacks?.remove(onMessage);
    }
    if (callbacks?.isEmpty != false) {
      _conversationCallbacks.remove(conversationId);
    }
    if (_hasConversationCallbacks(conversationId)) return;
    await _unsubscribe('private-conversation.$conversationId');
  }

  Future<void> subscribeToConversationTyping(
    String conversationId,
    PusherMessageCallback onTyping,
  ) async {
    _typingCallbacks
        .putIfAbsent(conversationId, () => <PusherMessageCallback>{})
        .add(onTyping);
    await _subscribe('private-conversation.$conversationId');
  }

  Future<void> unsubscribeFromConversationTyping(
    String conversationId, [
    PusherMessageCallback? onTyping,
  ]) async {
    final callbacks = _typingCallbacks[conversationId];
    if (onTyping == null) {
      callbacks?.clear();
    } else {
      callbacks?.remove(onTyping);
    }
    if (callbacks?.isEmpty != false) {
      _typingCallbacks.remove(conversationId);
    }
    if (_hasConversationCallbacks(conversationId)) return;
    await _unsubscribe('private-conversation.$conversationId');
  }

  Future<void> subscribeToConversationRead(
    String conversationId,
    PusherMessageCallback onRead,
  ) async {
    _readCallbacks
        .putIfAbsent(conversationId, () => <PusherMessageCallback>{})
        .add(onRead);
    await _subscribe('private-conversation.$conversationId');
  }

  Future<void> unsubscribeFromConversationRead(
    String conversationId, [
    PusherMessageCallback? onRead,
  ]) async {
    final callbacks = _readCallbacks[conversationId];
    if (onRead == null) {
      callbacks?.clear();
    } else {
      callbacks?.remove(onRead);
    }
    if (callbacks?.isEmpty != false) {
      _readCallbacks.remove(conversationId);
    }
    if (_hasConversationCallbacks(conversationId)) return;
    await _unsubscribe('private-conversation.$conversationId');
  }

  Future<void> subscribeToConversationDeleted(
    String conversationId,
    PusherMessageCallback onDeleted,
  ) async {
    _deletedCallbacks
        .putIfAbsent(conversationId, () => <PusherMessageCallback>{})
        .add(onDeleted);
    await _subscribe('private-conversation.$conversationId');
  }

  Future<void> unsubscribeFromConversationDeleted(
    String conversationId, [
    PusherMessageCallback? onDeleted,
  ]) async {
    final callbacks = _deletedCallbacks[conversationId];
    if (onDeleted == null) {
      callbacks?.clear();
    } else {
      callbacks?.remove(onDeleted);
    }
    if (callbacks?.isEmpty != false) {
      _deletedCallbacks.remove(conversationId);
    }
    if (_hasConversationCallbacks(conversationId)) return;
    await _unsubscribe('private-conversation.$conversationId');
  }

  Future<void> subscribeToUserChannel(
    int userId,
    PusherMessageCallback onMessage,
  ) async {
    final key = '$userId';
    _userCallbacks
        .putIfAbsent(key, () => <PusherMessageCallback>{})
        .add(onMessage);
    await _subscribe('private-user.$userId');
  }

  Future<void> unsubscribeFromUserChannel(
    int userId, [
    PusherMessageCallback? onMessage,
  ]) async {
    final key = '$userId';
    final callbacks = _userCallbacks[key];
    if (onMessage == null) {
      callbacks?.clear();
    } else {
      callbacks?.remove(onMessage);
    }
    if (callbacks?.isNotEmpty == true) return;

    _userCallbacks.remove(key);
    await _unsubscribe('private-user.$userId');
  }

  Future<void> subscribeToNotifications(
    String publicId,
    PusherMessageCallback onNotification,
  ) async {
    _notificationCallbacks
        .putIfAbsent(publicId, () => <PusherMessageCallback>{})
        .add(onNotification);
    await _subscribe('private-notifications.$publicId');
  }

  Future<void> unsubscribeFromNotifications(
    String publicId, [
    PusherMessageCallback? onNotification,
  ]) async {
    final callbacks = _notificationCallbacks[publicId];
    if (onNotification == null) {
      callbacks?.clear();
    } else {
      callbacks?.remove(onNotification);
    }
    if (callbacks?.isNotEmpty == true) return;
    _notificationCallbacks.remove(publicId);
    await _unsubscribe('private-notifications.$publicId');
  }

  Future<void> _resubscribeAll() async {
    _activeChannels.clear();
    _subscribingChannels.clear();
    _forgetAuthFailures();
    await _subscribeWanted();
  }

  Future<void> _subscribeWanted() async {
    final conversationIds = <String>{
      ..._conversationCallbacks.keys,
      ..._typingCallbacks.keys,
      ..._readCallbacks.keys,
      ..._deletedCallbacks.keys,
    };
    final channels = <String>[
      ...conversationIds.map(
        (id) => 'private-conversation.$id',
      ),
      ..._userCallbacks.keys.map((id) => 'private-user.$id'),
      ..._notificationCallbacks.keys.map((id) => 'private-notifications.$id'),
    ];
    for (final channel in channels) {
      if (!isConnected || _authPaused) break;
      await _subscribe(channel);
    }
  }

  bool get _authPaused {
    final until = _authBlockedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  void _pauseSubscriptions(Duration pause) {
    _authBlockedUntil = DateTime.now().add(pause);
    _resubscribeTimer?.cancel();
    _resubscribeTimer = Timer(pause, () {
      _authBlockedUntil = null;
      unawaited(_subscribeWanted());
    });
  }

  Future<void> _subscribe(String channelName) async {
    if (_activeChannels.contains(channelName) ||
        _subscribingChannels.contains(channelName)) {
      return;
    }
    if (!isConnected || _authPaused) return;
    final failedAt = _authFailedAt[channelName];
    if (failedAt != null &&
        DateTime.now().difference(failedAt) < _authRetryPause) {
      return;
    }

    _subscribingChannels.add(channelName);
    try {
      final auth = await _authorize(channelName);
      _send({
        'event': 'pusher:subscribe',
        'data': {
          'auth': auth['auth'],
          'channel': channelName,
          if (auth['channel_data'] != null)
            'channel_data': auth['channel_data'],
        },
      });
    } on _AuthRateLimited catch (limit) {
      _log('Channel auth rate limited for ${limit.pause.inSeconds}s');
      _subscribingChannels.remove(channelName);
      _pauseSubscriptions(limit.pause);
    } catch (error, stackTrace) {
      _log(
        'Subscription failed for $channelName',
        error: error,
        stackTrace: stackTrace,
      );
      _subscribingChannels.remove(channelName);
      _authFailedAt[channelName] = DateTime.now();
      _scheduleAuthRetry(channelName);
    }
  }

  void _scheduleAuthRetry(String channelName) {
    final failures = (_authFailures[channelName] ?? 0) + 1;
    _authFailures[channelName] = failures;
    if (failures > _authRetryLimit) return;
    _authRetryTimers[channelName]?.cancel();
    _authRetryTimers[channelName] = Timer(
      _authRetryPause * (1 << (failures - 1)),
      () {
        _authRetryTimers.remove(channelName);
        _authFailedAt.remove(channelName);
        unawaited(_subscribeWanted());
      },
    );
  }

  void _forgetAuthFailures([String? channelName]) {
    if (channelName != null) {
      _authRetryTimers.remove(channelName)?.cancel();
      _authFailures.remove(channelName);
      _authFailedAt.remove(channelName);
      return;
    }
    for (final timer in _authRetryTimers.values) {
      timer.cancel();
    }
    _authRetryTimers.clear();
    _authFailures.clear();
    _authFailedAt.clear();
  }

  Future<void> _unsubscribe(String channelName) async {
    _activeChannels.remove(channelName);
    _subscribingChannels.remove(channelName);
    _forgetAuthFailures(channelName);
    if (!isConnected) return;
    _send({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channelName},
    });
  }

  Future<Map<String, dynamic>> _authorize(String channelName) async {
    final socketId = _socketId;
    final token = _authToken;
    if (socketId == null || token == null) {
      throw StateError('Reverb is not connected');
    }

    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.postUrl(_authUri);
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token')
        ..set(HttpHeaders.acceptHeader, 'application/json')
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set('Accept-Language', _languageCode());
      request.write(jsonEncode({
        'socket_id': socketId,
        'channel_name': channelName,
      }));

      final response = await request.close().timeout(_authTimeout);
      final body =
          await utf8.decoder.bind(response).join().timeout(_authTimeout);
      if (response.statusCode == 429) {
        throw _AuthRateLimited(
          NetworkFailure.retryAfter(
                response.headers['retry-after']?.firstOrNull,
                DateTime.now(),
              ) ??
              _authRateLimitPause,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Broadcast auth failed (${response.statusCode}): $body',
          uri: _authUri,
        );
      }
      return _decodeMap(body);
    } finally {
      client.close(force: true);
    }
  }

  void _send(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null) return;
    socket.add(jsonEncode(payload));
  }

  void _handleDisconnect() {
    _log('Disconnected');
    final connectedAt = _connectedAt;
    _connectedAt = null;
    if (connectedAt != null &&
        DateTime.now().difference(connectedAt) >= _stableConnection) {
      _reconnectAttempt = 0;
    }
    _socketId = null;
    _activeChannels.clear();
    _subscribingChannels.clear();
    _forgetAuthFailures();
    unawaited(_closeSocket());
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_manuallyDisconnected || _authToken == null) return;
    if (_reconnectTimer?.isActive ?? false) return;
    _reconnectAttempt++;
    _reconnectTimer = Timer(
      reconnectDelay(_reconnectAttempt, _random.nextDouble()),
      () => unawaited(reconnect()),
    );
  }

  @visibleForTesting
  static Duration reconnectDelay(int attempt, double spread) {
    final step = (attempt - 1).clamp(0, 5);
    final seconds = min(1 << step, 30);
    final factor = 0.7 + spread * 0.6;
    return Duration(milliseconds: (seconds * 1000 * factor).round());
  }

  Future<void> _closeSocket() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    final socket = _socket;
    _socket = null;
    _socketId = null;
    if (socket != null) {
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _authToken = null;
    _reconnectTimer?.cancel();
    _resubscribeTimer?.cancel();
    _authBlockedUntil = null;
    _reconnectAttempt = 0;
    _connectedAt = null;
    _activeChannels.clear();
    _subscribingChannels.clear();
    _forgetAuthFailures();
    _conversationCallbacks.clear();
    _typingCallbacks.clear();
    _readCallbacks.clear();
    _deletedCallbacks.clear();
    _userCallbacks.clear();
    _notificationCallbacks.clear();
    await _closeSocket();
  }

  bool _hasConversationCallbacks(String conversationId) {
    return _conversationCallbacks[conversationId]?.isNotEmpty == true ||
        _typingCallbacks[conversationId]?.isNotEmpty == true ||
        _readCallbacks[conversationId]?.isNotEmpty == true ||
        _deletedCallbacks[conversationId]?.isNotEmpty == true;
  }

  String? _conversationId(
    Map<String, dynamic> envelope,
    Map<String, dynamic> data,
  ) {
    final value = data['conversation_id']?.toString();
    if (value != null && value.isNotEmpty) return value;
    final channel = envelope['channel']?.toString();
    const prefix = 'private-conversation.';
    if (channel != null && channel.startsWith(prefix)) {
      return channel.substring(prefix.length);
    }
    return null;
  }

  String _languageCode() {
    final code = LocalizationService.instance.locale;
    const supported = {'az', 'en', 'ru', 'tr', 'ua', 'es'};
    return supported.contains(code) ? code : 'az';
  }

  void _log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'Wawatair.Reverb',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Map<String, dynamic> _decodeMap(dynamic value) {
    final decoded = value is String ? jsonDecode(value) : value;
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
  }
}

class _AuthRateLimited implements Exception {
  const _AuthRateLimited(this.pause);

  final Duration pause;
}
