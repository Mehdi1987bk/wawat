import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import '../network_failure.dart';
import 'api_event_map.dart';
import 'telemetry.dart';
import 'telemetry_events.dart';
import 'telemetry_redactor.dart';

class TelemetryInterceptor extends Interceptor {
  TelemetryInterceptor({this.slowRequestThreshold = const Duration(seconds: 3)});

  final Duration slowRequestThreshold;

  static const _startedAtKey = NetworkFailure.startedAtKey;
  static const _metricKey = 'telemetry_http_metric';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();
    final metric = Telemetry.instance.newHttpMetric(
      options.uri.toString(),
      _httpMethod(options.method),
    );
    if (metric != null) {
      options.extra[_metricKey] = metric;
      metric.start().catchError((_) {});
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final duration = _durationOf(options);
    final endpoint = TelemetryRedactor.endpoint(options.path);
    final status = response.statusCode ?? 0;

    _stopMetric(options, status, response.data);

    Telemetry.instance.breadcrumb(
        'http ${options.method} $endpoint $status ${duration.inMilliseconds}ms');

    final mapping = mappingFor(options.method, endpoint);
    if (mapping?.onSuccess != null) {
      Telemetry.instance.event(mapping!.onSuccess!, params: {
        ...mapping.extraParams,
        TelemetryParams.endpoint: endpoint,
        TelemetryParams.durationMs: duration.inMilliseconds,
        ..._idParams(options.path),
      });
    }

    if (duration > slowRequestThreshold) {
      Telemetry.instance.event(
        TelemetryEvents.apiSlow,
        params: {
          TelemetryParams.endpoint: endpoint,
          TelemetryParams.httpMethod: options.method,
          TelemetryParams.durationMs: duration.inMilliseconds,
          TelemetryParams.statusCode: status,
        },
        severity: 'warning',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.cancel) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    final duration = _durationOf(options);
    final endpoint = TelemetryRedactor.endpoint(options.path);
    final status = err.response?.statusCode ?? 0;
    final verdict = verdictFor(err, duration);

    _stopMetric(options, status, err.response?.data);

    Telemetry.instance.breadcrumb(
        'http-error ${options.method} $endpoint ${status == 0 ? err.type.name : status} ${duration.inMilliseconds}ms');

    final params = <String, Object?>{
      TelemetryParams.endpoint: endpoint,
      TelemetryParams.httpMethod: options.method,
      TelemetryParams.statusCode: status,
      TelemetryParams.durationMs: duration.inMilliseconds,
      TelemetryParams.errorType: err.type.name,
      TelemetryParams.errorMessage: _shortMessage(err),
      TelemetryParams.isOffline: verdict.isOffline,
      TelemetryParams.failureKind: verdict.kind,
    };
    final attempt = options.extra[NetworkFailure.attemptKey];
    if (attempt is int) params[TelemetryParams.attempt] = attempt;

    Telemetry.instance.event(
      TelemetryEvents.apiFailure,
      params: params,
      severity: verdict.severity,
    );

    final mapping = mappingFor(options.method, endpoint);
    if (mapping?.onFailure != null) {
      Telemetry.instance.event(mapping!.onFailure!, params: {
        ...mapping.extraParams,
        TelemetryParams.endpoint: endpoint,
        TelemetryParams.statusCode: status,
        TelemetryParams.reason: err.type.name,
      });
    }

    if (status == 401 || status == 402) {
      Telemetry.instance.event(TelemetryEvents.sessionExpired,
          params: {TelemetryParams.endpoint: endpoint});
    }

    if (verdict.report && options.extra[NetworkFailure.reportedKey] != true) {
      Telemetry.instance.error(
        err,
        err.stackTrace,
        reason: 'api $status ${options.method} $endpoint',
        context: params,
      );
    }

    handler.next(err);
  }

  @visibleForTesting
  static ({bool isOffline, String severity, bool report, String kind})
      verdictFor(
    DioException err,
    Duration duration,
  ) {
    final failure = NetworkFailure.of(err, elapsed: duration);
    return (
      kind: failure.kind.name,
      isOffline: failure.isOffline,
      severity: failure.isRealFailure ? 'error' : 'warning',
      report: failure.isRealFailure ||
          (failure.kind == NetworkFailureKind.rejected &&
              _isUnexpected(failure.statusCode)),
    );
  }

  Duration _durationOf(RequestOptions options) {
    final started = options.extra[_startedAtKey];
    if (started is DateTime) return DateTime.now().difference(started);
    return Duration.zero;
  }

  void _stopMetric(RequestOptions options, int status, Object? payload) {
    final metric = options.extra[_metricKey];
    if (metric is! HttpMetric) return;
    try {
      metric.httpResponseCode = status;
      if (payload is String) {
        metric.responsePayloadSize = payload.length;
      }
      metric.stop().catchError((_) {});
    } catch (_) {
    } finally {
      options.extra.remove(_metricKey);
    }
  }

  Map<String, Object?> _idParams(String path) {
    final match = RegExp(r'/(?:listings|offers)/(\d+)').firstMatch(path);
    if (match == null) return const {};
    return {TelemetryParams.listingId: match.group(1)};
  }

  static bool _isUnexpected(int status) =>
      status >= 400 &&
      status < 500 &&
      status != 401 &&
      status != 402 &&
      status != 403 &&
      status != 404 &&
      status != 409 &&
      status != 422 &&
      status != 429;

  String _shortMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map && data['message'] is String) {
      return TelemetryRedactor.redact(data['message'] as String, maxLength: 160);
    }
    return TelemetryRedactor.redact(err.message ?? err.type.name,
        maxLength: 160);
  }

  HttpMethod _httpMethod(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      case 'PATCH':
        return HttpMethod.Patch;
      case 'HEAD':
        return HttpMethod.Head;
      case 'OPTIONS':
        return HttpMethod.Options;
      case 'CONNECT':
        return HttpMethod.Connect;
      case 'TRACE':
        return HttpMethod.Trace;
      default:
        return HttpMethod.Get;
    }
  }
}
