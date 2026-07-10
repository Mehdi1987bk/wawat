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

  final Set<String> _subscribedChannels = {};

  Function(dynamic)? _onUserChannelMessage;

  final Map<String, Function(dynamic)> _conversationCallbacks = {};

  bool get isInitialized => _isInitialized;

  Future<void> initialize(String token) async {
    if (_isInitialized) {
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
          _subscribedChannels.add(channelName);
        },
        onSubscriptionError: (channelName, error) {},
        onConnectionStateChange: (currentState, previousState) {},
        onError: (message, code, error) {},
        onAuthorizer: _handleAuth,
      );

      await pusher.connect();
      _isInitialized = true;
    } catch (e) {}
  }

  void _handleEvent(PusherEvent event) {
    if (event.eventName != 'message.sent') return;

    try {
      final data = jsonDecode(event.data ?? '{}');
      final conversationId = data['conversation_id']?.toString();

      if (_onUserChannelMessage != null) {
        _onUserChannelMessage!(data);
      }

      if (conversationId != null &&
          _conversationCallbacks.containsKey(conversationId)) {
        _conversationCallbacks[conversationId]!(data);
      }
    } catch (e) {}
  }

  Future<Map<String, dynamic>> _handleAuth(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    print('🔐 Auth for: $channelName');

    final response = await http.post(
      Uri.parse('https://api.wawatair.com/api/broadcasting/auth'),
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

    return jsonDecode(response.body);
  }

  Future<void> subscribeToUserChannel(
      int userId, Function(dynamic) onMessage) async {
    final channelName = 'private-user.$userId';

    _onUserChannelMessage = onMessage;

    if (_subscribedChannels.contains(channelName)) {
      return;
    }

    try {
      await pusher.subscribe(channelName: channelName);
    } catch (e) {
      if (e.toString().contains('Already subscribed')) {
        _subscribedChannels.add(channelName);
      }
    }
  }

  Future<void> subscribeToConversation(
      String conversationId, Function(dynamic) onMessage) async {
    final channelName = 'private-conversation.$conversationId';

    _conversationCallbacks[conversationId] = onMessage;

    if (_subscribedChannels.contains(channelName)) {
      return;
    }

    try {
      await pusher.subscribe(channelName: channelName);
    } catch (e) {
      if (e.toString().contains('Already subscribed')) {
        _subscribedChannels.add(channelName);
      }
    }
  }

  Future<void> unsubscribeFromUserChannel(int userId) async {
    final channelName = 'private-user.$userId';

    if (!_subscribedChannels.contains(channelName)) {
      return;
    }

    try {
      await pusher.unsubscribe(channelName: channelName);
      _subscribedChannels.remove(channelName);
      _onUserChannelMessage = null;
    } catch (e) {}
  }

  Future<void> unsubscribeFromConversation(String conversationId) async {
    final channelName = 'private-conversation.$conversationId';

    if (!_subscribedChannels.contains(channelName)) {
      _conversationCallbacks.remove(conversationId);
      return;
    }

    try {
      await pusher.unsubscribe(channelName: channelName);
      _subscribedChannels.remove(channelName);
      _conversationCallbacks.remove(conversationId);
    } catch (e) {}
  }

  Future<void> disconnect() async {
    try {
      await pusher.disconnect();
    } catch (e) {}
    _isInitialized = false;
    _subscribedChannels.clear();
    _onUserChannelMessage = null;
    _conversationCallbacks.clear();
  }
}
