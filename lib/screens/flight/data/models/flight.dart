import '../flight_json.dart';
import 'aircraft.dart';
import 'airport.dart';
import 'flight_enums.dart';

/// Авиакомпания. Может прийти `null` целиком.
class Airline {
  final String? name;
  final String? iata;
  final String? icao;

  const Airline({this.name, this.iata, this.icao});

  factory Airline.fromJson(Map<String, dynamic> json) => Airline(
        name: jString(json['name']),
        iata: jString(json['iata']),
        icao: jString(json['icao']),
      );
}

/// Местное время как строка со смещением: `2026-11-01 13:30+04:00`.
///
/// Показывается как есть — ничего не пересчитывается (§7.1). Разбор нужен
/// только чтобы достать часы и дату для вывода; арифметика идёт по UTC-полям.
class LocalStamp {
  final String raw;

  const LocalStamp(this.raw);

  static LocalStamp? parse(Object? v) {
    final s = jString(v);
    return s == null ? null : LocalStamp(s);
  }

  /// `13:30`
  String get clock {
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (m == null) return raw;
    return '${m.group(1)!.padLeft(2, '0')}:${m.group(2)}';
  }

  /// `2026-11-01`
  String? get date {
    final m = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    return m?.group(0);
  }

  /// Смещение так, как его дал сервер: `+04:00`.
  String? get offset {
    final m = RegExp(r'([+-]\d{2}:?\d{2})$').firstMatch(raw.trim());
    return m?.group(1);
  }

  /// `UTC+4` — для подписи у аэропорта.
  String? get utcLabel {
    final o = offset;
    if (o == null) return null;
    final sign = o[0];
    final hours = int.tryParse(o.substring(1, 3));
    if (hours == null) return null;
    final minutes = o.replaceAll(':', '').substring(3);
    final tail = minutes == '00' ? '' : ':$minutes';
    return 'UTC$sign$hours$tail';
  }

  /// Часы и минуты как количество минут от полуночи местного времени —
  /// только для сортировки внутри одного табло.
  int? get minutesOfDay {
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (m == null) return null;
    return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  }

  @override
  String toString() => raw;
}

/// Краткая запись рейса (§7.1) — списки, табло, выбор плеча, привязка.
class FlightSummary {
  /// Для запросов. На экран не выводится.
  final String number;

  /// Для экрана: `number` с пробелом после кода авиакомпании.
  final String displayNumber;
  final String? flightDate;
  final String? departureCode;
  final String? arrivalCode;

  /// Только для логики: иконка, цвет, ветвления.
  final String? status;

  /// Для показа. Уже переведён — своего словаря статусов нет.
  final String? statusLabel;
  final bool isCargo;
  final Airline? airline;
  final String? aircraftModel;
  final DateTime? departureAt;
  final DateTime? arrivalAt;
  final LocalStamp? departureLocal;
  final LocalStamp? arrivalLocal;

  /// >0 опоздание, <0 прилетит раньше, `null` пересчёта не было.
  final int? departureDelayMinutes;
  final int? arrivalDelayMinutes;

  /// Пришли координаты (`location !== null`). На наших маршрутах почти всегда
  /// `false` — у Баку нет потока ADS-B.
  final bool isLive;

  /// Подтверждён ли этот конец живым потоком аэропорта (§5).
  final bool departureConfirmed;
  final bool arrivalConfirmed;

  const FlightSummary({
    required this.number,
    required this.displayNumber,
    this.flightDate,
    this.departureCode,
    this.arrivalCode,
    this.status,
    this.statusLabel,
    this.isCargo = false,
    this.airline,
    this.aircraftModel,
    this.departureAt,
    this.arrivalAt,
    this.departureLocal,
    this.arrivalLocal,
    this.departureDelayMinutes,
    this.arrivalDelayMinutes,
    this.isLive = false,
    this.departureConfirmed = false,
    this.arrivalConfirmed = false,
  });

  factory FlightSummary.fromJson(Map<String, dynamic> json) {
    final airline = jMap(json['airline']);
    final number = jString(json['number']) ?? '';
    return FlightSummary(
      number: number,
      displayNumber: jString(json['display_number']) ?? number,
      flightDate: jString(json['flight_date']),
      departureCode: jString(json['departure_code']),
      arrivalCode: jString(json['arrival_code']),
      status: jString(json['status']),
      statusLabel: jString(json['status_label']),
      isCargo: jBool(json['is_cargo']),
      airline: airline == null ? null : Airline.fromJson(airline),
      aircraftModel: jString(json['aircraft_model']),
      departureAt: jUtc(json['departure_at']),
      arrivalAt: jUtc(json['arrival_at']),
      departureLocal: LocalStamp.parse(json['departure_local']),
      arrivalLocal: LocalStamp.parse(json['arrival_local']),
      departureDelayMinutes: jInt(json['departure_delay_minutes']),
      arrivalDelayMinutes: jInt(json['arrival_delay_minutes']),
      isLive: jBool(json['is_live']),
      departureConfirmed: jBool(json['departure_confirmed']),
      arrivalConfirmed: jBool(json['arrival_confirmed']),
    );
  }

  /// Тройка, которой рейс опознаётся везде (§4.1).
  FlightKey? get key => flightDate == null
      ? null
      : FlightKey(
          number: number,
          flightDate: flightDate!,
          departureCode: departureCode,
        );

  FlightStatusGroup get statusGroup => FlightStatus.groupOf(status);

  bool get isCanceled => FlightStatus.isCanceled(status);

  /// Продолжительность — не поле API, считается из `departure_at` / `arrival_at`.
  Duration? get duration {
    final from = departureAt;
    final to = arrivalAt;
    if (from == null || to == null) return null;
    final d = to.difference(from);
    return d.isNegative ? null : d;
  }
}

/// `number + flight_date + departure_code` — рейс опознаётся только тройкой.
///
/// Один и тот же номер летает в разные даты, а в одну дату может выполнять
/// несколько плеч, поэтому `departure_code` передаётся во все запросы по
/// рейсу: в `/detail`, в `POST /watch`, в `DELETE /watch`.
class FlightKey {
  final String number;
  final String flightDate;
  final String? departureCode;

  const FlightKey({
    required this.number,
    required this.flightDate,
    this.departureCode,
  });

  FlightKey withDepartureCode(String? code) => FlightKey(
        number: number,
        flightDate: flightDate,
        departureCode: code,
      );

  @override
  bool operator ==(Object other) =>
      other is FlightKey &&
      other.number == number &&
      other.flightDate == flightDate &&
      other.departureCode == departureCode;

  @override
  int get hashCode => Object.hash(number, flightDate, departureCode);

  @override
  String toString() =>
      '$number/$flightDate${departureCode == null ? '' : '/$departureCode'}';
}

/// Один из четырёх моментов времени у конца рейса: `{utc, local}`.
class FlightTime {
  final DateTime? utc;
  final LocalStamp? local;

  const FlightTime({this.utc, this.local});

  static FlightTime? parse(Object? raw) {
    final m = jMap(raw);
    if (m == null) return null;
    final utc = jUtc(m['utc']);
    final local = LocalStamp.parse(m['local']);
    if (utc == null && local == null) return null;
    return FlightTime(utc: utc, local: local);
  }
}

/// Какое из четырёх времён показано. Подписать, какое именно, обязательно.
enum FlightTimeKind { runway, revised, predicted, scheduled }

/// Конец рейса — `departure` или `arrival` (§7.2).
class FlightEndpoint {
  final AirportRef? airport;
  final FlightTime? scheduled;
  final FlightTime? revised;
  final FlightTime? predicted;

  /// Факт отрыва или касания — самое достоверное время.
  final FlightTime? runwayTime;

  final String? terminal;
  final String? checkInDesk;
  final String? gate;
  final String? baggageBelt;
  final String? runway;

  /// Своя для каждой стороны: `basic` расписание, `live` живые данные,
  /// `approximate` оценка. Одна общая плашка на весь рейс будет врать.
  final List<String> quality;

  final int? delayMinutes;

  const FlightEndpoint({
    this.airport,
    this.scheduled,
    this.revised,
    this.predicted,
    this.runwayTime,
    this.terminal,
    this.checkInDesk,
    this.gate,
    this.baggageBelt,
    this.runway,
    this.quality = const [],
    this.delayMinutes,
  });

  factory FlightEndpoint.fromJson(Map<String, dynamic> json) {
    final airport = jMap(json['airport']);
    return FlightEndpoint(
      airport: airport == null ? null : AirportRef.fromJson(airport),
      scheduled: FlightTime.parse(json['scheduled']),
      revised: FlightTime.parse(json['revised']),
      predicted: FlightTime.parse(json['predicted']),
      runwayTime: FlightTime.parse(json['runway_time']),
      terminal: jString(json['terminal']),
      checkInDesk: jString(json['check_in_desk']),
      gate: jString(json['gate']),
      baggageBelt: jString(json['baggage_belt']),
      runway: jString(json['runway']),
      quality: jStringList(json['quality']),
      delayMinutes: jInt(json['delay_minutes']),
    );
  }

  /// Самое достоверное из непустых: runway → revised → predicted → scheduled.
  FlightTimeKind? get bestKind {
    if (runwayTime != null) return FlightTimeKind.runway;
    if (revised != null) return FlightTimeKind.revised;
    if (predicted != null) return FlightTimeKind.predicted;
    if (scheduled != null) return FlightTimeKind.scheduled;
    return null;
  }

  FlightTime? get best => timeOf(bestKind);

  FlightTime? timeOf(FlightTimeKind? kind) {
    switch (kind) {
      case FlightTimeKind.runway:
        return runwayTime;
      case FlightTimeKind.revised:
        return revised;
      case FlightTimeKind.predicted:
        return predicted;
      case FlightTimeKind.scheduled:
        return scheduled;
      case null:
        return null;
    }
  }

  bool get hasLiveQuality => quality.contains(FlightQuality.live);
}

/// Координаты и телеметрия. `null`, если координат нет — тогда курс, высота и
/// скорость не показываются вообще.
class FlightLocation {
  final double? lat;
  final double? lon;
  final int? altitudeM;
  final int? altitudeFt;
  final int? pressureAltitudeFt;
  final double? pressureHpa;
  final double? groundSpeedKmh;
  final double? groundSpeedKt;
  final double? trueTrack;
  final int? vsiFpm;
  final DateTime? reportedAt;

  const FlightLocation({
    this.lat,
    this.lon,
    this.altitudeM,
    this.altitudeFt,
    this.pressureAltitudeFt,
    this.pressureHpa,
    this.groundSpeedKmh,
    this.groundSpeedKt,
    this.trueTrack,
    this.vsiFpm,
    this.reportedAt,
  });

  factory FlightLocation.fromJson(Map<String, dynamic> json) => FlightLocation(
        lat: jDouble(json['lat']),
        lon: jDouble(json['lon']),
        altitudeM: jInt(json['altitude_m']),
        altitudeFt: jInt(json['altitude_ft']),
        pressureAltitudeFt: jInt(json['pressure_altitude_ft']),
        pressureHpa: jDouble(json['pressure_hpa']),
        groundSpeedKmh: jDouble(json['ground_speed_kmh']),
        groundSpeedKt: jDouble(json['ground_speed_kt']),
        trueTrack: jDouble(json['true_track']),
        vsiFpm: jInt(json['vsi_fpm']),
        reportedAt: jUtc(json['reported_at']),
      );

  bool get hasPosition => lat != null && lon != null;
}

/// Точка следа. Приходит только в `/detail` и только если координаты были.
class TrackPoint {
  final double? lat;
  final double? lon;
  final int? altitudeM;
  final double? groundSpeedKmh;
  final double? trueTrack;
  final DateTime? reportedAt;

  const TrackPoint({
    this.lat,
    this.lon,
    this.altitudeM,
    this.groundSpeedKmh,
    this.trueTrack,
    this.reportedAt,
  });

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
        lat: jDouble(json['lat']),
        lon: jDouble(json['lon']),
        altitudeM: jInt(json['altitude_m']),
        groundSpeedKmh: jDouble(json['ground_speed_kmh']),
        trueTrack: jDouble(json['true_track']),
        reportedAt: jUtc(json['reported_at']),
      );

  bool get hasPosition => lat != null && lon != null;
}

/// Полётный план. Приходит редко — его подаёт не каждый рейс.
/// Нет `route` — нет блока.
class FlightPlan {
  final String? route;
  final String? rules;
  final String? type;
  final String? status;
  final int? revision;
  final int? altitudeFt;
  final int? airspeedKt;
  final DateTime? updatedAt;

  const FlightPlan({
    this.route,
    this.rules,
    this.type,
    this.status,
    this.revision,
    this.altitudeFt,
    this.airspeedKt,
    this.updatedAt,
  });

  factory FlightPlan.fromJson(Map<String, dynamic> json) => FlightPlan(
        route: jString(json['route']),
        rules: jString(json['rules']),
        type: jString(json['type']),
        status: jString(json['status']),
        revision: jInt(json['revision']),
        altitudeFt: jInt(json['altitude_ft']),
        airspeedKt: jInt(json['airspeed_kt']),
        updatedAt: jUtc(json['updated_at']),
      );

  bool get hasRoute => route != null && route!.trim().isNotEmpty;

  /// Путевые точки — не отдельное поле: строка `route` делится на слова.
  List<String> get waypoints => hasRoute
      ? route!.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList()
      : const [];
}

/// Полная карточка рейса (§7.2) — всё, что есть в `/detail`.
class FlightDetail {
  final FlightSummary summary;
  final String? callSign;
  final String? codeshareStatus;
  final double? greatCircleKm;
  final AircraftRef? aircraft;
  final FlightEndpoint departure;
  final FlightEndpoint arrival;
  final FlightLocation? location;
  final FlightPlan? flightPlan;

  /// Для полосы прогресса и отметки на дуге. `null`, если считать не из чего;
  /// `100`, если рейс `arrived`; `null` при `canceled` / `diverted`.
  final int? progressPercent;

  final List<TrackPoint> track;
  final DateTime? sourceUpdatedAt;
  final DateTime? refreshedAt;

  const FlightDetail({
    required this.summary,
    this.callSign,
    this.codeshareStatus,
    this.greatCircleKm,
    this.aircraft,
    this.departure = const FlightEndpoint(),
    this.arrival = const FlightEndpoint(),
    this.location,
    this.flightPlan,
    this.progressPercent,
    this.track = const [],
    this.sourceUpdatedAt,
    this.refreshedAt,
  });

  factory FlightDetail.fromJson(Map<String, dynamic> json) {
    final aircraft = jMap(json['aircraft']);
    final location = jMap(json['location']);
    final plan = jMap(json['flight_plan']);
    return FlightDetail(
      summary: FlightSummary.fromJson(json),
      callSign: jString(json['call_sign']),
      codeshareStatus: jString(json['codeshare_status']),
      greatCircleKm: jDouble(json['great_circle_km']),
      aircraft: aircraft == null ? null : AircraftRef.fromJson(aircraft),
      departure:
          FlightEndpoint.fromJson(jMap(json['departure']) ?? const {}),
      arrival: FlightEndpoint.fromJson(jMap(json['arrival']) ?? const {}),
      location: location == null ? null : FlightLocation.fromJson(location),
      flightPlan: plan == null ? null : FlightPlan.fromJson(plan),
      progressPercent: jInt(json['progress_percent']),
      track: jMapList(json['track'])
          .map(TrackPoint.fromJson)
          .toList(growable: false),
      sourceUpdatedAt: jUtc(json['source_updated_at']),
      refreshedAt: jUtc(json['refreshed_at']),
    );
  }

  String get number => summary.number;
  String get displayNumber => summary.displayNumber;
  String? get status => summary.status;
  String? get statusLabel => summary.statusLabel;
  FlightKey? get key => summary.key;

  /// У `/detail` нет `meta`, поэтому время данных берётся отсюда.
  DateTime? get dataTimestamp => refreshedAt ?? sourceUpdatedAt;

  bool get hasPosition => location?.hasPosition == true;

  /// Прилёт не подтверждён, а время прилёта уже прошло: «должен был
  /// приземлиться», но не «приземлился» и не «задерживается» — этого никто
  /// не подтверждал (§5).
  bool arrivalOverdue(DateTime now) {
    if (summary.arrivalConfirmed) return false;
    final expected = arrival.best?.utc ?? summary.arrivalAt;
    if (expected == null) return false;
    return now.toUtc().isAfter(expected);
  }

  /// Остаток пути: не поле API — `great_circle_km × (1 − progress / 100)`.
  double? get remainingKm {
    final total = greatCircleKm;
    final progress = progressPercent;
    if (total == null || progress == null) return null;
    final left = total * (1 - progress / 100);
    return left < 0 ? 0 : left;
  }
}
