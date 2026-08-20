import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

import 'api_event_map.dart';
import 'telemetry.dart';
import 'telemetry_events.dart';
import 'telemetry_redactor.dart';

/// Перехватчик Dio: превращает сетевой трафик в телеметрию.
///
/// Делает четыре вещи одновременно:
///  1. **Воронка** — успешный `POST /listings` становится событием
///     `listing_created` (таблица в [mappingFor]);
///  2. **Здоровье API** — каждая ошибка уходит в панель с эндпоинтом, кодом и
///     длительностью; 5xx дополнительно попадают в Crashlytics как non-fatal;
///  3. **Производительность** — `HttpMetric` для Firebase Performance, потому
///     что автоматическая инструментализация не видит трафик Dart;
///  4. **Хлебные крошки** — последние запросы прикрепляются к отчёту о падении.
///
/// Ставится **последним** в цепочке, чтобы видеть запрос уже с заголовками,
/// которые проставил `CallInterceptor`, и все ошибки, которые тот пропустил
/// дальше по цепочке.
class TelemetryInterceptor extends Interceptor {
  TelemetryInterceptor({this.slowRequestThreshold = const Duration(seconds: 3)});

  /// Порог «медленного» запроса. 3 с — это уже заметная пауза в UI.
  final Duration slowRequestThreshold;

  static const _startedAtKey = 'telemetry_started_at';
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
      // start() асинхронный, но ждать его незачем — запрос не должен
      // простаивать из-за метрики.
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
    final options = err.requestOptions;
    final duration = _durationOf(options);
    final endpoint = TelemetryRedactor.endpoint(options.path);
    final status = err.response?.statusCode ?? 0;
    final isNetwork = _isNetworkProblem(err);

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
      TelemetryParams.isOffline: isNetwork,
    };

    // Серверные 5xx — «чинить срочно», клиентские и обрывы связи — «смотреть».
    // Панель ранжирует по этому весу, поэтому не оставляем всё как info.
    Telemetry.instance.event(
      TelemetryEvents.apiFailure,
      params: params,
      severity: (status >= 500 || status == 0) && !isNetwork ? 'error' : 'warning',
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

    // В Crashlytics отправляем только то, что действительно нужно чинить:
    // серверные 5xx и неожиданные клиентские ошибки. Обрывы связи и 4xx —
    // это состояние сети и валидация, они утопили бы отчёты в шуме.
    final worthReporting =
        !isNetwork && (status >= 500 || status == 0 || _isUnexpected(status));
    if (worthReporting) {
      Telemetry.instance.error(
        err,
        err.stackTrace,
        reason: 'api $status ${options.method} $endpoint',
        context: params,
      );
    }

    handler.next(err);
  }

  // ── Вспомогательное ─────────────────────────────────────────────────────

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
      // Метрика — необязательная роскошь, ошибки в ней глотаем.
    } finally {
      options.extra.remove(_metricKey);
    }
  }

  /// Пробрасывает id ресурса в событие: `/listings/8123/favorite` → 8123.
  /// Без этого нельзя связать событие с конкретным объявлением в панели.
  Map<String, Object?> _idParams(String path) {
    final match = RegExp(r'/(?:listings|offers)/(\d+)').firstMatch(path);
    if (match == null) return const {};
    return {TelemetryParams.listingId: match.group(1)};
  }

  bool _isNetworkProblem(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        return false;
    }
  }

  /// 4xx, которые не являются нормальной частью работы приложения.
  /// 401/402 (сессия), 403, 404, 422 (валидация) — ожидаемы и обрабатываются
  /// в UI, поэтому не считаются багом.
  bool _isUnexpected(int status) =>
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
