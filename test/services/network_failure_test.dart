import 'dart:async';
import 'dart:io';

import 'package:buking/services/network_failure.dart';
import 'package:buking/services/telemetry/telemetry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

final _options = RequestOptions(path: '/app/version-check');

DioException _noAnswer(DioExceptionType type, {Object? error}) =>
    DioException(requestOptions: _options, type: type, error: error);

DioException _answer(int status, {Object? body}) => DioException(
      requestOptions: _options,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: _options,
        statusCode: status,
        data: body,
      ),
    );

const _fast = Duration(milliseconds: 300);
const _slow = Duration(seconds: 10);
const _html = '<html><body>Gateway Time-out</body></html>';

void main() {
  group('нет ответа — это «нет сети», что бы ни говорил системный детектор', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
    ]) {
      test(type.name, () {
        final failure = NetworkFailure.of(_noAnswer(type));

        expect(failure.kind, NetworkFailureKind.noNetwork);
        expect(failure.statusCode, 0);
        expect(failure.isOffline, isTrue);
        expect(failure.provesOffline, isTrue);
        expect(failure.isRealFailure, isFalse);
        expect(failure.mayRetry, isTrue);
      });
    }

    test('обрыв без статуса и без «сетевого» типа ошибки', () {
      final failure = NetworkFailure.of(_noAnswer(
        DioExceptionType.unknown,
        error: const HandshakeException('Connection terminated'),
      ));

      expect(failure.kind, NetworkFailureKind.noNetwork);
      expect(failure.isOffline, isTrue);
      expect(failure.isRealFailure, isFalse);
    });

    test('оборванный сокет закрывает приложение экраном «нет сети»', () {
      final failure = NetworkFailure.of(_noAnswer(
        DioExceptionType.unknown,
        error: const SocketException('Connection reset by peer'),
      ));

      expect(failure.provesOffline, isTrue);
    });

    test('сбой сертификата — не повод закрывать всё приложение', () {
      final failure =
          NetworkFailure.of(_noAnswer(DioExceptionType.badCertificate));

      expect(failure.isOffline, isTrue);
      expect(failure.provesOffline, isFalse);
    });
  });

  group('5xx быстрее двух секунд — ответ посредника, а не сервера', () {
    test('«504» за 300 мс', () {
      final failure =
          NetworkFailure.of(_answer(504, body: _html), elapsed: _fast);

      expect(failure.kind, NetworkFailureKind.intermediary);
      expect(failure.statusCode, 504);
      expect(failure.isOffline, isTrue);
      expect(failure.isRealFailure, isFalse);
      expect(failure.provesOnline, isFalse);
      expect(failure.provesOffline, isFalse);
    });

    test('«502» с пустым телом', () {
      final failure = NetworkFailure.of(_answer(502), elapsed: _fast);

      expect(failure.kind, NetworkFailureKind.intermediary);
    });

    test('«504» остаётся подделкой, даже если тело похоже на JSON', () {
      final failure = NetworkFailure.of(
        _answer(504, body: {'message': 'Gateway Timeout'}),
        elapsed: _fast,
      );

      expect(failure.kind, NetworkFailureKind.intermediary);
    });

    test('скорость берётся из отметки начала запроса', () {
      final options = RequestOptions(path: '/app/config')
        ..extra[NetworkFailure.startedAtKey] = DateTime.now();
      final failure = NetworkFailure.of(DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
            requestOptions: options, statusCode: 504, data: _html),
      ));

      expect(failure.kind, NetworkFailureKind.intermediary);
    });
  });

  group('настоящие сбои остаются сбоями', () {
    test('5xx после полноценного ожидания', () {
      final failure =
          NetworkFailure.of(_answer(504, body: _html), elapsed: _slow);

      expect(failure.kind, NetworkFailureKind.server);
      expect(failure.isOffline, isFalse);
      expect(failure.isRealFailure, isTrue);
      expect(failure.provesOnline, isTrue);
    });

    test('быстрый 500 с телом нашего API — упал обработчик на сервере', () {
      final failure = NetworkFailure.of(
        _answer(500, body: {'message': 'Server Error'}),
        elapsed: _fast,
      );

      expect(failure.kind, NetworkFailureKind.server);
      expect(failure.isRealFailure, isTrue);
    });

    test('без отметки времени 5xx считается настоящим', () {
      final failure = NetworkFailure.of(_answer(503, body: _html));

      expect(failure.kind, NetworkFailureKind.server);
    });

    test('ошибка в нашем коде не прячется под «нет сети»', () {
      final failure = NetworkFailure.of(_noAnswer(
        DioExceptionType.unknown,
        error: StateError('boom'),
      ));

      expect(failure.kind, NetworkFailureKind.internal);
      expect(failure.isOffline, isFalse);
      expect(failure.isRealFailure, isTrue);
      expect(failure.mayRetry, isFalse);
    });
  });

  test('429 — просьба сбавить темп, а не сбой и не обрыв', () {
    final failure = NetworkFailure.of(_answer(429), elapsed: _fast);

    expect(failure.kind, NetworkFailureKind.rateLimited);
    expect(failure.isOffline, isFalse);
    expect(failure.isRealFailure, isFalse);
    expect(failure.mayRetry, isFalse);
    expect(failure.provesOnline, isTrue);
  });

  test('4xx — чинить надо запрос: повторять нельзя', () {
    final failure = NetworkFailure.of(_answer(422), elapsed: _fast);

    expect(failure.kind, NetworkFailureKind.rejected);
    expect(failure.mayRetry, isFalse);
    expect(failure.provesOnline, isTrue);
  });

  test('отмена — наше собственное решение', () {
    final failure = NetworkFailure.of(_noAnswer(DioExceptionType.cancel));

    expect(failure.kind, NetworkFailureKind.cancelled);
    expect(failure.isOffline, isFalse);
    expect(failure.isRealFailure, isFalse);
    expect(failure.mayRetry, isFalse);
  });

  group('обрыв связи вне общего Dio — тоже не ошибка приложения', () {
    test('сырые исключения сокета, TLS, HTTP и таймаута', () {
      for (final Object error in [
        const SocketException('Failed host lookup'),
        const HandshakeException('terminated'),
        const HttpException('Connection closed before full header'),
        const WebSocketException('Connection not upgraded'),
        TimeoutException('no answer'),
      ]) {
        expect(NetworkFailure.isConnectivity(error), isTrue,
            reason: error.runtimeType.toString());
      }
    });

    test('Dio: обрыв и отмена — да, ответ сервера — нет', () {
      expect(
        NetworkFailure.isConnectivity(
            _noAnswer(DioExceptionType.connectionError)),
        isTrue,
      );
      expect(
        NetworkFailure.isConnectivity(_noAnswer(DioExceptionType.cancel)),
        isTrue,
      );
      expect(
        NetworkFailure.isConnectivity(_answer(500, body: {'message': 'x'})),
        isFalse,
      );
      expect(NetworkFailure.isConnectivity(_answer(422)), isFalse);
    });

    test('сбой диска и ошибка в коде остаются ошибками', () {
      expect(
        NetworkFailure.isConnectivity(
            const FileSystemException('No space left on device')),
        isFalse,
      );
      expect(NetworkFailure.isConnectivity(StateError('boom')), isFalse);
      expect(NetworkFailure.isConnectivity(const FormatException('bad')),
          isFalse);
    });
  });

  group('что уходит в панель телеметрии', () {
    test('обрыв связи — предупреждение с is_offline, без отчёта об ошибке', () {
      for (final err in [
        _noAnswer(DioExceptionType.connectionTimeout),
        _noAnswer(DioExceptionType.receiveTimeout),
        _noAnswer(DioExceptionType.connectionError),
        _noAnswer(DioExceptionType.unknown,
            error: const HandshakeException('terminated')),
        _noAnswer(DioExceptionType.badCertificate),
      ]) {
        final verdict = TelemetryInterceptor.verdictFor(err, _slow);

        expect(verdict.isOffline, isTrue, reason: err.type.name);
        expect(verdict.severity, 'warning', reason: err.type.name);
        expect(verdict.report, isFalse, reason: err.type.name);
      }
    });

    test('«504» за 300 мс — тоже «нет сети»', () {
      final verdict =
          TelemetryInterceptor.verdictFor(_answer(504, body: _html), _fast);

      expect(verdict.isOffline, isTrue);
      expect(verdict.severity, 'warning');
      expect(verdict.report, isFalse);
    });

    test('5xx после полноценного ожидания — ошибка', () {
      final verdict =
          TelemetryInterceptor.verdictFor(_answer(504, body: _html), _slow);

      expect(verdict.isOffline, isFalse);
      expect(verdict.severity, 'error');
      expect(verdict.report, isTrue);
    });

    test('429 и обычная валидация — не ошибки', () {
      for (final status in [429, 401, 404, 422]) {
        final verdict =
            TelemetryInterceptor.verdictFor(_answer(status), _fast);

        expect(verdict.isOffline, isFalse, reason: '$status');
        expect(verdict.severity, 'warning', reason: '$status');
        expect(verdict.report, isFalse, reason: '$status');
      }
    });

    test('неожиданный 4xx попадает в отчёты', () {
      final verdict = TelemetryInterceptor.verdictFor(_answer(400), _fast);

      expect(verdict.report, isTrue);
    });
  });

  group('Retry-After', () {
    final now = DateTime.utc(2026, 10, 13, 12);

    test('число секунд и дата', () {
      expect(NetworkFailure.retryAfter('30', now), const Duration(seconds: 30));
      expect(
        NetworkFailure.retryAfter('Tue, 13 Oct 2026 12:02:00 GMT', now),
        const Duration(minutes: 2),
      );
    });

    test('мусор, ноль и прошедшая дата — срок не назван', () {
      for (final header in [null, '', 'soon', '0', '-5',
          'Tue, 13 Oct 2026 11:00:00 GMT']) {
        expect(NetworkFailure.retryAfter(header, now), isNull,
            reason: '$header');
      }
    });

    test('больше часа сервер не попросит — это мусор, обрезаем', () {
      expect(NetworkFailure.retryAfter('86400', now),
          NetworkFailure.maxRetryAfter);
    });

    test('заголовок продублирован — одной строкой или двумя', () {
      expect(NetworkFailure.retryAfter('30, 30', now),
          const Duration(seconds: 30));

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 429,
        headers: Headers.fromMap({
          'retry-after': ['30', '30'],
        }),
      );
      expect(NetworkFailure.retryAfterOf(response, now),
          const Duration(seconds: 30));
      expect(NetworkFailure.retryAfterOf(null, now), isNull);
    });
  });
}
