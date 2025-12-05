# Инструкция: Добавить детальное логирование Pusher

## Найди файл где происходит инициализация Pusher

Ищи код похожий на:
```dart
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
```

## Замени код инициализации на этот (с логированием):

```dart
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PusherService {
  late PusherChannelsFlutter pusher;

  Future<void> initPusher() async {
    pusher = PusherChannelsFlutter.getInstance();

    try {
      await pusher.init(
        apiKey: 'YOUR_PUSHER_KEY',
        cluster: 'YOUR_CLUSTER',
        onEvent: (event) {
          print('📨 Pusher Event: ${event.eventName}');
          print('📦 Event Data: ${event.data}');
        },
        onSubscriptionSucceeded: (channelName, data) {
          print('✅ Subscription succeeded: $channelName');
          print('📊 Channel data: $data');
        },
        onSubscriptionError: (channelName, message, error) {
          print('❌ Subscription ERROR for channel: $channelName');
          print('❌ Error Message: $message');
          print('❌ Error Object: $error');

          // Полный объект ошибки
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
        // ВАЖНО! Кастомный authorizer для логирования
        onAuthorizer: (channelName, socketId, options) async {
          print('');
          print('🔐 ========== PUSHER AUTH REQUEST ==========');
          print('🔐 Channel: $channelName');
          print('🔐 Socket ID: $socketId');
          print('🔐 Options: $options');

          final authUrl = 'https://wawat.tahirguliyev.com/broadcasting/auth';

          // Получаем токен (замени на свой способ получения токена)
          final token = await getAuthToken(); // Твоя функция получения токена

          print('🔐 Auth URL: $authUrl');
          print('🔐 Token: $token');

          final response = await http.post(
            Uri.parse(authUrl),
            headers: {
              'Authorization': 'Bearer $token',
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
          print('📡 Headers: ${response.headers}');
          print('📡 Body (RAW): ${response.body}');

          try {
            final jsonResponse = jsonDecode(response.body);
            print('📡 Body (Parsed JSON):');
            print(JsonEncoder.withIndent('  ').convert(jsonResponse));

            // Проверяем наличие channel_data
            if (jsonResponse.containsKey('channel_data')) {
              print('⚠️  WARNING: channel_data found in response!');
              print('⚠️  channel_data value: ${jsonResponse['channel_data']}');
              print('⚠️  channel_data type: ${jsonResponse['channel_data'].runtimeType}');

              // Пытаемся распарсить channel_data
              try {
                if (jsonResponse['channel_data'] is String) {
                  final channelData = jsonDecode(jsonResponse['channel_data']);
                  print('⚠️  channel_data parsed: $channelData');
                } else {
                  print('⚠️  channel_data is not a string: ${jsonResponse['channel_data']}');
                }
              } catch (e) {
                print('❌ ERROR parsing channel_data: $e');
                print('❌ This is the cause of "channel_data is invalid JSON"!');
              }
            }

            if (jsonResponse.containsKey('auth')) {
              print('✅ Auth signature found: ${jsonResponse['auth']}');
            }

          } catch (e) {
            print('❌ ERROR parsing response body: $e');
          }

          print('========================================');
          print('');

          return response.body;
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

  Future<void> subscribeToConversation(int conversationId) async {
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

  // Твоя функция получения токена
  Future<String> getAuthToken() async {
    // Замени на свой способ получения токена
    // Например из secure storage
    return 'YOUR_TOKEN_HERE';
  }
}
```

## Использование:

```dart
final pusherService = PusherService();
await pusherService.initPusher();
await pusherService.subscribeToConversation(3);
```

## Что это даст:

После добавления этого кода, в консоли ты увидишь:

1. **Точный запрос к `/broadcasting/auth`** (headers, body)
2. **Полный ответ от бэкенда** (raw + parsed JSON)
3. **Наличие и содержимое `channel_data`** если он есть
4. **Точную ошибку** при парсинге
5. **Все события Pusher** с деталями

## Пришли бэкенду:

После запуска пришли бэкенду весь блок между:
```
🔐 ========== PUSHER AUTH REQUEST ==========
...
========================================
```

Это покажет **точно что возвращает бэкенд** и почему `channel_data is invalid JSON`.
