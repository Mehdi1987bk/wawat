import 'package:dio/dio.dart';

import 'flight_envelope.dart';
import 'flight_error.dart';
import 'flight_json.dart';
import 'flight_throttle.dart';
import 'models/aircraft.dart';
import 'models/airport.dart';
import 'models/flight.dart';
import 'models/flight_stats.dart';
import 'models/flight_watch.dart';

/// Все 28 эндпоинтов раздела (§6).
///
/// Правила, зашитые здесь, а не в экранах:
/// * конверт всегда `{data, meta?, message?}`;
/// * `200 + data: []` — пустота, а не ошибка; `204` не приходит никогда;
/// * ошибки поднимаются как [FlightError], разобранный по §12;
/// * свой лимит 3 запроса в секунду держит [FlightThrottle] — один на весь
///   раздел, потому что бюджет общий.
///
/// Провайдер напрямую не вызывается ни при каких условиях: ключ живёт только
/// на нашем сервере.
class FlightApi {
  FlightApi(this._dio, {this.baseUrl = 'https://api.wawatair.com/api/v1'});

  final Dio _dio;
  final String baseUrl;

  static final FlightThrottle _throttle = FlightThrottle();

  // ───────────────────────────── 6.1 Рейсы ─────────────────────────────

  /// #1 Подсказки номеров. Возвращает **только строки**: `["TK333","TK335"]`.
  /// Ни маршрута, ни времени здесь нет — за ними идёт второй запрос [flights].
  Future<FlightEnvelope<List<String>>> searchFlightNumbers(
    String query, {
    int? limit,
  }) =>
      _get('/flights/search', query: {
        'q': query,
        if (limit != null) 'limit': limit,
      }, convert: (raw) => jStringList(raw));

  /// #2 Даты, когда рейс летает.
  Future<FlightEnvelope<List<String>>> flightDates(
    String number, {
    String? from,
    String? to,
  }) =>
      _get('/flights/${_seg(number)}/dates', query: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      }, convert: (raw) => jStringList(raw));

  /// #3 Рейсы под номером за дату — **массив**: пусто → нет рейса,
  /// один → карточка, два и больше → выбор плеча (§4.1).
  Future<FlightEnvelope<List<FlightSummary>>> flights(
    String number,
    String date,
  ) =>
      _get('/flights/${_seg(number)}/$date', convert: _summaries);

  /// #4 Полная карточка. `departure_code` обязателен по смыслу, когда под
  /// номером летит больше одного плеча — иначе сервер выберет не то.
  Future<FlightEnvelope<FlightDetail>> flightDetail(
    String number,
    String date, {
    String? departureCode,
  }) =>
      _get('/flights/${_seg(number)}/$date/detail', query: {
        if (departureCode != null) 'departure_code': departureCode,
      }, convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : FlightDetail.fromJson(m);
      });

  /// #5 Чем борт летит в эту дату.
  Future<FlightEnvelope<List<FlightSummary>>> flightsByRegistration(
    String registration,
    String date,
  ) =>
      _get('/flights/by-registration/${_seg(registration)}/$date',
          convert: _summaries);

  /// #6 Рейсы маршрута за день. Единственный путь собрать тройку
  /// `number + flight_date + departure_code` для привязки объявления.
  Future<FlightEnvelope<List<FlightSummary>>> routeFlights(
    String from,
    String to,
    String date,
  ) =>
      _get('/routes/${_seg(from)}/${_seg(to)}/$date', convert: _summaries);

  /// #7 История рейса. Окно максимум 14 дней — сервер обрежет сам и вернёт
  /// фактическое в `meta.from` / `meta.to`.
  Future<FlightEnvelope<List<FlightSummary>>> flightHistory(
    String number, {
    String? from,
    String? to,
  }) =>
      _get('/flights/${_seg(number)}/history', query: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      }, convert: _summaries);

  /// #8 Статистика задержек рейса. Тело провайдера проходит как есть (§7.5).
  Future<FlightEnvelope<FlightDelayStats>> flightDelays(String number) =>
      _get('/flights/${_seg(number)}/delays', convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : FlightDelayStats.fromJson(m);
      });

  // ─────────────────────────── 6.2 Аэропорты ───────────────────────────

  /// #9 Наш каталог, избранные вперёд.
  Future<FlightEnvelope<List<AirportSummary>>> airports({int? limit}) =>
      _get('/airports', query: {
        if (limit != null) 'limit': limit,
      }, convert: _airports);

  /// #10 Поиск по названию, городу и коду. `distance_km` здесь не приходит.
  Future<FlightEnvelope<List<AirportSummary>>> searchAirports(
    String query, {
    int? limit,
  }) =>
      _get('/airports/search', query: {
        'q': query,
        if (limit != null) 'limit': limit,
      }, convert: _airports);

  /// #11 Аэропорты рядом. Единственный ответ с готовым `distance_km`, и
  /// список уже отсортирован по близости — пересчитывать не нужно.
  Future<FlightEnvelope<List<AirportSummary>>> nearbyAirports({
    required double lat,
    required double lon,
    int? radiusKm,
    int? limit,
  }) =>
      _get('/airports/search', query: {
        'lat': lat,
        'lon': lon,
        if (radiusKm != null) 'radius_km': radiusKm,
        if (limit != null) 'limit': limit,
      }, convert: _airports);

  /// #12 Карточка аэропорта.
  Future<FlightEnvelope<Airport>> airport(String code) =>
      _get('/airports/${_seg(code)}', convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : Airport.fromJson(m);
      });

  /// #13 Полосы. Каждый элемент — один конец полосы, пары «16/34» в API нет.
  Future<FlightEnvelope<List<Runway>>> runways(String code) =>
      _get('/airports/${_seg(code)}/runways',
          convert: (raw) =>
              jMapList(raw).map(Runway.fromJson).toList(growable: false));

  /// #14 Табло. Три ограничения: `from`/`to` — местное время аэропорта в
  /// формате `2026-11-01T06:00`, окно не больше 12 часов, и если передан
  /// `from`, то `to` обязателен (иначе 422). Без окна сервер отдаёт
  /// «−2 ч … +10 ч» от местного времени.
  ///
  /// Фильтров у табло больше нет: «только прямые», codeshare и грузовые —
  /// фильтры на стороне приложения по полученному массиву.
  Future<FlightEnvelope<List<FlightSummary>>> board(
    String code, {
    String? direction,
    String? from,
    String? to,
  }) =>
      _get('/airports/${_seg(code)}/board', query: {
        if (direction != null) 'direction': direction,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      }, convert: _summaries);

  /// #15 / #16 Задержки аэропорта: `date` — на момент, `from`+`to` — за окно
  /// (максимум 12 часов, формат `2026-11-01T06:00`).
  Future<FlightEnvelope<AirportDelays>> airportDelays(
    String code, {
    String? date,
    String? from,
    String? to,
  }) =>
      _get('/airports/${_seg(code)}/delays', query: {
        if (date != null) 'date': date,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      }, convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : AirportDelays.fromJson(m);
      });

  /// #17 Направления. `data` сразу массив — обёртку `{routes:…}` сервер снял.
  Future<FlightEnvelope<List<AirportRoute>>> airportRoutes(
    String code, {
    String? date,
  }) =>
      _get('/airports/${_seg(code)}/routes', query: {
        if (date != null) 'date': date,
      },
          convert: (raw) =>
              jMapList(raw).map(AirportRoute.fromJson).toList(growable: false));

  /// #18 Рассвет, закат, положение солнца.
  Future<FlightEnvelope<SolarInfo>> solar(String code, {String? date}) =>
      _get('/airports/${_seg(code)}/solar', query: {
        if (date != null) 'date': date,
      }, convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : SolarInfo.fromJson(m);
      });

  /// #19 Какие потоки живы у этого аэропорта. Этим объясняется «почему тут
  /// нет живых данных» — на всех экранах, где такой вопрос возникает.
  Future<FlightEnvelope<AirportFeeds>> feeds(String code) =>
      _get('/airports/${_seg(code)}/feeds', convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : AirportFeeds.fromJson(m);
      });

  /// #20 Задержки по миру — около 1710 аэропортов. Ключ — `airportIcao`.
  Future<FlightEnvelope<List<GlobalDelayItem>>> globalDelays({String? date}) =>
      _get('/airports/delays', query: {
        if (date != null) 'date': date,
      },
          convert: (raw) => jMapList(raw)
              .map(GlobalDelayItem.fromJson)
              .toList(growable: false));

  /// #21 Расстояние и примерное время полёта.
  Future<FlightEnvelope<AirportDistance>> distance(
    String from,
    String to,
  ) =>
      _get('/airports/${_seg(from)}/distance/${_seg(to)}', convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : AirportDistance.fromJson(m);
      });

  // ──────────────────────────── 6.3 Самолёты ───────────────────────────

  /// #22 Подсказки бортовых номеров. Ответ провайдера как есть: массив
  /// `items`, элементы camelCase — те же поля, что у парка.
  Future<FlightEnvelope<List<FleetItem>>> searchAircraft(
    String query, {
    int? limit,
  }) =>
      _get('/aircraft/search', query: {
        'q': query,
        if (limit != null) 'limit': limit,
      }, convert: (raw) {
        final list = raw is List ? raw : jMap(raw)?['items'];
        return jMapList(list).map(FleetItem.fromJson).toList(growable: false);
      });

  /// #23 Паспорт борта. Для карточки хватает **одного** этого запроса:
  /// `registrations[]` и `image` уже внутри и в нашем формате. У этого ответа
  /// нет ключа `meta` — полоска «данные на …» на паспорте не показывается.
  Future<FlightEnvelope<Aircraft>> aircraft(String registration) =>
      _get('/aircraft/${_seg(registration)}', convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : Aircraft.fromJson(m);
      });

  /// #24 История регистраций отдельным запросом: тело провайдера как есть,
  /// `data` — сразу массив, ключи camelCase (`hexIcao`, `airlineName`,
  /// `registrationDate`). Два формата смешивать нельзя; карточке он не нужен.
  Future<FlightEnvelope<List<ProviderRegistration>>> aircraftRegistrations(
    String registration,
  ) =>
      _get('/aircraft/${_seg(registration)}/registrations',
          convert: (raw) => jMapList(raw)
              .map(ProviderRegistration.fromJson)
              .toList(growable: false));

  /// #25 Фото отдельным запросом: тело провайдера как есть — там
  /// `htmlAttributions`, а не `attributions`. Нет фото → `200` + `data: null`.
  Future<FlightEnvelope<ProviderAircraftImage>> aircraftImage(
    String registration,
  ) =>
      _get('/aircraft/${_seg(registration)}/image', convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : ProviderAircraftImage.fromJson(m);
      });

  /// #26 Парк авиакомпании. `offset` считается от нуля — номер страницы не
  /// принимается.
  Future<FlightEnvelope<FleetPage>> fleet(
    String airline, {
    int? perPage,
    int? offset,
  }) =>
      _get('/airlines/${_seg(airline)}/fleet', query: {
        if (perPage != null) 'per_page': perPage,
        if (offset != null) 'offset': offset,
      }, convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : FleetPage.fromJson(m);
      });

  // ─────────────────────────── 6.4 Служебное ───────────────────────────

  /// #27 Здоровье потоков. Предупреждающая полоска показывается только при
  /// `degraded: true`.
  Future<FlightEnvelope<FlightDataHealth>> health() =>
      _get('/flight-data/health', convert: (raw) {
        final m = jMap(raw);
        return m == null ? null : FlightDataHealth.fromJson(m);
      });

  // ──────────────────────────── 6.5 Слежение ───────────────────────────

  /// #28a Мои подписки, отсортированы по времени вылета. Рейс лежит внутри
  /// каждой записи — догружать его отдельно не нужно.
  Future<FlightEnvelope<List<FlightWatch>>> watches() =>
      _get('/me/flight-watches',
          convert: (raw) =>
              jMapList(raw).map(FlightWatch.fromJson).toList(growable: false));

  /// #28b Подписаться. Повторный POST обновляет существующую подписку,
  /// второй не создаётся. Пустой массив `events` сервер отклонит (422) —
  /// не передавайте его вовсе, если нужен набор по умолчанию.
  Future<FlightEnvelope<FlightWatch>> watch(
    String number,
    String date, {
    String? departureCode,
    int? listingId,
    List<String>? events,
    int? muteHours,
  }) =>
      _request<FlightWatch>(
        'POST',
        '/flights/${_seg(number)}/$date/watch',
        body: {
          if (departureCode != null) 'departure_code': departureCode,
          if (listingId != null) 'listing_id': listingId,
          if (events != null && events.isNotEmpty) 'events': events,
          // Ключ не послать — сервер сбросит `muted_until`. Поэтому при
          // обычном сохранении событий тишину нужно присылать заново.
          if (muteHours != null) 'mute_hours': muteHours,
        },
        convert: (raw) {
          final m = jMap(raw);
          return m == null ? null : FlightWatch.fromJson(m);
        },
      );

  /// #28c Отписаться → `204`. Подписки нет → `404 NOT_FOUND`.
  Future<void> unwatch(
    String number,
    String date, {
    String? departureCode,
  }) async {
    await _send(
      'DELETE',
      '/flights/${_seg(number)}/$date/watch',
      query: {
        if (departureCode != null) 'departure_code': departureCode,
      },
    );
  }

  // ───────────────────────────── внутреннее ────────────────────────────

  static List<FlightSummary> _summaries(Object? raw) =>
      jMapList(raw).map(FlightSummary.fromJson).toList(growable: false);

  static List<AirportSummary> _airports(Object? raw) =>
      jMapList(raw).map(AirportSummary.fromJson).toList(growable: false);

  /// Путь собирается из кодов, которые приходят от сервера, но кодировать
  /// всё равно нужно: бортовые номера содержат дефис, а имена файлов и
  /// регистры у провайдера бывают любыми.
  static String _seg(String value) => Uri.encodeComponent(value.trim());

  Future<FlightEnvelope<T>> _get<T>(
    String path, {
    Map<String, Object?>? query,
    required T? Function(Object? raw) convert,
  }) =>
      _request<T>('GET', path, query: query, convert: convert);

  Future<FlightEnvelope<T>> _request<T>(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    required T? Function(Object? raw) convert,
  }) async {
    final response = await _send(method, path, query: query, body: body);
    final data = response.data;
    if (data is Map) {
      return FlightEnvelope.parse<T>(Map<String, dynamic>.from(data), convert);
    }
    // Конверт сервером гарантирован; этот путь остаётся только чтобы
    // неожиданный ответ не падал исключением разбора.
    return FlightEnvelope<T>(data: convert(data));
  }

  Future<Response<dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
  }) =>
      _throttle.run(() async {
        try {
          return await _dio.request<dynamic>(
            '$baseUrl$path',
            data: body,
            queryParameters: query == null || query.isEmpty ? null : query,
            options: Options(method: method),
          );
        } catch (error) {
          throw FlightError.from(error);
        }
      });
}
