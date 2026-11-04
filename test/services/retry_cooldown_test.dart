import 'package:buking/domain/entities/pagination.dart';
import 'package:buking/presentation/bloc/paginable_bloc.dart';
import 'package:buking/services/retry_cooldown.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _status(int code, {String? retryAfter}) {
  final options = RequestOptions(path: '/listings');
  return DioException.badResponse(
    statusCode: code,
    requestOptions: options,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: code,
      headers: Headers.fromMap({
        if (retryAfter != null) 'retry-after': [retryAfter],
      }),
    ),
  );
}

class _Feed extends PaginableBloc<int> {
  final requested = <int>[];
  Object? failWith;

  @override
  Future<Pagination<int>> provideSource(int page) async {
    requested.add(page);
    final failure = failWith;
    if (failure != null) throw failure;
    return Pagination<int>(data: [page], lastPage: 5);
  }
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  group('RetryCooldown', () {
    late DateTime now;
    late RetryCooldown cooldown;

    setUp(() {
      now = DateTime(2026, 10, 13, 12);
      cooldown = RetryCooldown(clock: () => now);
    });

    void pass(Duration time) => now = now.add(time);

    test('до первой неудачи пробовать можно', () {
      expect(cooldown.ready, isTrue);
    });

    test('паузы растут: 3, 10 и дальше по 30 секунд', () {
      final waited = <int>[];
      for (var i = 0; i < 4; i++) {
        cooldown.failed(_status(500));
        var seconds = 0;
        while (!cooldown.ready) {
          pass(const Duration(seconds: 1));
          seconds++;
        }
        waited.add(seconds);
      }

      expect(waited, [3, 10, 30, 30]);
    });

    test('429 — ждём столько, сколько просит сервер', () {
      cooldown.failed(_status(429, retryAfter: '45'));

      pass(const Duration(seconds: 44));
      expect(cooldown.ready, isFalse);
      pass(const Duration(seconds: 1));
      expect(cooldown.ready, isTrue);
    });

    test('429 без названного срока — минута', () {
      cooldown.failed(_status(429));

      pass(const Duration(seconds: 59));
      expect(cooldown.ready, isFalse);
      pass(const Duration(seconds: 1));
      expect(cooldown.ready, isTrue);
    });

    test('reset снимает паузу и возвращает на первую ступень', () {
      cooldown
        ..failed(_status(500))
        ..failed(_status(500))
        ..reset();
      expect(cooldown.ready, isTrue);

      cooldown.failed(_status(500));
      pass(const Duration(seconds: 3));
      expect(cooldown.ready, isTrue);
    });
  });

  group('лента с подгрузкой по скроллу', () {
    test('упавшая страница не запрашивается на каждое движение пальца',
        () async {
      final feed = _Feed();
      feed.load();
      await _pump();
      expect(feed.requested, [1]);

      feed.failWith = _status(500);
      for (var frame = 0; frame < 120; frame++) {
        feed.load();
        await _pump();
      }

      expect(feed.requested, [1, 2]);
      feed.dispose();
    });

    test('после 429 лента молчит, пока палец продолжает двигаться', () async {
      final feed = _Feed()..failWith = _status(429, retryAfter: '30');

      for (var frame = 0; frame < 120; frame++) {
        feed.load();
        await _pump();
      }

      expect(feed.requested, [1]);
      feed.dispose();
    });

    test('человек потянул ленту вниз — запрос уходит сразу', () async {
      final feed = _Feed()..failWith = _status(500);
      feed.load();
      await _pump();
      feed.load();
      await _pump();
      expect(feed.requested, [1]);

      feed.failWith = null;
      feed.load(refresh: true);
      await _pump();

      expect(feed.requested, [1, 1]);
      expect(feed.data, [1]);
      feed.dispose();
    });

    test('удачная страница снимает паузу: следующая грузится без ожидания',
        () async {
      final feed = _Feed();
      for (var i = 0; i < 3; i++) {
        feed.load();
        await _pump();
      }

      expect(feed.requested, [1, 2, 3]);
      feed.dispose();
    });
  });
}
