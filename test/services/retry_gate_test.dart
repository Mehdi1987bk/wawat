import 'package:buking/services/network_failure.dart';
import 'package:buking/services/retry_gate.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/scripted_network.dart';

const _feed = 'https://api.wawatair.com/api/v1/listings';

Dio _guarded(ScriptedNetwork net, {List<Interceptor> after = const []}) {
  final dio = net.dio();
  dio.interceptors
    ..insert(0, RetryGate(clock: net.clock, sleep: net.sleep))
    ..addAll(after);
  return dio;
}

Future<int?> _try(Dio dio, String url, {String method = 'GET'}) async {
  try {
    final response = await dio.request<dynamic>(url,
        options: Options(method: method));
    return response.statusCode;
  } on DioException catch (e) {
    return e.response?.statusCode ?? 0;
  }
}

const _second = Duration(seconds: 1);

void main() {
  group('первый запрос и запрос после успеха', () {
    test('не задерживаются', () async {
      final net = ScriptedNetwork([ok(const {})]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      await _try(dio, _feed);
      await _try(dio, _feed);

      expect(net.requests, hasLength(3));
      expect(net.pauses, isEmpty);
    });
  });

  group('связи не было', () {
    test('тот же запрос уходит не раньше чем через секунду', () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      for (var i = 0; i < 4; i++) {
        await _try(dio, _feed);
      }

      expect(net.requests, hasLength(4));
      expect(net.sentAt, [
        Duration.zero,
        _second,
        _second * 2,
        _second * 3,
      ]);
    });

    test('пауза не растёт: сеть вернулась — приложение оживает сразу',
        () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      for (var i = 0; i < 6; i++) {
        await _try(dio, _feed);
      }

      expect(net.pauses, everyElement(RetryGate.connectionPause));
    });

    test('ждём только остаток паузы, а не всю заново', () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.advance(const Duration(milliseconds: 400));
      await _try(dio, _feed);

      expect(net.pauses, [const Duration(milliseconds: 600)]);
    });

    test('человек нажал «повторить» через пару секунд — ждать нечего',
        () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.advance(const Duration(seconds: 2));
      await _try(dio, _feed);

      expect(net.pauses, isEmpty);
    });

    test('мгновенный «504» посредника — то же самое, что нет сети', () async {
      final net = ScriptedNetwork([status(504)]);
      final dio = _guarded(net);

      for (var i = 0; i < 4; i++) {
        await _try(dio, _feed);
      }

      expect(net.pauses, everyElement(RetryGate.connectionPause));
    });

    test('другой запрос не ждёт из-за чужой неудачи', () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      await _try(dio, '$_feed?page=2');
      await _try(dio, '$_feed?page=3');
      await _try(dio, 'https://api.wawatair.com/api/v1/cities');

      expect(net.pauses, isEmpty);
    });
  });

  group('сервер ответил ошибкой', () {
    test('паузы растут: 1, 3, 9 секунд и дальше по 9', () async {
      final net = ScriptedNetwork([
        status(500, body: const {'message': 'Server Error'}),
      ]);
      final dio = _guarded(net);

      for (var i = 0; i < 5; i++) {
        await _try(dio, _feed);
      }

      expect(net.pauses, const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 9),
        Duration(seconds: 9),
      ]);
    });

    test('успех обнуляет лестницу', () async {
      final net = ScriptedNetwork([
        status(500, body: const {}),
        status(500, body: const {}),
        ok(const {}),
        status(500, body: const {}),
        status(500, body: const {}),
      ]);
      final dio = _guarded(net);

      for (var i = 0; i < 5; i++) {
        await _try(dio, _feed);
      }

      expect(net.pauses, const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 1),
      ]);
    });

    test('через минуту тишины неудача считается первой', () async {
      final net = ScriptedNetwork([status(500, body: const {})]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      await _try(dio, _feed);
      await _try(dio, _feed);
      net.advance(const Duration(minutes: 2));
      await _try(dio, _feed);
      await _try(dio, _feed);

      expect(net.pauses.last, const Duration(seconds: 1));
    });

    test('отказ по существу (422) следующий запрос не задерживает', () async {
      final net = ScriptedNetwork([
        status(422, body: const {'message': 'The given data was invalid.'}),
      ]);
      final dio = _guarded(net);

      await _try(dio, _feed, method: 'POST');
      await _try(dio, _feed, method: 'POST');

      expect(net.requests, hasLength(2));
      expect(net.pauses, isEmpty);
    });
  });

  group('сервер попросил подождать (429)', () {
    NetworkStep tooMany({String? retryAfter}) => status(
          429,
          body: const {'message': 'Too Many Attempts.'},
          headers: {
            if (retryAfter != null) 'retry-after': [retryAfter],
          },
        );

    test('такой же запрос больше не уходит, пока не выйдет срок', () async {
      final net = ScriptedNetwork([tooMany(retryAfter: '30')]);
      final dio = _guarded(net);

      final codes = <int?>[];
      for (var i = 0; i < 50; i++) {
        codes.add(await _try(dio, _feed));
      }

      expect(net.requests, hasLength(1));
      expect(codes, everyElement(429));
      expect(net.pauses, isEmpty);
    });

    test('другая страница того же списка — тоже не уходит', () async {
      final net = ScriptedNetwork([tooMany(retryAfter: '30')]);
      final dio = _guarded(net);

      await _try(dio, '$_feed?page=2');
      await _try(dio, '$_feed?page=1');
      await _try(dio, '$_feed?page=3');

      expect(net.requests, hasLength(1));
    });

    test('срок вышел — запрос уходит', () async {
      final net = ScriptedNetwork([tooMany(retryAfter: '30'), ok(const {})]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.advance(const Duration(seconds: 29));
      expect(await _try(dio, _feed), 429);
      net.advance(const Duration(seconds: 2));
      expect(await _try(dio, _feed), 200);

      expect(net.requests, hasLength(2));
    });

    test('вызывающий получает тот же ответ сервера, что и в первый раз',
        () async {
      final net = ScriptedNetwork([tooMany(retryAfter: '30')]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      DioException? refused;
      try {
        await dio.get<dynamic>(_feed);
      } on DioException catch (e) {
        refused = e;
      }

      expect(refused?.response?.statusCode, 429);
      expect(refused?.response?.data, {'message': 'Too Many Attempts.'});
      expect(refused?.response?.headers.value('retry-after'), '30');
      expect(NetworkFailure.of(refused!).kind, NetworkFailureKind.rateLimited);
    });

    test('запрос, не ушедший в сеть, не попадает в телеметрию', () async {
      var reported = 0;
      final net = ScriptedNetwork([tooMany(retryAfter: '30')]);
      final dio = _guarded(net, after: [
        InterceptorsWrapper(onError: (err, handler) {
          reported++;
          handler.next(err);
        }),
      ]);

      for (var i = 0; i < 10; i++) {
        await _try(dio, _feed);
      }

      expect(reported, 1);
    });

    test('другой адрес блокировка не задевает', () async {
      final net = ScriptedNetwork([tooMany(retryAfter: '30'), ok(const {})]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      expect(await _try(dio, 'https://api.wawatair.com/api/v1/cities'), 200);
    });

    test('без названного срока — не блокируем, но и подряд не шлём', () async {
      final net = ScriptedNetwork([tooMany()]);
      final dio = _guarded(net);

      for (var i = 0; i < 4; i++) {
        await _try(dio, _feed);
      }

      expect(net.requests, hasLength(4));
      expect(net.pauses, const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 9),
      ]);
    });

    test('отправку данных не блокируем: лимит там может считаться по номеру '
        'телефона, а человек его уже исправил', () async {
      const login = 'https://api.wawatair.com/api/v1/auth/login';
      final net = ScriptedNetwork([tooMany(retryAfter: '30'), ok(const {})]);
      final dio = _guarded(net);

      expect(await _try(dio, login, method: 'POST'), 429);
      net.advance(const Duration(seconds: 2));
      expect(await _try(dio, login, method: 'POST'), 200);

      expect(net.requests, hasLength(2));
    });
  });

  group('запросы со своей лестницей повторов', () {
    test('проходят мимо: их паузы и общий срок считает GuardedRequest',
        () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      for (var attempt = 1; attempt <= 3; attempt++) {
        try {
          await dio.get<dynamic>(
            _feed,
            options: Options(extra: {NetworkFailure.attemptKey: attempt}),
          );
        } on DioException catch (_) {}
      }
      await _try(dio, _feed);

      expect(net.requests, hasLength(4));
      expect(net.pauses, isEmpty);
    });
  });

  group('память', () {
    test('сотни разных упавших адресов не ломают предохранитель', () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      for (var page = 0; page < 450; page++) {
        await _try(dio, '$_feed?page=$page');
      }
      await _try(dio, '$_feed?page=0');
      await _try(dio, '$_feed?page=449');

      expect(net.pauses, [RetryGate.connectionPause]);
    });
  });

  group('находки проверки', () {
    NetworkStep tooMany(List<String> retryAfter) => status(
          429,
          body: const {'message': 'Too Many Attempts.'},
          headers: {'retry-after': retryAfter},
        );

    test('два экрана спросили одно и то же, оба получили 500 — это одна '
        'неудача, а не две ступени', () async {
      final net = ScriptedNetwork([
        status(500, body: const {'message': 'Server Error'}),
      ]);
      final dio = _guarded(net);

      await Future.wait([_try(dio, _feed), _try(dio, _feed), _try(dio, _feed)]);
      await _try(dio, _feed);

      expect(net.requests, hasLength(4));
      expect(net.pauses, const [Duration(seconds: 1)]);
    });

    test('локальный отказ называет остаток срока, а не весь срок заново',
        () async {
      final net = ScriptedNetwork([tooMany(['30'])]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.advance(const Duration(seconds: 20, milliseconds: 400));
      DioException? refused;
      try {
        await dio.get<dynamic>(_feed);
      } on DioException catch (e) {
        refused = e;
      }

      expect(refused?.response?.headers['retry-after'], ['10']);
      expect(net.requests, hasLength(1));
    });

    test('Retry-After пришёл дважды — срок всё равно соблюдается', () async {
      final net = ScriptedNetwork([tooMany(['30', '30'])]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      expect(await _try(dio, _feed), 429);

      expect(net.requests, hasLength(1));
    });

    test('часы телефона перевели назад — запрос ждёт не дольше самой паузы',
        () async {
      final net = ScriptedNetwork([offline()]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.now = net.now.subtract(const Duration(hours: 3));
      await _try(dio, _feed);

      expect(net.pauses, [RetryGate.connectionPause]);
    });

    test('часы перевели назад после 429 — блокировка не растягивается на часы',
        () async {
      final net = ScriptedNetwork([tooMany(['30']), ok(const {})]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.now = net.now.subtract(const Duration(hours: 3));

      expect(await _try(dio, _feed), 200);
    });

    test('часы перевели назад посреди лестницы — она растёт дальше, а не '
        'замирает', () async {
      final net = ScriptedNetwork([
        status(500, body: const {'message': 'Server Error'}),
      ]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.now = net.now.subtract(const Duration(hours: 3));
      for (var i = 0; i < 3; i++) {
        await _try(dio, _feed);
      }

      expect(net.pauses, const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 9),
      ]);
    });

    test('часы перевели назад на пять минут после 429 — блок не длиннее, чем '
        'просил сервер', () async {
      final net = ScriptedNetwork([tooMany(['30']), ok(const {})]);
      final dio = _guarded(net);

      await _try(dio, _feed);
      net.now = net.now.subtract(const Duration(minutes: 5));

      expect(await _try(dio, _feed), 200);
      expect(net.requests, hasLength(2));
    });
  });
}
