import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:buking/services/pusher_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReverb {
  late final HttpServer _server;

  bool accepting = true;

  List<int> authAnswers = [200];
  String? retryAfter;

  bool retryAfterTwice = false;

  int connects = 0;
  final authorized = <String>[];

  final authTokens = <String?>[];
  final subscribed = <String>[];
  final _sockets = <WebSocket>[];

  int get openClients =>
      _sockets.where((socket) => socket.readyState == WebSocket.open).length;

  Uri get socketUri => Uri.parse('ws://127.0.0.1:${_server.port}/app/key');
  Uri get authUri => Uri.parse('http://127.0.0.1:${_server.port}/auth');

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_handle);
  }

  Future<void> _handle(HttpRequest request) async {
    if (request.uri.path == '/auth') {
      final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
      authorized.add(body['channel_name'].toString());
      authTokens.add(request.headers.value(HttpHeaders.authorizationHeader));
      final code = authAnswers[authorized.length <= authAnswers.length
          ? authorized.length - 1
          : authAnswers.length - 1];
      request.response.statusCode = code;
      if (code == 429 && retryAfter != null) {
        request.response.headers.set('retry-after', retryAfter!);
        if (retryAfterTwice) {
          request.response.headers.add('retry-after', retryAfter!);
        }
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(
          code == 200 ? {'auth': 'key:signature'} : {'message': 'no'}));
      await request.response.close();
      return;
    }

    connects++;
    if (!accepting) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    _sockets.add(socket);
    socket.add(jsonEncode({
      'event': 'pusher:connection_established',
      'data': jsonEncode({'socket_id': '1.${connects}', 'activity_timeout': 30}),
    }));
    socket.listen((raw) {
      final message = jsonDecode(raw as String) as Map;
      if (message['event'] != 'pusher:subscribe') return;
      final channel = (message['data'] as Map)['channel'].toString();
      subscribed.add(channel);
      socket.add(jsonEncode({
        'event': 'pusher_internal:subscription_succeeded',
        'channel': channel,
        'data': '{}',
      }));
    });
  }

  void push(String event, String channel, Map<String, dynamic> data) {
    for (final socket in _sockets) {
      if (socket.readyState != WebSocket.open) continue;
      socket.add(jsonEncode({
        'event': event,
        'channel': channel,
        'data': jsonEncode(data),
      }));
    }
  }

  Future<void> dropClients() async {
    for (final socket in _sockets) {
      await socket.close();
    }
    _sockets.clear();
  }

  Future<void> stop() async {
    await dropClients();
    await _server.close(force: true);
  }
}

Future<void> _settle([int ms = 150]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

Future<void> _until(bool Function() done, {int ms = 6000}) async {
  final deadline = DateTime.now().add(Duration(milliseconds: ms));
  while (!done() && DateTime.now().isBefore(deadline)) {
    await _settle(40);
  }
}

void main() {
  late _FakeReverb reverb;
  late PusherService pusher;

  setUp(() async {
    reverb = _FakeReverb();
    await reverb.start();
    pusher = PusherService.forTest(
      socketUri: reverb.socketUri,
      authUri: reverb.authUri,
    );
  });

  tearDown(() async {
    await pusher.disconnect();
    await reverb.stop();
  });

  group('пауза между попытками подключения', () {
    test('растёт: 1, 2, 4, 8, 16 и дальше по 30 секунд', () {
      Duration at(int attempt) => PusherService.reconnectDelay(attempt, 0.5);

      expect(
        [for (var n = 1; n <= 8; n++) at(n).inSeconds],
        [1, 2, 4, 8, 16, 30, 30, 30],
      );
    });

    test('разброс ±30%, и без паузы не бывает никогда', () {
      expect(PusherService.reconnectDelay(1, 0),
          const Duration(milliseconds: 700));
      expect(PusherService.reconnectDelay(1, 1),
          const Duration(milliseconds: 1300));
      expect(PusherService.reconnectDelay(6, 1), const Duration(seconds: 39));
      expect(PusherService.reconnectDelay(0, 0), greaterThan(Duration.zero));
    });
  });

  group('сервер лежит', () {
    test('полсотни подписок не делают полсотни попыток подключения',
        () async {
      reverb.accepting = false;

      await pusher.initialize('token');
      for (var id = 0; id < 50; id++) {
        await pusher.subscribeToConversation('$id', (_) {});
      }
      await pusher.subscribeToUserChannel(7, (_) {});

      expect(reverb.connects, 1);
      expect(reverb.authorized, isEmpty);
    });

    test('экраны и таймеры, зовущие initialize(), не опережают паузу',
        () async {
      reverb.accepting = false;

      for (var i = 0; i < 20; i++) {
        await pusher.initialize('token');
      }

      expect(reverb.connects, 1);
    });

    test('следующая попытка приходит сама, после паузы', () async {
      reverb.accepting = false;
      await pusher.initialize('token');
      expect(reverb.connects, 1);

      await _settle(500);
      expect(reverb.connects, 1, reason: 'раньше 0,7 с повторять нельзя');

      await _until(() => reverb.connects >= 2);
      expect(reverb.connects, 2);
    });

    test('сервер поднялся — подписки, запрошенные без связи, не потеряны',
        () async {
      reverb.accepting = false;
      await pusher.initialize('token');
      await pusher.subscribeToConversation('42', (_) {});
      await pusher.subscribeToUserChannel(7, (_) {});

      reverb.accepting = true;
      await _until(() => reverb.subscribed.length >= 2);

      expect(pusher.isConnected, isTrue);
      expect(reverb.subscribed,
          unorderedEquals(['private-conversation.42', 'private-user.7']));
    });
  });

  group('соединение есть', () {
    test('подписка уходит сразу, одна авторизация на канал', () async {
      await pusher.initialize('token');
      await pusher.subscribeToConversation('42', (_) {});
      await pusher.subscribeToConversation('42', (_) {});
      await _settle();

      expect(reverb.connects, 1);
      expect(reverb.authorized, ['private-conversation.42']);
      expect(reverb.subscribed, ['private-conversation.42']);
    });

    test('другой пользователь — новое соединение сразу, без паузы', () async {
      await pusher.initialize('token');
      expect(reverb.connects, 1);

      await pusher.initialize('other-token');

      expect(reverb.connects, 2);
      expect(pusher.isConnected, isTrue);
    });

    test('сервер оборвал соединение — возвращаемся после паузы и '
        'подписываемся заново', () async {
      await pusher.initialize('token');
      await pusher.subscribeToConversation('42', (_) {});
      await _settle();

      await reverb.dropClients();
      await _settle(400);
      expect(reverb.connects, 1, reason: 'раньше 0,7 с повторять нельзя');

      await _until(() => reverb.subscribed.length >= 2);
      expect(reverb.connects, 2);
      expect(reverb.subscribed,
          ['private-conversation.42', 'private-conversation.42']);
    });
  });

  group('сервер ответил 429 на авторизацию канала', () {
    test('остальные каналы не запрашиваются, пока не выйдет срок', () async {
      reverb
        ..authAnswers = [200, 429, 200]
        ..retryAfter = '1';
      await pusher.initialize('token');

      for (var id = 0; id < 10; id++) {
        await pusher.subscribeToConversation('$id', (_) {});
      }
      await _settle();

      expect(reverb.authorized, hasLength(2));

      await _until(() => reverb.subscribed.toSet().length == 10);

      expect(reverb.authorized, hasLength(11));
      expect(reverb.subscribed.toSet(), hasLength(10));
      expect(
        reverb.authorized.where((c) => c == 'private-conversation.0'),
        hasLength(1),
      );
    });
  });

  group('сервер отказал в авторизации канала (не 429)', () {
    test('экран подписывается на канал четыре раза подряд — запрос один',
        () async {
      reverb.authAnswers = [500];
      await pusher.initialize('token');

      for (var i = 0; i < 4; i++) {
        await pusher.subscribeToConversation('42', (_) {});
      }
      await _settle();

      expect(reverb.authorized, ['private-conversation.42']);
    });

    test('Retry-After пришёл дважды — пауза всё равно соблюдается', () async {
      reverb
        ..authAnswers = [429, 200]
        ..retryAfter = '1'
        ..retryAfterTwice = true;
      await pusher.initialize('token');

      await pusher.subscribeToConversation('42', (_) {});
      await pusher.subscribeToConversation('43', (_) {});
      await _settle();
      expect(reverb.authorized, hasLength(1));

      await _until(() => reverb.subscribed.toSet().length == 2);
      expect(reverb.subscribed.toSet(), hasLength(2));
    });

    PusherService quick(int pauseMs) {
      final service = PusherService.forTest(
        socketUri: reverb.socketUri,
        authUri: reverb.authUri,
        authRetryPause: Duration(milliseconds: pauseMs),
      );
      addTearDown(service.disconnect);
      return service;
    }

    test('разовый сбой: канал подписывается сам, после паузы', () async {
      reverb.authAnswers = [500, 200];
      final service = quick(300);
      await service.initialize('token');

      for (var i = 0; i < 4; i++) {
        await service.subscribeToConversation('42', (_) {});
      }
      await _settle();
      expect(reverb.authorized, hasLength(1), reason: 'повтор — не сразу');

      await _until(() => reverb.subscribed.isNotEmpty);
      expect(reverb.authorized, hasLength(2));
      expect(reverb.subscribed, ['private-conversation.42']);
    });

    test('постоянный отказ: три повтора с растущей паузой — и тишина',
        () async {
      reverb.authAnswers = [403];
      final service = quick(100);
      await service.initialize('token');

      await service.subscribeToConversation('42', (_) {});
      await _until(() => reverb.authorized.length >= 4);
      expect(reverb.authorized, hasLength(4));

      await _settle(900);
      expect(reverb.authorized, hasLength(4), reason: 'дальше не опрашиваем');
    });

    test('вышел из чата и вернулся — подписка идёт сразу, пауза не мешает',
        () async {
      reverb.authAnswers = [500, 200];
      final service = quick(5000);
      await service.initialize('token');
      void listener(Map<String, dynamic> _) {}

      await service.subscribeToConversation('42', listener);
      await service.unsubscribeFromConversation('42', listener);
      await service.subscribeToConversation('42', listener);
      await _settle();

      expect(reverb.subscribed, ['private-conversation.42']);
    });
  });

  group('выход из аккаунта', () {
    test('сокет закрыт, переподключения и авторизации каналов прекращаются',
        () async {
      await pusher.initialize('token');
      await pusher.subscribeToConversation('42', (_) {});
      await _until(() => reverb.subscribed.isNotEmpty);
      expect(reverb.openClients, 1);

      await pusher.disconnect();
      await pusher.subscribeToUserChannel(7, (_) {});
      await pusher.reconnect(force: true);
      await _settle(1700);

      expect(pusher.isConnected, isFalse);
      expect(pusher.isInitialized, isFalse);
      expect(reverb.openClients, 0);
      expect(reverb.connects, 1);
      expect(reverb.authorized, ['private-conversation.42']);
    });

    test('сервер лежал — после выхода попытки подключения не продолжаются',
        () async {
      reverb.accepting = false;
      await pusher.initialize('token');
      expect(reverb.connects, 1);

      await pusher.disconnect();
      reverb.accepting = true;
      await pusher.reconnect(force: true);
      await _settle(1700);

      expect(reverb.connects, 1);
      expect(reverb.openClients, 0);
    });

    test('выход во время подключения не оставляет открытого соединения',
        () async {
      final connecting = pusher.initialize('token');
      await pusher.disconnect();
      await connecting;
      await _until(() => reverb.connects == 1 && reverb.openClients == 0);
      await _settle();

      expect(reverb.connects, 1, reason: 'попытка успела дойти до сервера');
      expect(pusher.isConnected, isFalse);
      expect(reverb.openClients, 0);
    });

    test('вход под другим пользователем — новое соединение сразу, каналы '
        'подписаны заново и его токеном', () async {
      await pusher.initialize('token');
      await pusher.subscribeToUserChannel(7, (_) {});
      await pusher.subscribeToConversation('42', (_) {});
      await _until(() => reverb.subscribed.length >= 2);
      await pusher.disconnect();

      await pusher.initialize('other-token');
      expect(reverb.connects, 2);
      expect(pusher.isConnected, isTrue);

      await pusher.subscribeToUserChannel(8, (_) {});
      await pusher.subscribeToConversation('42', (_) {});
      await pusher.subscribeToConversation('99', (_) {});
      await _until(() => reverb.subscribed.length >= 5);
      await _settle();

      expect(reverb.authTokens.take(2), everyElement('Bearer token'));
      expect(
        reverb.authorized.skip(2),
        unorderedEquals([
          'private-user.8',
          'private-conversation.42',
          'private-conversation.99',
        ]),
      );
      expect(reverb.authTokens.skip(2), everyElement('Bearer other-token'));
      expect(reverb.subscribed.skip(2), hasLength(3));
    });

    test('слушатели прежнего пользователя событий больше не получают',
        () async {
      var previous = 0;
      var current = 0;
      await pusher.initialize('token');
      await pusher.subscribeToConversation('42', (_) => previous++);
      await _until(() => reverb.subscribed.isNotEmpty);
      await pusher.disconnect();

      await pusher.initialize('other-token');
      await pusher.subscribeToConversation('42', (_) => current++);
      await _until(() => reverb.subscribed.length >= 2);
      reverb.push('message.sent', 'private-conversation.42', {'id': 1});
      await _until(() => current > 0);
      await _settle();

      expect(previous, 0);
      expect(current, 1);
    });
  });
}
