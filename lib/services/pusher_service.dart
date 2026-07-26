import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';

typedef PusherMessageCallback = void Function(Map<String, dynamic> data);

class PusherService {
  static const _appKey = 'cbfef40b803a09357669';
  static const _host = 'api.wawatair.com';
  static const _authUrl = 'https://api.wawatair.com/api/broadcasting/auth';

  static final PusherService _instance = PusherService._internal();

  factory PusherService() => _instance;

  PusherService._internal();

  final Map<String, Set<PusherMessageCallback>> _conversationCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _typingCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _readCallbacks = {};
  final Map<String, Set<PusherMessageCallback>> _userCallbacks = {};
  final Set<String> _activeChannels = {};
  final Set<String> _subscribingChannels = {};

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  String? _authToken;
  String? _socketId;
  bool _isConnecting = false;
  bool _manuallyDisconnected = false;
  int _reconnectAttempt = 0;

  bool get isInitialized => _authToken != null;

  bool get isConnected =>
      _socket != null && _socketId != null && !_manuallyDisconnected;

  Uri get socketUri => Uri(
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
    if (_authToken != null && _authToken != token) {
      await _closeSocket();
      _activeChannels.clear();
      _subscribingChannels.clear();
    }

    _authToken = token;
    _manuallyDisconnected = false;
    await reconnect();
  }

  Future<void> reconnect() async {
    if (_authToken == null ||
        _authToken!.isEmpty ||
        _isConnecting ||
        isConnected) {
      return;
    }

    _reconnectTimer?.cancel();
    _isConnecting = true;
    final connected = Completer<void>();

    try {
      final uri = socketUri;
      _log('Connecting to $uri');
      final socket = await WebSocket.connect(
        uri.toString(),
        headers: const {'Origin': 'https://api.wawatair.com'},
      );
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
      _reconnectAttempt = 0;
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
          _activeChannels.add(channel);
          _log('Subscribed to $channel');
        }
        return;
      }

      if (eventName != 'message.sent' &&
          eventName != 'user.typing' &&
          eventName != 'message.read') {
        return;
      }
      final data = _decodeMap(envelope['data']);
      final conversationId = _conversationId(envelope, data);
      if (conversationId != null) {
        final source = switch (eventName) {
          'user.typing' => _typingCallbacks,
          'message.read' => _readCallbacks,
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

  /// Read-receipts ride the same `private-conversation.{id}` channel as
  /// messages and typing — subscribing here is a no-op when already joined.
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

  Future<void> _resubscribeAll() async {
    _activeChannels.clear();
    _subscribingChannels.clear();

    final conversationIds = <String>{
      ..._conversationCallbacks.keys,
      ..._typingCallbacks.keys,
      ..._readCallbacks.keys,
    };
    final channels = <String>[
      ...conversationIds.map(
        (id) => 'private-conversation.$id',
      ),
      ..._userCallbacks.keys.map((id) => 'private-user.$id'),
    ];
    for (final channel in channels) {
      await _subscribe(channel);
    }
  }

  Future<void> _subscribe(String channelName) async {
    if (_activeChannels.contains(channelName) ||
        _subscribingChannels.contains(channelName)) {
      return;
    }
    if (!isConnected) {
      await reconnect();
    }
    if (!isConnected) return;

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
    } catch (error, stackTrace) {
      _log(
        'Subscription failed for $channelName',
        error: error,
        stackTrace: stackTrace,
      );
      _subscribingChannels.remove(channelName);
    }
  }

  Future<void> _unsubscribe(String channelName) async {
    _activeChannels.remove(channelName);
    _subscribingChannels.remove(channelName);
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

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(_authUrl));
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token')
        ..set(HttpHeaders.acceptHeader, 'application/json')
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set('Accept-Language', _languageCode());
      request.write(jsonEncode({
        'socket_id': socketId,
        'channel_name': channelName,
      }));

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Broadcast auth failed (${response.statusCode}): $body',
          uri: Uri.parse(_authUrl),
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
    _socketId = null;
    _activeChannels.clear();
    _subscribingChannels.clear();
    unawaited(_closeSocket());
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_manuallyDisconnected || _authToken == null) return;
    _reconnectTimer?.cancel();
    _reconnectAttempt++;
    final seconds = _reconnectAttempt.clamp(1, 10);
    _reconnectTimer = Timer(
      Duration(seconds: seconds),
      () => unawaited(reconnect()),
    );
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
    _reconnectTimer?.cancel();
    _activeChannels.clear();
    _subscribingChannels.clear();
    _conversationCallbacks.clear();
    _typingCallbacks.clear();
    _readCallbacks.clear();
    _userCallbacks.clear();
    await _closeSocket();
  }

  bool _hasConversationCallbacks(String conversationId) {
    return _conversationCallbacks[conversationId]?.isNotEmpty == true ||
        _typingCallbacks[conversationId]?.isNotEmpty == true ||
        _readCallbacks[conversationId]?.isNotEmpty == true;
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
    final code = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (code == 'uk') return 'ua';
    const supported = {'az', 'en', 'ru', 'tr', 'ua'};
    return supported.contains(code) ? code : 'en';
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
    return const {};
  }
}
