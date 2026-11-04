import 'package:buking/data/network/response/chat_response.dart';
import 'package:buking/screens/chat/bloc/chat_conversation_bloc.dart';
import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_chat_server.dart';

const _s = Duration(seconds: 1);
const _ms = Duration(milliseconds: 1);

const _getMessages = 'GET /conversations/{id}/messages';
const _postMessage = 'POST /conversations/{id}/messages';
const _read = 'POST /conversations/{id}/read';
const _typing = 'POST /conversations/{id}/typing';

class _Chat {
  _Chat(this.async) {
    server = FakeChatServer(clock: _now);
    bloc = ChatConversationBloc(
      chatApi: server.api(),
      realtime: realtime,
      cacheManager: FakeSession(),
      clock: _now,
    );
    bloc.messagesStream.listen((value) => messages = value, onError: (_) {});
    bloc.sendErrorsStream.listen(errors.add);
  }

  static final _start = DateTime(2026, 10, 13, 19, 33);

  final FakeAsync async;
  late final FakeChatServer server;
  final realtime = FakeRealtime();
  late final ChatConversationBloc bloc;
  List<ChatMessage> messages = const [];
  final errors = <Object>[];

  DateTime _now() => _start.add(async.elapsed);

  void open() {
    bloc.initChat('01CONVERSATION').then((_) => bloc.loadMessages());
    async.elapse(_ms * 10);
  }

  void typeAndSend(
    String text, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final keys = duration.inMilliseconds ~/ 100;
    for (var i = 0; i < keys; i++) {
      bloc.onComposerChanged('$text $i');
      async.elapse(_ms * 100);
    }
    bloc.sendMessage(text, null);
    async.elapse(_ms * 10);
  }

  void close() {
    bloc.dispose();
    async.elapse(_s);
  }

  List<String> get bodies =>
      [for (final message in messages.reversed) message.body ?? ''];
}

void _echo(_Chat chat, Map<String, dynamic> Function(Map<String, dynamic>) shape,
    {bool beforeAnswer = false}) {
  chat.server.onCreated = (message) {
    final event = shape(message);
    if (beforeAnswer) {
      chat.realtime.message(event);
    } else {
      Future<void>.delayed(_ms * 50, () => chat.realtime.message(event));
    }
  };
}

ResponseBody _tooManyRequests({int? header, int? body}) => FakeChatServer.json(
      {
        'message': 'Слишком много сообщений. Подождите немного.',
        'code': 'RATE_LIMITED',
        if (body != null) 'retry_after': body,
      },
      status: 429,
      headers: {
        if (header != null) 'retry-after': ['$header'],
      },
    );

void main() {
  group('минута активной переписки: 16 сообщений', () {
    final shapes = <String, Map<String, dynamic> Function(Map<String, dynamic>)>{
      'в событии есть автор': (message) => {...message, 'sender_id': 7},
      'в событии только id сообщения': (message) => {'id': message['id']},
      'сообщение вложено в message': (message) => {'message': message},
      'в событии нет ни автора, ни id': (message) => {'body': message['body']},
    };

    for (final shape in shapes.entries) {
      for (final beforeAnswer in [false, true]) {
        final order = beforeAnswer ? 'событие раньше ответа' : 'ответ раньше';
        test('${shape.key}, $order', () {
          fakeAsync((async) {
            final chat = _Chat(async)..open();
            _echo(chat, shape.value, beforeAnswer: beforeAnswer);

            for (var i = 1; i <= 16; i++) {
              chat.typeAndSend('сообщение $i');
              async.elapse(_ms * 1740);
            }
            async.elapse(_s * 5);

            final counts = chat.server.counts;
            expect(counts[_postMessage], 16);
            expect(chat.bodies, [for (var i = 1; i <= 16; i++) 'сообщение $i']);
            expect(
              chat.messages.every((message) =>
                  message.deliveryStatus == ChatMessageDeliveryStatus.sent),
              isTrue,
            );
            expect(counts[_getMessages], lessThanOrEqualTo(2));
            expect(counts[_read], 1);
            expect(counts[_typing], lessThanOrEqualTo(20));
            final typing = chat.server.timesOf(_typing);
            for (var i = 1; i < typing.length; i++) {
              expect(
                typing[i].difference(typing[i - 1]),
                greaterThanOrEqualTo(_s * 3),
              );
            }
            final total = chat.server.log.length;
            expect(total - 16, lessThanOrEqualTo(20), reason: '$counts');
            chat.close();
          });
        });
      }
    }
  });

  test('10 сообщений за 10 секунд — все доставлены, лента не перезагружается',
      () {
    fakeAsync((async) {
      final chat = _Chat(async)..open();
      _echo(chat, (message) => {'id': message['id']});

      for (var i = 1; i <= 10; i++) {
        chat.typeAndSend('быстро $i', duration: _ms * 900);
        async.elapse(_ms * 90);
      }
      async.elapse(_s * 5);

      expect(chat.bodies, [for (var i = 1; i <= 10; i++) 'быстро $i']);
      expect(chat.errors, isEmpty);
      expect(chat.server.count(_postMessage), 10);
      expect(chat.server.count(_getMessages), 1);
      expect(chat.server.count(_read), 1);
      expect(chat.server.count(_typing), lessThanOrEqualTo(5));
      chat.close();
    });
  });

  group('входящие', () {
    test('новое сообщение собеседника — лента обновляется и уходит «прочитано»',
        () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();

        final incoming = chat.server.addIncoming('привет');
        chat.realtime.message({'id': incoming['id'], 'sender_id': 99});
        async.elapse(_s);

        expect(chat.bodies, ['привет']);
        expect(chat.server.count(_getMessages), 2);
        expect(chat.server.count(_read), 2);
        chat.close();
      });
    });

    test('пачка событий — не запрос на каждое', () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();

        for (var i = 1; i <= 5; i++) {
          final incoming = chat.server.addIncoming('часть $i');
          chat.realtime.message({'id': incoming['id'], 'sender_id': 99});
        }
        async.elapse(_s);

        expect(chat.bodies, [for (var i = 1; i <= 5; i++) 'часть $i']);
        expect(chat.server.count(_getMessages), lessThanOrEqualTo(3));
        chat.close();
      });
    });

    test('собеседник написал, пока моё сообщение было в пути — оно не теряется',
        () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();
        chat.server.onCreated = (_) {
          final incoming = chat.server.addIncoming('встречное');
          chat.realtime.message({'id': incoming['id']});
        };

        chat.typeAndSend('моё', duration: _ms * 300);
        async.elapse(_s);

        expect(chat.bodies, containsAll(['моё', 'встречное']));
        chat.close();
      });
    });

    test('возврат из фона без новых входящих — «прочитано» не повторяется', () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();
        chat.server.addIncoming('привет');
        chat.bloc.loadMessages();
        async.elapse(_s);
        expect(chat.server.count(_read), 2);

        chat.bloc.reconnectRealtime();
        async.elapse(_s);
        chat.bloc.loadMessages();
        async.elapse(_s);

        expect(chat.server.count(_read), 2);
        chat.close();
      });
    });
  });

  group('ответ 429', () {
    test('сообщение остаётся с «Повторить», само не переотправляется', () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();
        chat.server.answer = (route) =>
            route == _postMessage ? _tooManyRequests(header: 30) : null;

        chat.typeAndSend('не ушло', duration: _ms * 300);
        async.elapse(_s * 120);

        expect(chat.server.count(_postMessage), 1);
        expect(chat.messages.single.deliveryStatus,
            ChatMessageDeliveryStatus.failed);
        final error = chat.errors.single as DioException;
        expect((error.response!.data as Map)['message'],
            'Слишком много сообщений. Подождите немного.');
        chat.close();
      });
    });

    test('«Повторить» раньше срока Retry-After — запрос в сеть не уходит', () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();
        chat.server.answer = (route) =>
            route == _postMessage ? _tooManyRequests(header: 30) : null;
        chat.typeAndSend('не ушло', duration: _ms * 300);
        async.elapse(_s);
        chat.server.answer = null;

        chat.bloc.retryMessage(chat.messages.single.id);
        async.elapse(_s);
        expect(chat.server.count(_postMessage), 1);
        expect(chat.messages.single.deliveryStatus,
            ChatMessageDeliveryStatus.failed);
        expect(chat.errors, hasLength(2));

        async.elapse(_s * 30);
        chat.bloc.retryMessage(chat.messages.single.id);
        async.elapse(_s);
        expect(chat.server.count(_postMessage), 2);
        expect(chat.bodies, ['не ушло']);
        expect(chat.messages.single.deliveryStatus,
            ChatMessageDeliveryStatus.sent);
        chat.close();
      });
    });

    test('короткий срок — следующее сообщение ждёт его и уходит само', () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();
        var refused = false;
        chat.server.answer = (route) {
          if (route != _postMessage || refused) return null;
          refused = true;
          return _tooManyRequests(body: 3);
        };

        chat.typeAndSend('первое', duration: _ms * 300);
        chat.typeAndSend('второе', duration: _ms * 300);
        expect(chat.server.count(_postMessage), 1);

        async.elapse(_s * 4);
        final posts = chat.server.timesOf(_postMessage);
        expect(posts, hasLength(2));
        expect(posts[1].difference(posts[0]), greaterThanOrEqualTo(_s * 3));
        expect(chat.messages.first.body, 'второе');
        expect(chat.messages.first.deliveryStatus,
            ChatMessageDeliveryStatus.sent);
        chat.close();
      });
    });

    test('429 на «печатает» — пауза до Retry-After, отправка не страдает', () {
      fakeAsync((async) {
        final chat = _Chat(async)..open();
        chat.server.answer =
            (route) => route == _typing ? _tooManyRequests(header: 60) : null;

        for (var i = 1; i <= 8; i++) {
          chat.typeAndSend('сообщение $i');
          async.elapse(_s * 2);
        }

        expect(chat.server.count(_typing), 1);
        expect(chat.server.count(_postMessage), 8);
        expect(chat.errors, isEmpty);
        chat.close();
      });
    });
  });
}
