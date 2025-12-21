import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PusherService {
  // Singleton
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  late PusherChannelsFlutter pusher;
  String? _authToken;
  bool _isInitialized = false;

  // Отслеживаем подписанные каналы
  final Set<String> _subscribedChannels = {};

  // Callback для канала пользователя (список чатов)
  Function(dynamic)? _onUserChannelMessage;

  // Callbacks для каналов отдельных чатов
  final Map<int, Function(dynamic)> _conversationCallbacks = {};

  bool get isInitialized => _isInitialized;

  Future<void> initialize(String token) async {
    if (_isInitialized) {
      print('⚠️ Pusher already initialized, skipping');
      return;
    }

    _authToken = token;
    pusher = PusherChannelsFlutter.getInstance();

    try {
      await pusher.init(
        apiKey: 'b49808fed22eba5c789b',
        cluster: 'ap2',
        onEvent: _handleEvent,
        onSubscriptionSucceeded: (channelName, data) {
          print('✅ Subscribed to: $channelName');
          _subscribedChannels.add(channelName);
        },
        onSubscriptionError: (channelName, error) {
          print('❌ Subscription ERROR: $channelName - $error');
        },
        onConnectionStateChange: (currentState, previousState) {
          print('🔄 Pusher: $previousState -> $currentState');
        },
        onError: (message, code, error) {
          print('💥 Pusher Error: $message (code: $code)');
        },
        onAuthorizer: _handleAuth,
      );

      await pusher.connect();
      _isInitialized = true;
      print('✅ Pusher initialized successfully');
    } catch (e) {
      print('💥 Failed to initialize Pusher: $e');
    }
  }

  void _handleEvent(PusherEvent event) {
    print('📨 Event: ${event.eventName} on ${event.channelName}');
    print('📦 Data: ${event.data}');

    // Обрабатываем только message.sent
    if (event.eventName != 'message.sent') return;

    try {
      final data = jsonDecode(event.data ?? '{}');
      final conversationId = data['conversation_id'] as int?;

      // 1. Уведомляем канал пользователя (для списка чатов)
      if (_onUserChannelMessage != null) {
        print('📬 Notifying user channel callback');
        _onUserChannelMessage!(data);
      }

      // 2. Уведомляем канал конкретного чата (если открыт)
      if (conversationId != null && _conversationCallbacks.containsKey(conversationId)) {
        print('📬 Notifying conversation $conversationId callback');
        _conversationCallbacks[conversationId]!(data);
      }
    } catch (e) {
      print('❌ Error handling event: $e');
    }
  }

  Future<Map<String, dynamic>> _handleAuth(
      String channelName,
      String socketId,
      dynamic options,
      ) async {
    print('🔐 Auth for: $channelName');

    final response = await http.post(
      Uri.parse('http://62.84.176.158/api/v1/broadcasting/auth'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'socket_id': socketId,
        'channel_name': channelName,
      },
    );

    print('📡 Auth response: ${response.statusCode}');
    return jsonDecode(response.body);
  }

  /// Подписка на канал пользователя (для списка чатов)
  Future<void> subscribeToUserChannel(int userId, Function(dynamic) onMessage) async {
    final channelName = 'private-user.$userId';

    // Сохраняем callback в любом случае
    _onUserChannelMessage = onMessage;

    // Проверяем, не подписаны ли уже
    if (_subscribedChannels.contains(channelName)) {
      print('⚠️ Already subscribed to $channelName, updating callback only');
      return;
    }

    print('🔔 Subscribing to user channel: $channelName');

    try {
      await pusher.subscribe(channelName: channelName);
      print('✅ Subscribed to user channel');
    } catch (e) {
      print('❌ Failed to subscribe to user channel: $e');
      // Если ошибка "already subscribed", добавляем в Set
      if (e.toString().contains('Already subscribed')) {
        _subscribedChannels.add(channelName);
      }
    }
  }

  /// Подписка на канал чата (при открытии чата)
  Future<void> subscribeToConversation(int conversationId, Function(dynamic) onMessage) async {
    final channelName = 'private-conversation.$conversationId';

    // Сохраняем callback в любом случае
    _conversationCallbacks[conversationId] = onMessage;

    // Проверяем, не подписаны ли уже
    if (_subscribedChannels.contains(channelName)) {
      print('⚠️ Already subscribed to $channelName, updating callback only');
      return;
    }

    print('🔔 Subscribing to conversation: $channelName');

    try {
      await pusher.subscribe(channelName: channelName);
      print('✅ Subscribed to conversation $conversationId');
    } catch (e) {
      print('❌ Failed to subscribe to conversation: $e');
      // Если ошибка "already subscribed", добавляем в Set
      if (e.toString().contains('Already subscribed')) {
        _subscribedChannels.add(channelName);
      }
    }
  }

  /// Отписка от канала пользователя
  Future<void> unsubscribeFromUserChannel(int userId) async {
    final channelName = 'private-user.$userId';

    if (!_subscribedChannels.contains(channelName)) {
      print('⚠️ Not subscribed to $channelName');
      return;
    }

    try {
      await pusher.unsubscribe(channelName: channelName);
      _subscribedChannels.remove(channelName);
      _onUserChannelMessage = null;
      print('🔕 Unsubscribed from user channel');
    } catch (e) {
      print('❌ Failed to unsubscribe from user channel: $e');
    }
  }

  /// Отписка от канала чата (при закрытии чата)
  Future<void> unsubscribeFromConversation(int conversationId) async {
    final channelName = 'private-conversation.$conversationId';

    if (!_subscribedChannels.contains(channelName)) {
      print('⚠️ Not subscribed to $channelName');
      _conversationCallbacks.remove(conversationId);
      return;
    }

    try {
      await pusher.unsubscribe(channelName: channelName);
      _subscribedChannels.remove(channelName);
      _conversationCallbacks.remove(conversationId);
      print('🔕 Unsubscribed from conversation $conversationId');
    } catch (e) {
      print('❌ Failed to unsubscribe from conversation: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await pusher.disconnect();
    } catch (e) {
      print('❌ Error disconnecting: $e');
    }
    _isInitialized = false;
    _subscribedChannels.clear();
    _onUserChannelMessage = null;
    _conversationCallbacks.clear();
  }
}
