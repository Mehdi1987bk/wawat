import 'flight_auth.dart';
import 'flight_envelope.dart';
import 'flight_local_store.dart';
import 'flight_map_prefs.dart';
import 'flight_repository.dart';
import 'models/flight.dart';
import 'models/flight_enums.dart';
import 'models/flight_watch.dart';

/// Один рейс на радаре.
///
/// Список подписок уже содержит рейс целиком, но позиции в нём нет: её даёт
/// только `/detail`. Поэтому строка живёт в двух частях — что известно из
/// списка и что пришло из подробностей (§9.2).
class RadarFlight {
  final FlightKey key;
  final String displayNumber;

  /// Из списка подписок. У отмеченного на телефоне рейса этого нет —
  /// известен только номер с датой.
  final FlightSummary? listed;

  /// Подробности: позиция, доля пути, высота и скорость.
  final FlightDetail? detail;

  /// Есть подписка на сервере (а не только отметка на телефоне).
  final bool watched;

  /// Привязанное объявление — по нему работает фильтр «Bizim marşrutlar».
  final int? listingId;

  const RadarFlight({
    required this.key,
    required this.displayNumber,
    this.listed,
    this.detail,
    this.watched = false,
    this.listingId,
  });

  RadarFlight withDetail(FlightDetail? value) => RadarFlight(
        key: key,
        displayNumber: displayNumber,
        listed: listed,
        detail: value,
        watched: watched,
        listingId: listingId,
      );

  FlightSummary? get summary => detail?.summary ?? listed;

  String? get status => summary?.status;
  String? get statusLabel => summary?.statusLabel;
  String? get departureCode =>
      detail?.departure.airport?.code ?? listed?.departureCode;
  String? get arrivalCode =>
      detail?.arrival.airport?.code ?? listed?.arrivalCode;

  FlightLocation? get location => detail?.location;

  /// Пришла ли живая позиция. Нет — метка ставится по доле пути.
  bool get hasPosition => location?.hasPosition == true;

  /// Доля пути. `null` — метки на карте нет вообще, остаётся одна дуга.
  double? get progress => detail?.progressPercent?.toDouble();

  int? get altitudeM => location?.altitudeM;
  double? get speedKmh => location?.groundSpeedKmh;
  double? get track => location?.trueTrack;
  int? get vsiFpm => location?.vsiFpm;

  bool get isCargo => summary?.isCargo ?? false;
  bool get isCanceled => FlightStatus.isCanceled(status);

  /// В воздухе — по статусу; `is_live` не всегда приходит у рейса без ADS-B.
  bool get airborne => FlightStatus.isInAir(status) || summary?.isLive == true;

  /// Чем рейс отбирается в фильтре авиакомпаний.
  String? get airlineKey {
    final airline = summary?.airline;
    final value = airline?.iata ?? airline?.icao ?? airline?.name;
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed.toUpperCase();
  }

  String? get airlineName {
    final airline = summary?.airline;
    final value = airline?.name ?? airline?.iata ?? airline?.icao;
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

/// Что получилось собрать для радара.
class FlightRadarData {
  final List<RadarFlight> flights;

  /// Вошёл ли человек. Гостю подписки недоступны — радар строится из
  /// отмеченных на телефоне рейсов.
  final bool signedIn;

  /// `meta` списка подписок — отсюда берётся полоска «данные на …».
  final FlightMeta? meta;

  /// Сколько рейсов осталось без запроса позиции: бюджет минуты не резиновый.
  final int withoutDetail;

  const FlightRadarData({
    this.flights = const [],
    this.signedIn = false,
    this.meta,
    this.withoutDetail = 0,
  });

  int get total => flights.length;
  int get positioned => flights.where((f) => f.hasPosition).length;
  int get estimated =>
      flights.where((f) => !f.hasPosition && f.progress != null).length;
}

/// Сбор радара.
///
/// Запроса «все самолёты в районе» в нашем API нет (§9.2), поэтому радар
/// строится из подписок и отмеченных на телефоне рейсов. По каждому уходит
/// `/detail` — иначе позиции не будет; подписанный рейс при этом **не**
/// опрашивается по таймеру (§4.4), запрос уходит один раз на вход на экран,
/// а повторный вход в пределах 30 секунд берёт прошлый ответ из кэша.
abstract final class FlightRadar {
  /// Сколько рейсов за один вход спрашивается подробно. Минутный бюджет
  /// авторизованного — 45 запросов; оставляем место остальным экранам.
  static const maxDetails = 20;

  static Future<FlightRadarData> load({bool force = false}) async {
    final repo = FlightRepository.instance;
    final signedIn = await FlightAuth.signedIn();

    var rows = <RadarFlight>[];
    FlightMeta? meta;

    if (signedIn) {
      final envelope = await repo.watches(force: force);
      meta = envelope.meta;
      for (final watch in envelope.data ?? const <FlightWatch>[]) {
        final flight = watch.flight;
        final key = flight?.key;
        if (flight == null || key == null) continue;
        rows.add(RadarFlight(
          key: key,
          displayNumber: flight.displayNumber,
          listed: flight,
          watched: true,
          listingId: watch.listingId,
        ));
      }
    }

    // Отмеченные на телефоне рейсы — это «seçilmiş uçuşlar» из §9.2. Берутся
    // только близкие по дате: позиция у рейса прошлого месяца никому не
    // нужна, а запрос всё равно стоил бы бюджета.
    await FlightLocalStore.instance.load();
    for (final saved in FlightLocalStore.instance.savedFlights) {
      if (!_nearDate(saved.flightDate)) continue;
      if (rows.any((row) => row.key == saved.key)) continue;
      rows.add(RadarFlight(
        key: saved.key,
        displayNumber: saved.displayNumber,
      ));
    }

    final limited = rows.length > maxDetails ? rows.sublist(0, maxDetails) : rows;
    final out = <RadarFlight>[];
    for (final row in limited) {
      FlightDetail? detail;
      try {
        detail = (await repo.flightDetail(row.key, force: force)).data;
      } catch (_) {
        // Один рейс без подробностей радар не ломает: строка останется с тем,
        // что было в списке подписок.
        detail = null;
      }
      out.add(row.withDetail(detail));
    }

    return FlightRadarData(
      flights: [...out, ...rows.skip(limited.length)],
      signedIn: signedIn,
      meta: meta,
      withoutDetail: rows.length - limited.length,
    );
  }

  /// Вчера, сегодня и два дня вперёд — окно, в котором рейс ещё имеет
  /// отношение к «сейчас».
  static bool _nearDate(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return false;
    final now = DateTime.now();
    final days = DateTime(parsed.year, parsed.month, parsed.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    return days >= -1 && days <= 2;
  }
}

/// Фильтры радара — локально, без запросов (§9.2).
List<RadarFlight> fRadarFiltered(
  List<RadarFlight> flights,
  FlightMapPrefs prefs,
) {
  return flights.where((flight) {
    switch (prefs.scope) {
      case FMapScope.all:
        break;
      case FMapScope.watched:
        if (!flight.watched) return false;
      case FMapScope.ourRoutes:
        if (flight.listingId == null) return false;
    }
    if (prefs.airborneOnly && !flight.airborne) return false;
    if (prefs.positionOnly && !flight.hasPosition) return false;
    if (!prefs.showCargo && flight.isCargo) return false;
    final airline = prefs.airline;
    if (airline != null && flight.airlineKey != airline) return false;
    switch (prefs.altitude) {
      case FMapAltitude.any:
        break;
      case FMapAltitude.high:
        final altitude = flight.altitudeM;
        if (altitude == null || altitude < 10000) return false;
      case FMapAltitude.descending:
        // Снижение видно только по вертикальной скорости, а она приходит
        // вместе с позицией. Нет позиции — нет и ответа на этот вопрос.
        final vsi = flight.vsiFpm;
        final approaching = flight.status == FlightStatus.approaching;
        if (!approaching && (vsi == null || vsi >= -100)) return false;
    }
    return true;
  }).toList(growable: false);
}

/// Авиакомпании, которые реально есть на радаре — список чипов фильтра
/// строится из загруженных рейсов, а не из заранее вписанных имён.
List<RadarAirline> fRadarAirlines(List<RadarFlight> flights) {
  final map = <String, String>{};
  for (final flight in flights) {
    final key = flight.airlineKey;
    if (key == null) continue;
    map.putIfAbsent(key, () => flight.airlineName ?? key);
  }
  final out = map.entries
      .map((e) => RadarAirline(key: e.key, name: e.value))
      .toList();
  out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return out;
}

class RadarAirline {
  final String key;
  final String name;

  const RadarAirline({required this.key, required this.name});
}
