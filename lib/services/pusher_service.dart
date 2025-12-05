import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PusherService {
  late PusherChannelsFlutter pusher;
  String? _authToken;
  Function(dynamic)? _onMessageCallback;

  Future<void> initialize(String token) async {
    _authToken = token;
    pusher = PusherChannelsFlutter.getInstance();

    try {
      await pusher.init(
        apiKey: 'b49808fed22eba5c789b',
        cluster: 'ap2',
        onEvent: (event) {
          print('📨 Pusher Event: ${event.eventName}');
          print('📦 Event Data: ${event.data}');

          // ИСПРАВЛЕНО: Добавлена проверка на 'message.sent'
          if (_onMessageCallback != null &&
              (event.eventName == 'message.sent' ||
                  event.eventName == 'new-message' ||
                  event.eventName == 'NewMessage' ||
                  event.eventName?.contains('NewMessage') == true ||
                  event.eventName?.contains('MessageSent') == true)) {
            try {
              final data = jsonDecode(event.data ?? '{}');
              print('✅ Processing message event: ${event.eventName}');
              _onMessageCallback!(data);
            } catch (e) {
              print('Error parsing message: $e');
            }
          }
        },
        onSubscriptionSucceeded: (channelName, data) {
          print('✅ Subscription succeeded: $channelName');
          print('📊 Channel data: $data');
        },
        onSubscriptionError: (channelName, error) {
          print('❌ Subscription ERROR for channel: $channelName');
          print('❌ Error Object: $error');

          if (error != null) {
            print('❌ Error Type: ${error.runtimeType}');
            print('❌ Error Details: ${error.toString()}');
          }
        },
        onConnectionStateChange: (currentState, previousState) {
          print('🔄 Pusher: $previousState -> $currentState');
        },
        onError: (message, code, error) {
          print('💥 Pusher General Error:');
          print('💥 Message: $message');
          print('💥 Code: $code');
          print('💥 Error: $error');
        },
        onAuthorizer: (String channelName, String socketId, dynamic options) async {
          print('');
          print('🔐 ========== PUSHER AUTH REQUEST ==========');
          print('🔐 Channel: $channelName');
          print('🔐 Socket ID: $socketId');
          print('🔐 Options: $options');

          final authUrl = 'https://wawat.tahirguliyev.com/api/v1/broadcasting/auth';

          print('🔐 Auth URL: $authUrl');
          print('🔐 Token: $_authToken');

          final response = await http.post(
            Uri.parse(authUrl),
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

          print('');
          print('📡 ========== BACKEND RESPONSE ==========');
          print('📡 Status Code: ${response.statusCode}');
          print('📡 Body (RAW): ${response.body}');

          final jsonResponse = jsonDecode(response.body);

          print('✅ Auth signature found: ${jsonResponse['auth']}');
          print('========================================');
          print('');

          return jsonResponse;
        },
      );

      await pusher.connect();
      print('Pusher initialized successfully');
    } catch (e, stackTrace) {
      print('💥 FATAL ERROR initializing Pusher:');
      print('💥 Error: $e');
      print('💥 StackTrace: $stackTrace');
    }
  }

  Future<void> subscribeToConversation(
      int conversationId,
      Function(dynamic) onNewMessage,
      ) async {
    _onMessageCallback = onNewMessage;

    try {
      final channelName = 'private-conversation.$conversationId';
      print('');
      print('🔔 Subscribing to channel: $channelName');

      final channel = await pusher.subscribe(
        channelName: channelName,
      );

      print('✅ Subscribe method completed for: $channelName');
    } catch (e, stackTrace) {
      print('💥 ERROR subscribing to channel:');
      print('💥 Error: $e');
      print('💥 StackTrace: $stackTrace');
    }
  }

  Future<void> unsubscribe(String channelName) async {
    await pusher.unsubscribe(channelName: channelName);
    _onMessageCallback = null;
  }

  Future<void> disconnect() async {
    await pusher.disconnect();
  }
}
