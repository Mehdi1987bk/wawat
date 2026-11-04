import 'dart:math';

import 'package:buking/services/guarded_request.dart';
import 'package:buking/services/network_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/scripted_network.dart';

const _url = 'https://api.wawatair.com/api/v1/app/version-check';
const _answer = {
  'data': {'force_update': false},
};

void main() {
  test('успех с первого раза: один запрос, ни одной паузы', () async {
    final network = ScriptedNetwork([ok(_answer)]);

    final result = await network.request().get(_url, query: {'a': 1});

    expect(result.outcome, GuardedOutcome.success);
    expect(result.data, _answer);
    expect(result.attempts, 1);
    expect(network.requests, hasLength(1));
    expect(network.pauses, isEmpty);
    expect(network.requests.single.uri.toString(), '$_url?a=1');
  });

  test('таймауты заданы явно: 5 с на соединение, 10 с на ответ', () async {
    final network = ScriptedNetwork([ok(_answer)]);

    await network.request().get(_url);

    final sent = network.requests.single;
    expect(sent.connectTimeout, const Duration(seconds: 5));
    expect(sent.receiveTimeout, const Duration(seconds: 10));
  });

  group('нет сети', () {
    test('не больше трёх повторов, паузы растут: 1, 3 и 9 секунд', () async {
      final network = ScriptedNetwork([offline()]);

      final result = await network.request().get(_url);

      expect(result.outcome, GuardedOutcome.noNetwork);
      expect(result.data, isNull);
      expect(result.attempts, 4, reason: 'первая попытка и три повтора');
      expect(network.requests, hasLength(4));
      expect(network.pauses, const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 9),
      ]);
    });

    test('между попытками всегда есть пауза — серий подряд не бывает',
        () async {
      final network = ScriptedNetwork([offline()]);

      await network.request().get(_url);

      expect(network.pauses, hasLength(network.requests.length - 1));
      for (var i = 1; i < network.sentAt.length; i++) {
        expect(network.sentAt[i] - network.sentAt[i - 1],
            greaterThanOrEqualTo(const Duration(seconds: 1)));
      }
    });

    test('паузы слегка «дрожат», но остаются около 1, 3 и 9 секунд', () async {
      final network = ScriptedNetwork([offline()]);
      final request = GuardedRequest(
        dio: network.dio,
        clock: network.clock,
        sleep: network.sleep,
        random: Random(7),
      );

      await request.get(_url);

      expect(network.pauses, hasLength(3));
      const bases = [1000, 3000, 9000];
      for (var i = 0; i < 3; i++) {
        final ms = network.pauses[i].inMilliseconds;
        expect(ms, inInclusiveRange(bases[i] * 0.8, bases[i] * 1.2));
      }
      expect(network.pauses.map((p) => p.inMilliseconds),
          isNot(orderedEquals(bases)));
    });

    test('сеть вернулась на втором запросе — дальше не повторяем', () async {
      final network = ScriptedNetwork([offline(), ok(_answer)]);

      final result = await network.request().get(_url);

      expect(result.isSuccess, isTrue);
      expect(result.attempts, 2);
      expect(network.pauses, const [Duration(seconds: 1)]);
    });

    test('номер попытки уходит вместе с запросом', () async {
      final network = ScriptedNetwork([offline(), ok(_answer)]);

      await network.request().get(_url);

      expect(
        network.requests.map((r) => r.extra[NetworkFailure.attemptKey]),
        [1, 2],
      );
    });
  });

  group('ответ посредника', () {
    test('«504» за доли секунды обрабатывается как отсутствие сети', () async {
      final network = ScriptedNetwork([status(504)]);

      final result = await network.request().get(_url);

      expect(result.outcome, GuardedOutcome.noNetwork);
      expect(result.data, isNull);
      expect(result.attempts, 4);
    });

    test('страница входа гостевого Wi‑Fi — это не ответ сервера', () async {
      final network = ScriptedNetwork([captivePortal()]);

      final result = await network.request().get(_url);

      expect(result.outcome, GuardedOutcome.noNetwork);
      expect(result.data, isNull);
    });
  });

  group('429', () {
    test('повторы прекращаются сразу', () async {
      final network = ScriptedNetwork([status(429)]);

      final result = await network.request().get(_url);

      expect(result.outcome, GuardedOutcome.rateLimited);
      expect(result.attempts, 1);
      expect(network.requests, hasLength(1));
      expect(network.pauses, isEmpty);
    });

    test('429 посреди повторов тоже обрывает их', () async {
      final network = ScriptedNetwork([offline(), status(429), ok(_answer)]);

      final result = await network.request().get(_url);

      expect(result.outcome, GuardedOutcome.rateLimited);
      expect(network.requests, hasLength(2));
    });

    test('Retry-After: пока время не вышло, запрос в сеть не уходит',
        () async {
      final network = ScriptedNetwork([
        status(429, headers: {
          'retry-after': ['120'],
        }),
        ok(_answer),
      ]);
      final request = network.request();

      await request.get(_url);
      expect(request.blockedUntil,
          network.now.add(const Duration(seconds: 120)));

      network.advance(const Duration(seconds: 119));
      final early = await request.get(_url);
      expect(early.outcome, GuardedOutcome.rateLimited);
      expect(early.attempts, 0);
      expect(network.requests, hasLength(1));

      network.advance(const Duration(seconds: 2));
      final later = await request.get(_url);
      expect(later.isSuccess, isTrue);
      expect(network.requests, hasLength(2));
    });

    test('без Retry-After ждём минуту — окно, за которое сервер считает лимит',
        () async {
      final network = ScriptedNetwork([status(429), ok(_answer)]);
      final request = network.request();

      await request.get(_url);
      network.advance(const Duration(seconds: 59));
      expect((await request.get(_url)).attempts, 0);

      network.advance(const Duration(seconds: 2));
      expect((await request.get(_url)).isSuccess, isTrue);
    });
  });

  test('4xx не повторяется: чинить нужно запрос', () async {
    final network = ScriptedNetwork([
      status(422, body: {'message': 'invalid'}),
    ]);

    final result = await network.request().get(_url);

    expect(result.outcome, GuardedOutcome.rejected);
    expect(result.attempts, 1);
    expect(network.pauses, isEmpty);
  });

  test('настоящий 5xx повторяется с теми же паузами', () async {
    final network = ScriptedNetwork([status(503)])
      ..answerTook = const Duration(seconds: 10);

    final result = await network.request().get(_url);

    expect(result.outcome, GuardedOutcome.serverError);
    expect(result.attempts, 4);
    expect(network.pauses, hasLength(3));
  });

  group('общий предел — 20 секунд на всю операцию', () {
    test('если каждый запрос висит до таймаута, укладываемся в 20 секунд',
        () async {
      late final ScriptedNetwork network;
      network = ScriptedNetwork([
        (options) {
          network.advance(options.connectTimeout!);
          throw DioException.connectionTimeout(
            timeout: options.connectTimeout!,
            requestOptions: options,
          );
        },
      ]);
      final startedAt = network.now;

      final result = await network.request().get(_url);

      expect(result.outcome, GuardedOutcome.noNetwork);
      expect(network.now.difference(startedAt),
          lessThanOrEqualTo(const Duration(seconds: 20)));
      expect(result.attempts, 3);
      expect(network.pauses,
          const [Duration(seconds: 1), Duration(seconds: 3)]);
    });

    test('последний запрос получает только остаток времени', () async {
      late final ScriptedNetwork network;
      network = ScriptedNetwork([
        (options) {
          network.advance(const Duration(seconds: 7));
          throw DioException.receiveTimeout(
            timeout: options.receiveTimeout!,
            requestOptions: options,
          );
        },
      ]);

      await network.request().get(_url);

      expect(network.requests, hasLength(3));
      expect(network.requests.last.connectTimeout, const Duration(seconds: 2));
      expect(network.requests.last.receiveTimeout, const Duration(seconds: 2));
    });
  });

  group('находки проверки', () {
    test('Retry-After пришёл дважды — запрос не падает, срок соблюдается',
        () async {
      final network = ScriptedNetwork([
        status(429, headers: {
          'retry-after': ['30', '30'],
        }),
      ]);
      final request = network.request();

      final result = await request.get(_url);

      expect(result.outcome, GuardedOutcome.rateLimited);
      expect(request.blockedUntil,
          network.now.add(const Duration(seconds: 30)));
    });

    test('настоящий сбой сервера помечается: отчёт о нём уходит один раз',
        () async {
      final network = ScriptedNetwork([
        status(500, body: const {'message': 'Server Error'}),
      ]);

      await network.request().get(_url);

      expect(
        [
          for (final sent in network.requests)
            sent.extra[NetworkFailure.reportedKey] == true,
        ],
        [false, true, true, true],
      );
    });

    test('обрыв, а затем настоящий сбой: о сбое ещё не сообщали — пометки нет',
        () async {
      final network = ScriptedNetwork([
        offline(),
        status(500, body: const {'message': 'Server Error'}),
      ]);

      await network.request().get(_url);

      expect(
        [
          for (final sent in network.requests)
            sent.extra[NetworkFailure.reportedKey] == true,
        ],
        [false, false, true, true],
      );
    });
  });
}
