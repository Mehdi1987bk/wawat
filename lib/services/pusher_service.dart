import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? pusher;
  bool _isInitialized = false;

  Future<void> initialize(String authToken) async {
    if (_isInitialized) return;

    pusher = PusherChannelsFlutter.getInstance();

    try {
      await pusher!.init(
        apiKey: 'b49808fed22eba5c789b',
        cluster: 'ap2',
        onConnectionStateChange: (currentState, previousState) {
          print('Pusher: $previousState -> $currentState');
        },
        onError: (message, code, error) {
          print('Pusher error: $message');
        },
        onEvent: (event) {
          print('Pusher event: ${event.eventName}');
        },
        authEndpoint: 'https://wawat.tahirguliyev.com/api/v1/broadcasting/auth',
        onAuthorizer: (channelName, socketId, options) async {
          return {
            'auth': '',
            'channel_data': '',
            'shared_secret': '',
          };
        },
      );

      await pusher!.connect();
      _isInitialized = true;
      print('Pusher initialized successfully');
    } catch (e) {
      print('Pusher initialization error: $e');
    }
  }

  Future<void> subscribeToConversation(
      int conversationId,
      Function(dynamic) onNewMessage,
      ) async {
    if (!_isInitialized) {
      print('Pusher not initialized');
      return;
    }

    final channelName = 'private-conversation.$conversationId';

    try {
      await pusher!.subscribe(
        channelName: channelName,
        onEvent: (event) {
          if (event.eventName == 'message.sent') {
            try {
              final data = jsonDecode(event.data);
              onNewMessage(data);
            } catch (e) {
              print('Error parsing message: $e');
            }
          }
        },
      );
      print('Subscribed to $channelName');
    } catch (e) {
      print('Subscribe error: $e');
    }
  }

  Future<void> unsubscribe(String channelName) async {
    if (!_isInitialized) return;

    try {
      await pusher!.unsubscribe(channelName: channelName);
    } catch (e) {
      print('Unsubscribe error: $e');
    }
  }

  Future<void> disconnect() async {
    if (!_isInitialized) return;

    try {
      await pusher!.disconnect();
      _isInitialized = false;
    } catch (e) {
      print('Disconnect error: $e');
    }
  }
}
