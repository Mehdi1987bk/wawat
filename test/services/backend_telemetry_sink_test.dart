import 'dart:async';

import 'package:buking/services/telemetry/backend_telemetry_sink.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Server {
  _Server(this.statuses, {this.retryAfter});

  final List<int> statuses;
  final String? retryAfter;
  final List<int> batches = [];
  DateTime now = DateTime(2026, 10, 13, 12);

  Completer<void>? hold;

  void advance(Duration by) => now = now.add(by);

  Dio dio() {
    final dio = Dio(BaseOptions(validateStatus: (_) => true));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        batches.add(((options.data as Map)['records'] as List).length);
        await hold?.future;
        final status = statuses[
            batches.length <= statuses.length ? batches.length - 1 : statuses.length - 1];
        handler.resolve(Response<dynamic>(
          requestOptions: options,
          statusCode: status,
          headers: Headers.fromMap({
            if (retryAfter != null) 'retry-after': [retryAfter!],
          }),
        ));
      },
    ));
    return dio;
  }
}

TelemetryRecord _record([String name = 'api_failure']) => TelemetryRecord(
      type: 'event',
      name: name,
      severity: 'warning',
      occurredAt: DateTime(2026, 10, 13, 12),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BackendTelemetrySink sink;

  Future<_Server> start(List<int> statuses, {String? retryAfter}) async {
    final server = _Server(statuses, retryAfter: retryAfter);
    sink = BackendTelemetrySink.forTest();
    await sink.init(
      baseUrl: 'https://api.wawatair.com/api/v1',
      tokenProvider: () async => null,
      contextProvider: () => const {},
      dio: server.dio(),
      clock: () => server.now,
    );
    return server;
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => sink.dispose());

  test('успешная отправка опустошает очередь', () async {
    final server = await start([200]);
    sink.add(_record());

    await sink.flush();
    server.advance(const Duration(minutes: 1));
    await sink.flush();

    expect(server.batches, [1], reason: 'пустую очередь не отправляем');
  });

  group('после сбоя сервера', () {
    test('новые записи не вызывают отправку — повтора без паузы нет', () async {
      final server = await start([500]);
      sink.add(_record());
      await sink.flush();
      expect(server.batches, hasLength(1));

      for (var i = 0; i < 40; i++) {
        sink.add(_record('event_$i'));
        await pumpEventQueue(times: 1);
      }
      await sink.flush();

      expect(server.batches, hasLength(1));
    });

    test('первая повторная попытка — примерно через минуту', () async {
      final server = await start([500, 200]);
      sink.add(_record());
      await sink.flush();

      server.advance(const Duration(seconds: 47));
      await sink.flush();
      expect(server.batches, hasLength(1), reason: 'рано даже с учётом разброса');

      server.advance(const Duration(seconds: 26));
      await sink.flush();
      expect(server.batches, hasLength(2));
    });

    test('паузы растут: ~1, ~3, ~9 минут, затем четверть часа', () async {
      final server = await start([500]);
      sink.add(_record());
      await sink.flush();

      for (final minutes in [1, 3, 9, 15]) {
        server.advance(Duration(seconds: (minutes * 60 * 0.79).floor()));
        await sink.flush();
        final before = server.batches.length;
        server.advance(Duration(seconds: (minutes * 60 * 0.42).ceil()));
        await sink.flush();
        expect(server.batches.length, before + 1, reason: 'пауза ~$minutes мин');
      }
      expect(server.batches, hasLength(5));
    });

    test('срочная отправка тоже ждёт: сервер от срочности не заработает',
        () async {
      final server = await start([500]);
      sink.add(_record());
      await sink.flush();

      sink.add(_record('uncaught_error'));
      await sink.flush(force: true);

      expect(server.batches, hasLength(1));
    });
  });

  group('429', () {
    test('Retry-After соблюдается, даже для срочной отправки', () async {
      final server = await start([429, 200], retryAfter: '600');
      sink.add(_record());
      await sink.flush();

      server.advance(const Duration(minutes: 9, seconds: 50));
      await sink.flush();
      await sink.flush(force: true);
      expect(server.batches, hasLength(1));

      server.advance(const Duration(seconds: 15));
      await sink.flush();
      expect(server.batches, hasLength(2));
    });

    test('без Retry-After молчим не меньше минуты', () async {
      final server = await start([429, 200]);
      sink.add(_record());
      await sink.flush();

      server.advance(const Duration(seconds: 45));
      await sink.flush(force: true);

      expect(server.batches, hasLength(1));
    });
  });

  test('пачку, которую сервер отклонил, не шлём повторно', () async {
    final server = await start([422, 200]);
    sink.add(_record());
    await sink.flush();

    sink.add(_record('next'));
    server.advance(const Duration(seconds: 6));
    await sink.flush();

    expect(server.batches, [1, 1], reason: 'во второй пачке только новая запись');
  });

  test('серия срочных отправок уходит одной пачкой, а не запросом на каждую',
      () async {
    final server = await start([200]);

    for (var i = 0; i < 10; i++) {
      sink.add(_record('uncaught_error'));
      await sink.flush(force: true);
    }

    expect(server.batches, [1]);

    server.advance(const Duration(seconds: 5));
    await sink.flush(force: true);
    expect(server.batches, [1, 9]);
  });

  test('неотправленное переживает перезапуск', () async {
    await start([500]);
    sink.add(_record('crash'));
    await sink.flush();
    sink.dispose();

    final next = await start([200]);
    await sink.flush();

    expect(next.batches, [1]);
  });

  test('одним запросом уходит не больше 50 записей, остаток — следующими',
      () async {
    final server = await start([500, 200]);
    sink.add(_record());
    await sink.flush();
    for (var i = 0; i < 119; i++) {
      sink.add(_record());
    }

    for (var i = 0; i < 3; i++) {
      server.advance(const Duration(minutes: 2));
      await sink.flush();
    }

    expect(server.batches, [1, 50, 50, 20]);
  });

  test('пока отправка отложена, накопленное сохраняется на диск по таймеру',
      () async {
    await start([500]);
    sink.add(_record('first'));
    await sink.flush();

    sink.add(_record('second'));
    sink.add(_record('third'));
    await sink.tick();
    sink.dispose();

    final next = await start([200]);
    await sink.flush();

    expect(next.batches, [3]);
  });

  group('запись пришла, пока прошлая пачка ещё в пути', () {
    test('обычная — ждёт таймера: цепочки отправок каждые 5 секунд нет',
        () async {
      final server = await start([200]);
      server.hold = Completer<void>();
      sink.add(_record());
      final sending = sink.flush();
      await Future<void>.delayed(Duration.zero);

      sink.add(_record('screen_view'));
      server.hold!.complete();
      await sending;

      expect(server.batches, [1]);
      expect(sink.hasDeferredSend, isFalse);
    });

    test('срочная — уходит следом, не дожидаясь таймера', () async {
      final server = await start([200]);
      server.hold = Completer<void>();
      sink.add(_record());
      final sending = sink.flush();
      await Future<void>.delayed(Duration.zero);

      sink.add(_record('uncaught_error'));
      await sink.flush(force: true);
      server.hold!.complete();
      await sending;

      expect(server.batches, [1]);
      expect(sink.hasDeferredSend, isTrue);
    });

    test('не поместившееся в пачку — тоже следом', () async {
      final server = await start([500, 200]);
      sink.add(_record());
      await sink.flush();
      for (var i = 0; i < 59; i++) {
        sink.add(_record());
      }

      server.advance(const Duration(minutes: 2));
      await sink.flush();

      expect(server.batches, [1, 50]);
      expect(sink.hasDeferredSend, isTrue);
    });
  });
}
