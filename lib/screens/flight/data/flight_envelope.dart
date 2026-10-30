import 'flight_json.dart';

/// `meta` модуля рейсов (§4.2, §4.3).
///
/// `stale: true` — не ошибка: провайдер не ответил или кончился месячный
/// бюджет, и сервер отдал последнюю известную копию. Экран рисуется как
/// обычно, сверху — полоска со временем из [fetchedAt].
///
/// `unavailableReason` приходит вместе с `data: null`: такого вида данных у
/// этого аэропорта/рейса нет в принципе. Текст — сообщение провайдера как
/// есть, обрезанное сервером до 300 символов; пользователю он не показывается
/// (для него есть своя спокойная фраза), но пригождается в журнале.
class FlightMeta {
  final bool cached;
  final bool stale;
  final DateTime? fetchedAt;
  final String? unavailableReason;

  /// Только у табло (#14) и у окон статистики задержек: фактическое окно,
  /// которое сервер выбрал сам.
  final String? from;
  final String? to;
  final String? direction;

  const FlightMeta({
    this.cached = false,
    this.stale = false,
    this.fetchedAt,
    this.unavailableReason,
    this.from,
    this.to,
    this.direction,
  });

  static const empty = FlightMeta();

  factory FlightMeta.fromJson(Map<String, dynamic> json) => FlightMeta(
        cached: jBool(json['cached']),
        stale: jBool(json['stale']),
        fetchedAt: jUtc(json['fetched_at']),
        unavailableReason: jString(json['unavailable_reason']),
        from: jString(json['from']),
        to: jString(json['to']),
        direction: jString(json['direction']),
      );

  bool get hasFetchedAt => fetchedAt != null;
}

/// Конверт успеха модуля: `{data, meta?, message?}`.
///
/// [data] может быть `null` — это §4.3, а не сбой.
class FlightEnvelope<T> {
  final T? data;
  final FlightMeta meta;
  final String? message;

  const FlightEnvelope({this.data, this.meta = FlightMeta.empty, this.message});

  /// `data: null` + `meta.unavailable_reason` — спокойный пустой экран.
  bool get isUnavailable => data == null;

  FlightEnvelope<R> map<R>(R Function(T value) convert) => FlightEnvelope<R>(
        data: data == null ? null : convert(data as T),
        meta: meta,
        message: message,
      );

  static FlightEnvelope<T> parse<T>(
    Map<String, dynamic> json,
    T? Function(Object? raw) convert,
  ) {
    final rawMeta = jMap(json['meta']);
    return FlightEnvelope<T>(
      data: convert(json['data']),
      meta: rawMeta == null ? FlightMeta.empty : FlightMeta.fromJson(rawMeta),
      message: jString(json['message']),
    );
  }
}
