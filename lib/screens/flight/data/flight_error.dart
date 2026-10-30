import 'package:dio/dio.dart';

import '../../../services/api_error.dart';

/// Ошибка модуля рейсов — разобранная по §12 «ответ → что показать».
///
/// Главное, что этот класс закрывает: `meta.stale: true` и
/// `data: null + meta.unavailable_reason` ошибками **не являются** и сюда не
/// попадают вообще — они приходят внутри успешного конверта. Настоящая ошибка
/// данных одна: `503 FLIGHT_DATA_UNAVAILABLE`.
class FlightError implements Exception {
  final ApiError api;

  /// `errors.reason[0]` у 503 — слова источника. На экран не выводится,
  /// нужно для журнала.
  final String? reason;

  /// `retry_after` из тела 429 (секунды). Заголовок `Retry-After` разбирает
  /// [ApiError], тело — здесь.
  final Duration? bodyRetryAfter;

  const FlightError(this.api, {this.reason, this.bodyRetryAfter});

  factory FlightError.from(Object error) {
    final api = ApiError.from(error);
    String? reason;
    Duration? retry;

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map) {
          final raw = errors['reason'];
          if (raw is List && raw.isNotEmpty) {
            reason = raw.first?.toString();
          } else if (raw != null) {
            reason = raw.toString();
          }
        }
        final seconds = data['retry_after'];
        final parsed = seconds is num
            ? seconds.round()
            : int.tryParse(seconds?.toString() ?? '');
        if (parsed != null && parsed > 0) retry = Duration(seconds: parsed);
      }
    }

    return FlightError(api, reason: reason, bodyRetryAfter: retry);
  }

  /// `404 NOT_FOUND` — мягкая: «такой рейс/аэропорт не найден».
  bool get isNotFound => api.code == 'NOT_FOUND' || api.statusCode == 404;

  /// `422 VALIDATION_ERROR` — в этом модуле почти всегда формат даты или
  /// `from` без `to`.
  bool get isValidation => api.isValidation;

  /// `429 RATE_LIMITED` — временная, экран ожидания с отсчётом.
  bool get isRateLimited => api.isRateLimited;

  /// `503 FLIGHT_DATA_UNAVAILABLE` — единственная настоящая ошибка данных.
  bool get isServiceDown =>
      api.code == 'FLIGHT_DATA_UNAVAILABLE' || api.statusCode == 503;

  /// `401 UNAUTHENTICATED` — только на эндпоинтах слежения.
  bool get isUnauthenticated => api.isUnauthenticated;

  bool get isNetwork => api.noConnection || api.timeout;

  Duration? get retryAfter => api.retryAfter ?? bodyRetryAfter;

  /// Сколько секунд осталось ждать — для отсчёта на экране.
  int get retrySeconds {
    final d = retryAfter;
    if (d == null) return 0;
    final s = d.inSeconds;
    return s < 0 ? 0 : s;
  }

  Map<String, String> get fieldErrors => api.fieldErrors;

  /// Сообщение сервера, если оно есть. Своё придумывается только когда
  /// сервер ничего не сказал.
  String display([String? fallback]) => api.display(fallback);

  @override
  String toString() =>
      'FlightError(${api.statusCode} ${api.code}: ${api.message})';
}
