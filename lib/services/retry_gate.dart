import 'dart:async';

import 'package:dio/dio.dart';

import 'network_failure.dart';

class RetryGate extends Interceptor {
  RetryGate({
    DateTime Function()? clock,
    Future<void> Function(Duration)? sleep,
  })  : _now = clock ?? DateTime.now,
        _sleep = sleep ?? Future<void>.delayed;

  static const connectionPause = Duration(seconds: 1);

  static const serverPauses = [
    Duration(seconds: 1),
    Duration(seconds: 3),
    Duration(seconds: 9),
  ];

  static const _forgetAfter = Duration(minutes: 1);

  static const _maxRemembered = 200;

  final DateTime Function() _now;
  final Future<void> Function(Duration) _sleep;

  final _failed = <String, _Failed>{};

  final _limited = <String, _Limited>{};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    DioException? refusal;
    try {
      if (!_hasOwnRetries(options)) {
        refusal = _refusalFor(options);
        if (refusal == null) {
          final wait = _waitFor(options);
          if (wait > Duration.zero) await _sleep(wait);
        }
      }
    } catch (_) {
      refusal = null;
    }
    if (refusal != null) {
      return handler.reject(refusal);
    }
    return handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _failed.remove(_requestKey(response.requestOptions));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      _remember(err);
    } catch (_) {
    }
    handler.next(err);
  }

  bool _hasOwnRetries(RequestOptions options) =>
      options.extra.containsKey(NetworkFailure.attemptKey);

  DioException? _refusalFor(RequestOptions options) {
    if (!_isRead(options)) return null;
    final key = _routeKey(options);
    final limited = _limited[key];
    if (limited == null) return null;
    final left = limited.until.difference(_now());
    if (left <= Duration.zero || left > limited.asked) {
      _limited.remove(key);
      return null;
    }
    final answer = limited.answer;
    return DioException.badResponse(
      statusCode: answer.statusCode ?? 429,
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: answer.statusCode,
        statusMessage: answer.statusMessage,
        headers: Headers.fromMap({
          ...answer.headers.map,
          'retry-after': ['${(left.inMilliseconds / 1000).ceil()}'],
        }),
        data: answer.data,
      ),
    );
  }

  Duration _waitFor(RequestOptions options) {
    final failed = _failed[_requestKey(options)];
    if (failed == null) return Duration.zero;
    final wait = failed.at.add(failed.pause).difference(_now());
    return wait > failed.pause ? failed.pause : wait;
  }

  void _remember(DioException err) {
    final options = err.requestOptions;
    if (_hasOwnRetries(options)) return;

    final failure = NetworkFailure.of(err);
    final key = _requestKey(options);
    final now = _now();
    switch (failure.kind) {
      case NetworkFailureKind.cancelled:
      case NetworkFailureKind.internal:
        return;
      case NetworkFailureKind.rejected:
        _failed.remove(key);
        return;
      case NetworkFailureKind.rateLimited:
        final asked = NetworkFailure.retryAfterOf(err.response, now);
        final response = err.response;
        if (asked != null && response != null && _isRead(options)) {
          _failed.remove(key);
          _limited[_routeKey(options)] =
              _Limited(now.add(asked), asked, response);
          _trim(_limited);
          return;
        }
        _fail(key, now, climbs: true);
        return;
      case NetworkFailureKind.server:
        _fail(key, now, climbs: true);
        return;
      case NetworkFailureKind.noNetwork:
      case NetworkFailureKind.intermediary:
        _fail(key, now, climbs: false);
        return;
    }
  }

  void _fail(String key, DateTime now, {required bool climbs}) {
    final previous = _failed.remove(key);
    if (climbs &&
        previous != null &&
        previous.streak > 0 &&
        !now.isBefore(previous.at) &&
        now.isBefore(previous.at.add(previous.pause))) {
      _failed[key] = previous;
      return;
    }
    final fresh =
        previous != null && now.difference(previous.at) < _forgetAfter;
    final streak = climbs ? (fresh ? previous.streak : 0) + 1 : 0;
    final pause = climbs
        ? serverPauses[(streak - 1).clamp(0, serverPauses.length - 1)]
        : connectionPause;
    _failed[key] = _Failed(now, streak, pause);
    _trim(_failed);
  }

  void _trim(Map<String, Object> remembered) {
    while (remembered.length > _maxRemembered) {
      remembered.remove(remembered.keys.first);
    }
  }

  bool _isRead(RequestOptions options) => options.method.toUpperCase() == 'GET';

  String _requestKey(RequestOptions options) =>
      '${options.method.toUpperCase()} ${options.uri}';

  String _routeKey(RequestOptions options) {
    final uri = options.uri;
    return '${uri.host}${uri.path}';
  }
}

class _Failed {
  const _Failed(this.at, this.streak, this.pause);

  final DateTime at;

  final int streak;
  final Duration pause;
}

class _Limited {
  const _Limited(this.until, this.asked, this.answer);

  final DateTime until;

  final Duration asked;
  final Response<dynamic> answer;
}
