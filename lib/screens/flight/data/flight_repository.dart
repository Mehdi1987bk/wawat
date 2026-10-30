import 'package:dio/dio.dart';

import '../../../main.dart';
import 'flight_api.dart';
import 'flight_envelope.dart';
import 'models/aircraft.dart';
import 'models/airport.dart';
import 'models/flight.dart';
import 'models/flight_stats.dart';
import 'models/flight_watch.dart';

/// Кэш раздела и правила частоты (§4.4).
///
/// Зачем он существует отдельно от сетевого кэша: минутный бюджет у раздела
/// небольшой (45 запросов авторизованному, 15 гостю), а экраны ходят по
/// кругу — карточка рейса, табло, обратно. Повторный вход на тот же экран в
/// пределах окна берёт прошлый ответ и запроса не делает.
///
/// Табло и карточка рейса ограничены **жёстко**: даже «обновить» руками не
/// отправит запрос, если с прошлого прошло меньше 30 секунд.
///
/// Подписанный рейс не опрашивается вообще: сервер обновляет его сам и
/// присылает push, поэтому опроса по таймеру в разделе нет нигде.
class FlightRepository {
  FlightRepository._(this.api);

  static FlightRepository? _instance;

  /// Один на приложение: кэш общий, иначе смысла в нём нет.
  static FlightRepository get instance =>
      _instance ??= FlightRepository._(FlightApi(sl.get<Dio>()));

  final FlightApi api;

  final Map<String, _Entry> _cache = {};

  static const _live = Duration(seconds: 30);
  static const _short = Duration(minutes: 2);
  static const _medium = Duration(minutes: 10);
  static const _static = Duration(hours: 12);

  // ───────────────────────────── Рейсы ─────────────────────────────

  Future<FlightEnvelope<List<String>>> searchFlightNumbers(
    String query, {
    int limit = 10,
  }) =>
      _load('fsearch:${query.toLowerCase()}:$limit', _short,
          () => api.searchFlightNumbers(query, limit: limit));

  Future<FlightEnvelope<List<String>>> flightDates(
    String number, {
    String? from,
    String? to,
  }) =>
      _load('fdates:${_n(number)}:$from:$to', _medium,
          () => api.flightDates(number, from: from, to: to));

  Future<FlightEnvelope<List<FlightSummary>>> flights(
    String number,
    String date, {
    bool force = false,
  }) =>
      _load('flights:${_n(number)}:$date', _live,
          () => api.flights(number, date),
          force: force);

  Future<FlightEnvelope<FlightDetail>> flightDetail(
    FlightKey key, {
    bool force = false,
  }) =>
      _load(
        'detail:${_n(key.number)}:${key.flightDate}:${key.departureCode ?? ''}',
        _live,
        () => api.flightDetail(key.number, key.flightDate,
            departureCode: key.departureCode),
        force: force,
      );

  Future<FlightEnvelope<List<FlightSummary>>> flightsByRegistration(
    String registration,
    String date,
  ) =>
      _load('byreg:${_n(registration)}:$date', _live,
          () => api.flightsByRegistration(registration, date));

  Future<FlightEnvelope<List<FlightSummary>>> routeFlights(
    String from,
    String to,
    String date, {
    bool force = false,
  }) =>
      _load('route:${_n(from)}:${_n(to)}:$date', _live,
          () => api.routeFlights(from, to, date),
          force: force);

  Future<FlightEnvelope<List<FlightSummary>>> flightHistory(
    String number, {
    String? from,
    String? to,
  }) =>
      _load('history:${_n(number)}:$from:$to', _short,
          () => api.flightHistory(number, from: from, to: to));

  Future<FlightEnvelope<FlightDelayStats>> flightDelays(String number) =>
      _load('fdelays:${_n(number)}', _medium, () => api.flightDelays(number));

  // ──────────────────────────── Аэропорты ────────────────────────────

  Future<FlightEnvelope<List<AirportSummary>>> airports({
    int limit = 10,
    bool force = false,
  }) =>
      _load('airports:$limit', _medium, () => api.airports(limit: limit),
          force: force);

  Future<FlightEnvelope<List<AirportSummary>>> searchAirports(
    String query, {
    int? limit,
  }) =>
      _load('asearch:${query.toLowerCase()}:$limit', _short,
          () => api.searchAirports(query, limit: limit));

  Future<FlightEnvelope<List<AirportSummary>>> nearbyAirports({
    required double lat,
    required double lon,
    int radiusKm = 150,
    int limit = 10,
    bool force = false,
  }) =>
      _load(
        'near:${lat.toStringAsFixed(3)}:${lon.toStringAsFixed(3)}:$radiusKm:$limit',
        _short,
        () => api.nearbyAirports(
            lat: lat, lon: lon, radiusKm: radiusKm, limit: limit),
        force: force,
      );

  Future<FlightEnvelope<Airport>> airport(String code) =>
      _load('airport:${_n(code)}', _medium, () => api.airport(code));

  Future<FlightEnvelope<List<Runway>>> runways(String code) =>
      _load('runways:${_n(code)}', _static, () => api.runways(code));

  Future<FlightEnvelope<List<FlightSummary>>> board(
    String code, {
    String? direction,
    String? from,
    String? to,
    bool force = false,
  }) =>
      _load('board:${_n(code)}:$direction:$from:$to', _live,
          () => api.board(code, direction: direction, from: from, to: to),
          force: force);

  Future<FlightEnvelope<AirportDelays>> airportDelays(
    String code, {
    String? date,
    String? from,
    String? to,
  }) =>
      _load('adelays:${_n(code)}:$date:$from:$to', _short,
          () => api.airportDelays(code, date: date, from: from, to: to));

  Future<FlightEnvelope<List<AirportRoute>>> airportRoutes(
    String code, {
    String? date,
  }) =>
      _load('aroutes:${_n(code)}:$date', _medium,
          () => api.airportRoutes(code, date: date));

  Future<FlightEnvelope<SolarInfo>> solar(String code, {String? date}) =>
      _load('solar:${_n(code)}:$date', _medium,
          () => api.solar(code, date: date));

  Future<FlightEnvelope<AirportFeeds>> feeds(String code) =>
      _load('feeds:${_n(code)}', _short, () => api.feeds(code));

  Future<FlightEnvelope<List<GlobalDelayItem>>> globalDelays({
    String? date,
    bool force = false,
  }) =>
      _load('gdelays:$date', _short, () => api.globalDelays(date: date),
          force: force);

  Future<FlightEnvelope<AirportDistance>> distance(String from, String to) =>
      _load('dist:${_n(from)}:${_n(to)}', _static, () => api.distance(from, to));

  // ───────────────────────────── Самолёты ─────────────────────────────

  Future<FlightEnvelope<List<FleetItem>>> searchAircraft(
    String query, {
    int? limit,
  }) =>
      _load('acsearch:${query.toLowerCase()}:$limit', _short,
          () => api.searchAircraft(query, limit: limit));

  Future<FlightEnvelope<Aircraft>> aircraft(String registration) =>
      _load('aircraft:${_n(registration)}', _static,
          () => api.aircraft(registration));

  Future<FlightEnvelope<FleetPage>> fleet(
    String airline, {
    int perPage = 50,
    int offset = 0,
  }) =>
      _load('fleet:${_n(airline)}:$perPage:$offset', _medium,
          () => api.fleet(airline, perPage: perPage, offset: offset));

  // ───────────────────────────── Служебное ────────────────────────────

  Future<FlightEnvelope<FlightDataHealth>> health({bool force = false}) =>
      _load('health', _short, () => api.health(), force: force);

  // ───────────────────────────── Слежение ─────────────────────────────

  Future<FlightEnvelope<List<FlightWatch>>> watches({bool force = false}) =>
      _load('watches', _live, () => api.watches(), force: force);

  Future<FlightEnvelope<FlightWatch>> watch(
    FlightKey key, {
    int? listingId,
    List<String>? events,
    int? muteHours,
  }) async {
    final result = await api.watch(
      key.number,
      key.flightDate,
      departureCode: key.departureCode,
      listingId: listingId,
      events: events,
      muteHours: muteHours,
    );
    _cache.remove('watches');
    return result;
  }

  Future<void> unwatch(FlightKey key) async {
    await api.unwatch(key.number, key.flightDate,
        departureCode: key.departureCode);
    _cache.remove('watches');
  }

  // ───────────────────────────── внутреннее ───────────────────────────

  /// Прошлый ответ, если он есть, — даже просроченный. Нужен ровно для
  /// одного случая: после `429` показать «продолжить с кэшем». Если прошлого
  /// ответа нет, кнопки быть не должно — в самом `429` данных не приходит.
  FlightEnvelope<T>? peek<T>(String key) {
    final entry = _cache[key];
    final value = entry?.envelope;
    return value is FlightEnvelope<T> ? value : null;
  }

  /// Сколько рейсов отслеживается — по прошлому ответу, без запроса. Нужен
  /// карточке входа на главной: своего запроса она не делает.
  int? get cachedWatchCount =>
      peek<List<FlightWatch>>('watches')?.data?.length;

  /// Сколько осталось до того, как запрос по этому ключу снова разрешён.
  Duration cooldown(String key, [Duration window = _live]) {
    final entry = _cache[key];
    if (entry == null) return Duration.zero;
    final passed = DateTime.now().difference(entry.at);
    final left = window - passed;
    return left.isNegative ? Duration.zero : left;
  }

  String boardKey(String code, {String? direction, String? from, String? to}) =>
      'board:${_n(code)}:$direction:$from:$to';

  String detailKey(FlightKey key) =>
      'detail:${_n(key.number)}:${key.flightDate}:${key.departureCode ?? ''}';

  void clear() => _cache.clear();

  static String _n(String value) => value.trim().toUpperCase();

  Future<FlightEnvelope<T>> _load<T>(
    String key,
    Duration ttl,
    Future<FlightEnvelope<T>> Function() load, {
    bool force = false,
  }) async {
    final entry = _cache[key];
    if (entry != null) {
      final age = DateTime.now().difference(entry.at);
      // `force` не пробивает окно живых данных: 30 секунд для табло и
      // карточки — требование бюджета, а не оптимизация отзывчивости.
      final floorHeld = ttl == _live && age < _live;
      if (floorHeld || (!force && age < ttl)) {
        final cached = entry.envelope;
        if (cached is FlightEnvelope<T>) return cached;
      }
    }
    final result = await load();
    _cache[key] = _Entry(result, DateTime.now());
    return result;
  }
}

class _Entry {
  final Object envelope;
  final DateTime at;

  _Entry(this.envelope, this.at);
}
