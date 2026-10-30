import '../flight_json.dart';
import 'flight.dart';

/// Подписка на рейс (`GET /me/flight-watches`).
///
/// Рейс приходит **внутри** списка — он загружен заранее, и отдельный запрос
/// на каждый отслеживаемый рейс делать не нужно. Сервер сам обновляет
/// подписанный рейс (в воздухе каждые 90 секунд, за 2 часа до вылета каждые
/// 10 минут) и присылает push; опрашивать его в цикле нельзя.
class FlightWatch {
  final int? id;
  final List<String> events;

  /// Внутренний целочисленный id объявления. Эндпоинты объявлений работают с
  /// ULID `public_id`, поэтому открыть объявление по этому значению нельзя —
  /// это известный пробел бэкенда (§15).
  final int? listingId;

  final DateTime? mutedUntil;
  final DateTime? createdAt;
  final FlightSummary? flight;

  const FlightWatch({
    this.id,
    this.events = const [],
    this.listingId,
    this.mutedUntil,
    this.createdAt,
    this.flight,
  });

  factory FlightWatch.fromJson(Map<String, dynamic> json) {
    final flight = jMap(json['flight']);
    return FlightWatch(
      id: jInt(json['id']),
      events: jStringList(json['events']),
      listingId: jInt(json['listing_id']),
      mutedUntil: jUtc(json['muted_until']),
      createdAt: jUtc(json['created_at']),
      flight: flight == null ? null : FlightSummary.fromJson(flight),
    );
  }

  FlightKey? get key => flight?.key;

  bool isMuted(DateTime now) =>
      mutedUntil != null && mutedUntil!.isAfter(now.toUtc());
}

/// `GET /flight-data/health` — этим управляется предупреждающая полоска на
/// домашнем экране модуля: показывать её только при `degraded: true`.
class FlightDataHealth {
  final FeedState schedules;
  final FeedState live;
  final FeedState adsb;
  final bool degraded;

  const FlightDataHealth({
    this.schedules = const FeedState(),
    this.live = const FeedState(),
    this.adsb = const FeedState(),
    this.degraded = false,
  });

  factory FlightDataHealth.fromJson(Map<String, dynamic> json) {
    final feeds = jMap(json['feeds']) ?? const {};
    return FlightDataHealth(
      schedules: FeedState.fromJson(jMap(feeds['schedules']) ?? const {}),
      live: FeedState.fromJson(jMap(feeds['live']) ?? const {}),
      adsb: FeedState.fromJson(jMap(feeds['adsb']) ?? const {}),
      degraded: jBool(json['degraded']),
    );
  }
}

class FeedState {
  final String? service;

  /// Слово провайдера: OK · Down · Degraded · OKPartial · Unavailable · Unknown.
  final String? status;

  const FeedState({this.service, this.status});

  factory FeedState.fromJson(Map<String, dynamic> json) => FeedState(
        service: jString(json['service']),
        status: jString(json['status']),
      );
}
