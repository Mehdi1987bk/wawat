import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' show ClientException;

enum NetworkFailureKind {
  cancelled,

  noNetwork,

  intermediary,

  rateLimited,

  rejected,

  server,

  internal,
}

class NetworkFailure {
  const NetworkFailure._(
    this.kind, {
    this.statusCode = 0,
    this.provesOffline = false,
  });

  static const startedAtKey = 'telemetry_started_at';

  static const attemptKey = 'request_attempt';

  static const reportedKey = 'request_failure_reported';

  static const fakeAnswerWindow = Duration(seconds: 2);

  static const maxRetryAfter = Duration(hours: 1);

  final NetworkFailureKind kind;

  final int statusCode;

  final bool provesOffline;

  bool get isOffline =>
      kind == NetworkFailureKind.noNetwork ||
      kind == NetworkFailureKind.intermediary;

  bool get provesOnline =>
      kind == NetworkFailureKind.rateLimited ||
      kind == NetworkFailureKind.rejected ||
      kind == NetworkFailureKind.server;

  bool get mayRetry => isOffline || kind == NetworkFailureKind.server;

  bool get isRealFailure =>
      kind == NetworkFailureKind.server || kind == NetworkFailureKind.internal;

  static bool isConnectivity(Object error) {
    if (error is DioException) {
      final failure = NetworkFailure.of(error);
      return failure.isOffline || failure.kind == NetworkFailureKind.cancelled;
    }
    return error is SocketException ||
        error is TlsException ||
        error is HttpException ||
        error is WebSocketException ||
        error is ClientException ||
        error is TimeoutException;
  }

  static bool isNoLink(Object error) {
    if (error is DioException) return NetworkFailure.of(error).isOffline;
    return error is SocketException || error is TlsException;
  }

  static Duration? retryAfter(String? header, DateTime now) {
    final raw = header?.trim();
    if (raw == null || raw.isEmpty) return null;

    Duration? pause;
    final seconds =
        int.tryParse(raw) ?? int.tryParse(raw.split(',').first.trim());
    if (seconds != null) {
      pause = Duration(seconds: seconds);
    } else {
      try {
        pause = HttpDate.parse(raw).difference(now.toUtc());
      } catch (_) {
        return null;
      }
    }
    if (pause <= Duration.zero) return null;
    return pause > maxRetryAfter ? maxRetryAfter : pause;
  }

  static Duration? retryAfterOf(Response<dynamic>? response, DateTime now) =>
      retryAfter(response?.headers['retry-after']?.firstOrNull, now);

  factory NetworkFailure.of(DioException err, {Duration? elapsed}) {
    if (err.type == DioExceptionType.cancel) {
      return const NetworkFailure._(NetworkFailureKind.cancelled);
    }

    final response = err.response;
    if (response == null) {
      if (err.type == DioExceptionType.unknown && err.error is Error) {
        return const NetworkFailure._(NetworkFailureKind.internal);
      }
      return NetworkFailure._(
        NetworkFailureKind.noNetwork,
        provesOffline: _isTransport(err),
      );
    }

    final status = response.statusCode ?? 0;
    if (status == 429) {
      return NetworkFailure._(NetworkFailureKind.rateLimited,
          statusCode: status);
    }
    if (status < 500) {
      return NetworkFailure._(NetworkFailureKind.rejected, statusCode: status);
    }

    final took = elapsed ?? _elapsedOf(err.requestOptions);
    if (took != null && took < fakeAnswerWindow && !_looksLikeOurs(response)) {
      return NetworkFailure._(NetworkFailureKind.intermediary,
          statusCode: status);
    }
    return NetworkFailure._(NetworkFailureKind.server, statusCode: status);
  }

  static bool _looksLikeOurs(Response<dynamic> response) =>
      response.statusCode != 504 && response.data is Map;

  static bool _isTransport(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        return err.error is SocketException;
    }
  }

  static Duration? _elapsedOf(RequestOptions options) {
    final started = options.extra[startedAtKey];
    if (started is DateTime) return DateTime.now().difference(started);
    return null;
  }
}
