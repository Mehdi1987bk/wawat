/// Ответы «как есть» (§7.5). У шести эндпоинтов тело провайдера не
/// трансформируется, потому что это статистика, а не сущность приложения —
/// поэтому имена полей здесь camelCase, и это не ошибка.
///
/// Сводных чисел в этих ответах нет: «38 направлений · 92 рейса · 21 страна»
/// считаются в приложении по массиву.
library;

import '../flight_json.dart';
import 'airport.dart';

/// Длительность задержки у провайдера: строка `hh:mm:ss` (может быть
/// отрицательной) либо число. Если формат незнакомый — значения нет, и экран
/// рисует спокойный пропуск вместо выдуманного числа.
class DelaySpan {
  final Duration value;

  const DelaySpan(this.value);

  static DelaySpan? parse(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return DelaySpan(Duration(minutes: raw.round()));
    final s = raw.toString().trim();
    if (s.isEmpty) return null;

    final negative = s.startsWith('-');
    final body = negative ? s.substring(1) : s;

    final hms = RegExp(r'^(\d+):(\d{2})(?::(\d{2}))?(?:\.\d+)?$').firstMatch(body);
    if (hms != null) {
      final d = Duration(
        hours: int.parse(hms.group(1)!),
        minutes: int.parse(hms.group(2)!),
        seconds: int.parse(hms.group(3) ?? '0'),
      );
      return DelaySpan(negative ? -d : d);
    }

    final plain = num.tryParse(body);
    if (plain != null) {
      final d = Duration(minutes: plain.round());
      return DelaySpan(negative ? -d : d);
    }
    return null;
  }

  int get minutes => value.inMinutes;
  bool get isNegative => value.isNegative;
}

/// `GET /flights/{number}/delays` — статистика задержек рейса.
///
/// `class` в Dart ключевое слово, поэтому поле называется [delayClass].
/// Периода наблюдения и «худшего часа» в ответе нет: единственное число —
/// `numConsideredFlights`, поэтому диапазон дат на экране не показывается.
class FlightDelayStats {
  final DelaySpan? medianDelay;
  final List<DelayPercentile> percentiles;
  final List<DelayBracket> brackets;
  final int? numConsideredFlights;
  final String? delayClass;

  const FlightDelayStats({
    this.medianDelay,
    this.percentiles = const [],
    this.brackets = const [],
    this.numConsideredFlights,
    this.delayClass,
  });

  factory FlightDelayStats.fromJson(Map<String, dynamic> json) =>
      FlightDelayStats(
        medianDelay: DelaySpan.parse(json['medianDelay']),
        percentiles: DelayPercentile.parseAll(json['delayPercentiles']),
        brackets: DelayBracket.parseAll(json['numFlightsDelayedBrackets']),
        numConsideredFlights: jInt(json['numConsideredFlights']),
        delayClass: jString(json['class']),
      );

  bool get isEmpty =>
      medianDelay == null &&
      percentiles.isEmpty &&
      brackets.isEmpty &&
      numConsideredFlights == null;
}

/// Один персентиль. Провайдер шлёт их то массивом объектов, то объектом с
/// ключами — разбор принимает и то и другое.
class DelayPercentile {
  final num percentile;
  final DelaySpan? delay;

  const DelayPercentile(this.percentile, this.delay);

  static List<DelayPercentile> parseAll(Object? raw) {
    final out = <DelayPercentile>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          final p = jDouble(m['percentile'] ?? m['p'] ?? m['key']);
          final d = DelaySpan.parse(
              m['delay'] ?? m['time'] ?? m['value'] ?? m['span']);
          if (p != null) out.add(DelayPercentile(_tidy(p), d));
        }
      }
    } else if (raw is Map) {
      raw.forEach((key, value) {
        final p = jDouble(key.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
        if (p != null) out.add(DelayPercentile(_tidy(p), DelaySpan.parse(value)));
      });
    }
    out.sort((a, b) => a.percentile.compareTo(b.percentile));
    return out;
  }

  static num _tidy(double v) => v == v.roundToDouble() ? v.round() : v;

  /// `P90`
  String get label => 'P$percentile';
}

/// Группа задержек: сколько рейсов попало в интервал.
class DelayBracket {
  final DelaySpan? from;
  final DelaySpan? to;
  final int? numFlights;

  const DelayBracket({this.from, this.to, this.numFlights});

  static List<DelayBracket> parseAll(Object? raw) {
    if (raw is! List) return const [];
    final out = <DelayBracket>[];
    for (final item in raw) {
      if (item is Map) {
        final m = Map<String, dynamic>.from(item);
        out.add(DelayBracket(
          from: DelaySpan.parse(m['from'] ?? m['lowerBound'] ?? m['min']),
          to: DelaySpan.parse(m['to'] ?? m['upperBound'] ?? m['max']),
          numFlights:
              jInt(m['numFlights'] ?? m['count'] ?? m['numberOfFlights']),
        ));
      }
    }
    return out;
  }

  /// `0–15 dəq` / `120+ dəq` — числа берутся из ответа, подпись собирается
  /// на экране.
  String range(String minuteSuffix) {
    final a = from?.minutes ?? 0;
    final b = to?.minutes;
    if (b == null) return '$a+ $minuteSuffix';
    return '$a–$b $minuteSuffix';
  }
}

/// Одна сторона задержек аэропорта.
///
/// Главное правило: `delayIndex` и `medianDelay` приходят только когда
/// `numQualifiedTotal > 0` — то есть есть рейсы с измеренным фактическим
/// временем. Из 1728 аэропортов живого ответа число есть только у 523.
/// Поэтому отсутствие числа — основной случай, а не краевой, и писать
/// «задержек нет» нельзя: правда — «неизвестно».
class DelaySide {
  final DelaySpan? medianDelay;

  /// 0.0–5.0, меньше — лучше.
  final double? delayIndex;

  final int? numTotal;
  final int? numQualifiedTotal;
  final int? numCancelled;

  const DelaySide({
    this.medianDelay,
    this.delayIndex,
    this.numTotal,
    this.numQualifiedTotal,
    this.numCancelled,
  });

  factory DelaySide.fromJson(Map<String, dynamic> json) => DelaySide(
        medianDelay: DelaySpan.parse(json['medianDelay']),
        delayIndex: jDouble(json['delayIndex']),
        numTotal: jInt(json['numTotal']),
        numQualifiedTotal: jInt(json['numQualifiedTotal']),
        numCancelled: jInt(json['numCancelled']),
      );

  /// Есть ли измеренное число, которое можно показать и по которому можно
  /// сортировать.
  bool get hasMeasurement => delayIndex != null || medianDelay != null;
}

/// `GET /airports/{code}/delays` — задержки аэропорта.
class AirportDelays {
  final String? airportIcao;
  final String? from;
  final String? to;
  final DelaySide? departures;
  final DelaySide? arrivals;

  const AirportDelays({
    this.airportIcao,
    this.from,
    this.to,
    this.departures,
    this.arrivals,
  });

  factory AirportDelays.fromJson(Map<String, dynamic> json) {
    final dep = jMap(json['departuresDelayInformation']);
    final arr = jMap(json['arrivalsDelayInformation']);
    return AirportDelays(
      airportIcao: jString(json['airportIcao']),
      from: jString(json['from']),
      to: jString(json['to']),
      departures: dep == null ? null : DelaySide.fromJson(dep),
      arrivals: arr == null ? null : DelaySide.fromJson(arr),
    );
  }

  bool get hasAnyMeasurement =>
      (departures?.hasMeasurement ?? false) ||
      (arrivals?.hasMeasurement ?? false);
}

/// `GET /airports/{code}/routes` — направления. `data` сразу массив:
/// обёртка `{routes: …}` снята сервером.
class AirportRoute {
  final RouteDestination? destination;
  final double? averageDailyFlights;
  final List<RouteOperator> operators;

  const AirportRoute({
    this.destination,
    this.averageDailyFlights,
    this.operators = const [],
  });

  factory AirportRoute.fromJson(Map<String, dynamic> json) {
    final dest = jMap(json['destination']);
    return AirportRoute(
      destination: dest == null ? null : RouteDestination.fromJson(dest),
      averageDailyFlights: jDouble(json['averageDailyFlights']),
      operators: jMapList(json['operators'])
          .map(RouteOperator.fromJson)
          .toList(growable: false),
    );
  }
}

class RouteDestination {
  final String? icao;
  final String? iata;
  final String? name;
  final String? municipalityName;
  final String? countryCode;
  final double? lat;
  final double? lon;

  const RouteDestination({
    this.icao,
    this.iata,
    this.name,
    this.municipalityName,
    this.countryCode,
    this.lat,
    this.lon,
  });

  factory RouteDestination.fromJson(Map<String, dynamic> json) {
    final loc = jMap(json['location']);
    return RouteDestination(
      icao: jString(json['icao']),
      iata: jString(json['iata']),
      name: jString(json['name']),
      municipalityName: jString(json['municipalityName']),
      countryCode: jString(json['countryCode']),
      lat: jDouble(loc?['lat']),
      lon: jDouble(loc?['lon']),
    );
  }

  String? get code => iata ?? icao;
  bool get hasPosition => lat != null && lon != null;
}

class RouteOperator {
  final String? name;
  final String? iata;
  final String? icao;

  const RouteOperator({this.name, this.iata, this.icao});

  factory RouteOperator.fromJson(Map<String, dynamic> json) => RouteOperator(
        name: jString(json['name']),
        iata: jString(json['iata']),
        icao: jString(json['icao']),
      );
}

/// `GET /airports/{code}/solar` — рассвет, закат, положение солнца.
/// Порядок девяти точек — как ключи в ответе.
class SolarInfo {
  final double? sunElevation;
  final double? sunAzimuth;

  /// Интервалы светового дня как их дал провайдер.
  final List<String> dayTime;

  final Map<String, String> points;

  const SolarInfo({
    this.sunElevation,
    this.sunAzimuth,
    this.dayTime = const [],
    this.points = const {},
  });

  /// Порядок ключей на экране.
  static const order = <String>[
    'dawnAstronomical',
    'dawnNautical',
    'dawnCivil',
    'sunrise',
    'noonTrue',
    'sunset',
    'duskCivil',
    'duskNautical',
    'duskAstronomical',
  ];

  factory SolarInfo.fromJson(Map<String, dynamic> json) {
    final points = <String, String>{};
    for (final key in order) {
      final v = jString(json[key]);
      if (v != null) points[key] = v;
    }
    final rawDay = json['dayTime'];
    final day = <String>[];
    if (rawDay is List) {
      for (final item in rawDay) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          final from = jString(m['from'] ?? m['start']);
          final to = jString(m['to'] ?? m['end']);
          if (from != null || to != null) {
            day.add('${from ?? ''}${to == null ? '' : ' — $to'}');
          }
        } else {
          final s = jString(item);
          if (s != null) day.add(s);
        }
      }
    } else {
      final s = jString(rawDay);
      if (s != null) day.add(s);
    }
    return SolarInfo(
      sunElevation: jDouble(json['sunElevation']),
      sunAzimuth: jDouble(json['sunAzimuth']),
      dayTime: day,
      points: points,
    );
  }

  /// Солнце ниже горизонта — «НОЧЬ». Считается в приложении: такого поля нет.
  bool? get isNight =>
      sunElevation == null ? null : sunElevation! < 0;

  String? get sunrise => points['sunrise'];
  String? get sunset => points['sunset'];
}

/// `GET /airports/{code}/feeds` — какие потоки живы у этого аэропорта.
/// Объяснение «почему тут нет живых данных» всегда отсюда.
class AirportFeeds {
  final FeedInfo schedules;
  final FeedInfo live;
  final FeedInfo adsb;

  const AirportFeeds({
    this.schedules = const FeedInfo(),
    this.live = const FeedInfo(),
    this.adsb = const FeedInfo(),
  });

  factory AirportFeeds.fromJson(Map<String, dynamic> json) => AirportFeeds(
        schedules:
            FeedInfo.fromJson(jMap(json['flightSchedulesFeed']) ?? const {}),
        live: FeedInfo.fromJson(
            jMap(json['liveFlightUpdatesFeed']) ?? const {}),
        adsb: FeedInfo.fromJson(jMap(json['adsbUpdatesFeed']) ?? const {}),
      );
}

class FeedInfo {
  final String? service;
  final String? status;
  final String? minAvailableLocalDate;
  final String? maxAvailableLocalDate;

  const FeedInfo({
    this.service,
    this.status,
    this.minAvailableLocalDate,
    this.maxAvailableLocalDate,
  });

  factory FeedInfo.fromJson(Map<String, dynamic> json) => FeedInfo(
        service: jString(json['service']),
        status: jString(json['status']),
        minAvailableLocalDate: jString(json['minAvailableLocalDate']),
        maxAvailableLocalDate: jString(json['maxAvailableLocalDate']),
      );
}

/// `GET /airports/{from}/distance/{to}` — расстояние и примерное время полёта.
class AirportDistance {
  final AirportRef? from;
  final AirportRef? to;
  final double? meter;
  final double? km;
  final double? mile;
  final double? nm;

  /// Примерное время полёта, не время расписания. Не преобразуется — значение
  /// проходит как есть.
  final String? approxFlightTime;

  const AirportDistance({
    this.from,
    this.to,
    this.meter,
    this.km,
    this.mile,
    this.nm,
    this.approxFlightTime,
  });

  factory AirportDistance.fromJson(Map<String, dynamic> json) {
    final gc = jMap(json['greatCircleDistance']) ?? const {};
    return AirportDistance(
      from: _ref(json['from']),
      to: _ref(json['to']),
      meter: jDouble(gc['meter']),
      km: jDouble(gc['km']),
      mile: jDouble(gc['mile']),
      nm: jDouble(gc['nm']),
      approxFlightTime: jString(json['approxFlightTime']),
    );
  }

  static AirportRef? _ref(Object? raw) {
    final m = jMap(raw);
    if (m == null) return null;
    final loc = jMap(m['location']);
    return AirportRef(
      iata: jString(m['iata']),
      icao: jString(m['icao']),
      name: jString(m['name']),
      municipality: jString(m['municipalityName'] ?? m['municipality']),
      countryCode: jString(m['countryCode'] ?? m['country_code']),
      timeZone: jString(m['timeZone'] ?? m['time_zone']),
      lat: jDouble(loc?['lat'] ?? m['lat']),
      lon: jDouble(loc?['lon'] ?? m['lon']),
    );
  }
}

/// Элемент глобальной карты задержек. Ключ — `airportIcao` (EGLL, OMDB),
/// не IATA.
class GlobalDelayItem {
  final String? airportIcao;
  final DelaySide? departures;
  final DelaySide? arrivals;

  const GlobalDelayItem({this.airportIcao, this.departures, this.arrivals});

  factory GlobalDelayItem.fromJson(Map<String, dynamic> json) {
    final dep = jMap(json['departuresDelayInformation']);
    final arr = jMap(json['arrivalsDelayInformation']);
    return GlobalDelayItem(
      airportIcao: jString(json['airportIcao']),
      departures: dep == null ? null : DelaySide.fromJson(dep),
      arrivals: arr == null ? null : DelaySide.fromJson(arr),
    );
  }

  /// Худший из двух концов — по нему строится сортировка и цвет.
  double? get worstIndex {
    final a = departures?.delayIndex;
    final b = arrivals?.delayIndex;
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }

  DelaySpan? get worstMedian {
    final a = departures?.medianDelay;
    final b = arrivals?.medianDelay;
    if (a == null) return b;
    if (b == null) return a;
    return a.value >= b.value ? a : b;
  }

  int get totalFlights =>
      (departures?.numTotal ?? 0) + (arrivals?.numTotal ?? 0);

  bool get hasMeasurement =>
      (departures?.hasMeasurement ?? false) ||
      (arrivals?.hasMeasurement ?? false);
}
