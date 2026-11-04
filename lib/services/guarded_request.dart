import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import 'network_failure.dart';

enum GuardedOutcome {
  success,

  noNetwork,

  rateLimited,

  rejected,

  serverError,
}

class GuardedResult {
  const GuardedResult(this.outcome, {this.data, this.attempts = 0});

  final GuardedOutcome outcome;

  final Map<String, dynamic>? data;

  final int attempts;

  bool get isSuccess => outcome == GuardedOutcome.success;
}

class GuardedRequest {
  GuardedRequest({
    required this.dio,
    this.connectTimeout = const Duration(seconds: 5),
    this.receiveTimeout = const Duration(seconds: 10),
    this.totalBudget = const Duration(seconds: 20),
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 3),
      Duration(seconds: 9),
    ],
    this.jitter = 0.2,
    this.rateLimitPause = const Duration(minutes: 1),
    DateTime Function()? clock,
    Future<void> Function(Duration)? sleep,
    Random? random,
  })  : _now = clock ?? DateTime.now,
        _sleep = sleep ?? Future<void>.delayed,
        _random = random ?? Random();

  final Dio Function() dio;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration totalBudget;
  final List<Duration> retryDelays;

  final double jitter;
  final Duration rateLimitPause;

  final DateTime Function() _now;
  final Future<void> Function(Duration) _sleep;
  final Random _random;

  DateTime? _blockedUntil;

  DateTime? get blockedUntil => _blockedUntil;

  Future<GuardedResult> get(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final startedAt = _now();
    final blockedUntil = _blockedUntil;
    if (blockedUntil != null && startedAt.isBefore(blockedUntil)) {
      return const GuardedResult(GuardedOutcome.rateLimited);
    }

    final deadline = startedAt.add(totalBudget);
    var attempts = 0;
    var outcome = GuardedOutcome.noNetwork;
    var reported = false;

    while (true) {
      final remaining = deadline.difference(_now());
      if (remaining <= Duration.zero) break;

      attempts++;
      try {
        final data = await _send(url, query, attempts, remaining, reported);
        if (data != null) {
          return GuardedResult(GuardedOutcome.success,
              data: data, attempts: attempts);
        }
        outcome = GuardedOutcome.noNetwork;
      } on DioException catch (e) {
        final failure = NetworkFailure.of(e);
        if (failure.kind == NetworkFailureKind.rateLimited) {
          final now = _now();
          final asked = NetworkFailure.retryAfterOf(e.response, now);
          _blockedUntil = now.add(asked ?? rateLimitPause);
          return GuardedResult(GuardedOutcome.rateLimited, attempts: attempts);
        }
        if (failure.kind == NetworkFailureKind.cancelled) {
          return GuardedResult(GuardedOutcome.noNetwork, attempts: attempts);
        }
        if (!failure.mayRetry) {
          return GuardedResult(GuardedOutcome.rejected, attempts: attempts);
        }
        if (failure.kind == NetworkFailureKind.server) {
          reported = true;
          outcome = GuardedOutcome.serverError;
        } else {
          outcome = GuardedOutcome.noNetwork;
        }
      } catch (_) {
        return GuardedResult(GuardedOutcome.rejected, attempts: attempts);
      }

      final retryIndex = attempts - 1;
      if (retryIndex >= retryDelays.length) break;
      final pause = _withJitter(retryDelays[retryIndex]);
      if (!_now().add(pause).isBefore(deadline)) break;
      await _sleep(pause);
    }

    return GuardedResult(outcome, attempts: attempts);
  }

  Future<Map<String, dynamic>?> _send(
    String url,
    Map<String, dynamic>? query,
    int attempt,
    Duration remaining,
    bool reported,
  ) async {
    final client = dio();
    final cancelToken = CancelToken();
    final watchdog = Timer(remaining, () => cancelToken.cancel('deadline'));
    try {
      final options = Options(
        method: 'GET',
        receiveTimeout: _shorter(receiveTimeout, remaining),
        extra: {
          NetworkFailure.attemptKey: attempt,
          if (reported) NetworkFailure.reportedKey: true,
        },
      )
          .compose(
            client.options,
            url,
            queryParameters: query,
            cancelToken: cancelToken,
          )
          .copyWith(connectTimeout: _shorter(connectTimeout, remaining));
      final response = await client.fetch<dynamic>(options);
      final data = response.data;
      if (data is! Map) return null;
      return data.map((key, value) => MapEntry(key.toString(), value));
    } finally {
      watchdog.cancel();
    }
  }

  Duration _shorter(Duration a, Duration b) => a < b ? a : b;

  Duration _withJitter(Duration base) {
    if (jitter <= 0) return base;
    final factor = 1 - jitter + _random.nextDouble() * 2 * jitter;
    return Duration(milliseconds: (base.inMilliseconds * factor).round());
  }
}
