import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/flight.dart';

/// Что раздел помнит на самом телефоне: история поиска и выбранные аэропорты.
///
/// На сервере этого нет — ни истории поиска рейсов, ни избранных аэропортов
/// в API не существует. Поэтому на экранах так и написано: «yalnız bu
/// cihazda» (только на этом устройстве).
class FlightLocalStore extends ChangeNotifier {
  FlightLocalStore._();

  static final FlightLocalStore instance = FlightLocalStore._();

  static const _recentsKey = 'flight_recent_searches';
  static const _airportsKey = 'flight_saved_airports';
  static const _flightsKey = 'flight_saved_flights';
  static const _maxRecents = 20;
  static const _maxFlights = 30;

  List<FlightRecent> _recents = const [];
  List<String> _airports = const [];
  List<FlightSaved> _flights = const [];
  bool _loaded = false;

  List<FlightRecent> get recents => _recents;
  List<String> get savedAirports => _airports;
  List<FlightSaved> get savedFlights => _flights;
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _recents = _decodeRecents(prefs.getString(_recentsKey));
    _airports = prefs.getStringList(_airportsKey) ?? const [];
    _flights = _decodeFlights(prefs.getString(_flightsKey));
    _loaded = true;
    notifyListeners();
  }

  bool isSavedFlight(FlightKey key) =>
      _flights.any((entry) => entry.key == key);

  /// Звёздочка в шапке карточки рейса. Избранных рейсов на сервере нет —
  /// только на этом телефоне, поэтому и подпись такая же, как у аэропортов.
  /// Возвращает новое состояние: добавили или убрали.
  Future<bool> toggleFlight(FlightSaved entry) async {
    final saved = isSavedFlight(entry.key);
    if (saved) {
      _flights =
          _flights.where((e) => e.key != entry.key).toList(growable: false);
    } else {
      final next = <FlightSaved>[
        entry,
        ..._flights.where((e) => e.key != entry.key),
      ];
      _flights = next.length > _maxFlights
          ? next.sublist(0, _maxFlights)
          : next;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _flightsKey,
      jsonEncode(_flights.map((e) => e.toJson()).toList()),
    );
    return !saved;
  }

  static List<FlightSaved> _decodeFlights(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => FlightSaved.fromJson(Map<String, dynamic>.from(e)))
          .whereType<FlightSaved>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> addRecent(FlightRecent entry) async {
    final next = <FlightRecent>[
      entry,
      ..._recents.where((e) => e.id != entry.id),
    ];
    _recents = next.length > _maxRecents
        ? next.sublist(0, _maxRecents)
        : next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recentsKey,
      jsonEncode(_recents.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearRecents() async {
    _recents = const [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentsKey);
  }

  bool isSaved(String code) => _airports.contains(code.toUpperCase());

  Future<void> toggleAirport(String code) async {
    final upper = code.toUpperCase();
    _airports = _airports.contains(upper)
        ? (_airports.where((e) => e != upper).toList())
        : <String>[upper, ..._airports];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_airportsKey, _airports);
  }

  static List<FlightRecent> _decodeRecents(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => FlightRecent.fromJson(Map<String, dynamic>.from(e)))
          .whereType<FlightRecent>()
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

/// Чем был поиск: номер рейса, аэропорт, самолёт или маршрут.
enum FlightRecentKind { flight, airport, aircraft, route }

/// Одна запись истории. Хранится ровно столько, сколько нужно, чтобы
/// повторить переход: вид, значение и то, что было на экране.
class FlightRecent {
  final FlightRecentKind kind;

  /// Номер рейса, код аэропорта, регистрация или `GYD-IST`.
  final String value;

  final String title;
  final String? subtitle;

  /// Дата рейса, если запись о конкретном рейсе.
  final String? date;

  const FlightRecent({
    required this.kind,
    required this.value,
    required this.title,
    this.subtitle,
    this.date,
  });

  String get id => '${kind.name}:$value:${date ?? ''}';

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'value': value,
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (date != null) 'date': date,
      };

  static FlightRecent? fromJson(Map<String, dynamic> json) {
    final value = json['value']?.toString();
    final title = json['title']?.toString();
    if (value == null || value.isEmpty || title == null) return null;
    return FlightRecent(
      kind: FlightRecentKind.values.firstWhere(
        (k) => k.name == json['kind'],
        orElse: () => FlightRecentKind.flight,
      ),
      value: value,
      title: title,
      subtitle: json['subtitle']?.toString(),
      date: json['date']?.toString(),
    );
  }
}

/// Отмеченный звёздочкой рейс. Хранится тройка (§4.1) и то, что нужно
/// нарисовать строку, не спрашивая сервер.
class FlightSaved {
  final String number;
  final String displayNumber;
  final String flightDate;
  final String? departureCode;
  final String? route;

  const FlightSaved({
    required this.number,
    required this.displayNumber,
    required this.flightDate,
    this.departureCode,
    this.route,
  });

  FlightKey get key => FlightKey(
        number: number,
        flightDate: flightDate,
        departureCode: departureCode,
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'display_number': displayNumber,
        'flight_date': flightDate,
        if (departureCode != null) 'departure_code': departureCode,
        if (route != null) 'route': route,
      };

  static FlightSaved? fromJson(Map<String, dynamic> json) {
    final number = json['number']?.toString();
    final date = json['flight_date']?.toString();
    if (number == null || number.isEmpty) return null;
    if (date == null || date.isEmpty) return null;
    return FlightSaved(
      number: number,
      displayNumber: json['display_number']?.toString() ?? number,
      flightDate: date,
      departureCode: json['departure_code']?.toString(),
      route: json['route']?.toString(),
    );
  }
}
