import 'package:dio/dio.dart';

import 'network_failure.dart';

class RetryCooldown {
  RetryCooldown({
    this.pauses = const [
      Duration(seconds: 3),
      Duration(seconds: 10),
      Duration(seconds: 30),
    ],
    this.rateLimitPause = const Duration(minutes: 1),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final List<Duration> pauses;

  final Duration rateLimitPause;

  final DateTime Function() _now;

  int _failures = 0;
  DateTime? _notBefore;

  bool get ready {
    final notBefore = _notBefore;
    return notBefore == null || !_now().isBefore(notBefore);
  }

  void failed(Object error) {
    final now = _now();
    _failures++;
    var pause = pauses[(_failures - 1).clamp(0, pauses.length - 1)];
    if (error is DioException && error.response?.statusCode == 429) {
      pause = NetworkFailure.retryAfterOf(error.response, now) ?? rateLimitPause;
    }
    _notBefore = now.add(pause);
  }

  void reset() {
    _failures = 0;
    _notBefore = null;
  }
}
