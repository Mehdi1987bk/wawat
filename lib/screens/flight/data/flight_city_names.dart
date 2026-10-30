import 'models/airport.dart';
import 'flight_repository.dart';

/// Названия городов по коду аэропорта.
///
/// В ответе табло города нет — только `arrival_code` / `departure_code`
/// (§9.8), а строка должна читаться как «İstanbul (IST)». Делать запрос на
/// каждую строку нельзя: бюджет `throttle:flightdata` — 3 запроса в секунду,
/// а на табло их двадцать. Поэтому один раз за сеанс берётся наш каталог
/// лиманов и дальше код раскрывается по памяти; чего в каталоге нет,
/// показывается кодом — выдумывать город неоткуда.
abstract final class FlightCityNames {
  static Map<String, String> _cities = const {};
  static bool _loaded = false;

  /// Каталог берётся с запасом. Если сервер такой `limit` не принимает,
  /// остаётся список по умолчанию — экран от этого не ломается.
  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final repo = FlightRepository.instance;
    List<AirportSummary>? list;
    try {
      list = (await repo.airports(limit: 200)).data;
    } catch (_) {
      try {
        list = (await repo.airports()).data;
      } catch (_) {
        list = null;
      }
    }
    if (list == null) return;
    final map = <String, String>{};
    for (final airport in list) {
      final city = airport.city ?? airport.name;
      if (city == null || city.isEmpty) continue;
      for (final code in [airport.code, airport.iata, airport.icao]) {
        if (code != null && code.isNotEmpty) map[code.toUpperCase()] = city;
      }
    }
    _cities = map;
  }

  /// Город, если он известен; иначе `null`.
  static String? city(String? code) =>
      code == null ? null : _cities[code.toUpperCase()];

  /// «İstanbul (IST)» — или просто «IST», когда города нет.
  static String label(String? code) {
    if (code == null || code.isEmpty) return '—';
    final name = city(code);
    return name == null ? code : '$name ($code)';
  }

  /// Пополняется теми аэропортами, которые экраны и так загрузили.
  static void remember(Iterable<AirportSummary> airports) {
    if (airports.isEmpty) return;
    final map = Map<String, String>.of(_cities);
    for (final airport in airports) {
      final city = airport.city ?? airport.name;
      if (city == null || city.isEmpty) continue;
      for (final code in [airport.code, airport.iata, airport.icao]) {
        if (code != null && code.isNotEmpty) map[code.toUpperCase()] = city;
      }
    }
    _cities = map;
  }
}
