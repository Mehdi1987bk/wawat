import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/flight.dart';

/// Связки «объявление ↔ рейс» на самом телефоне.
///
/// Почему не на сервере. В объявлении бэкенд хранит только `flight_number`,
/// `flight_date` и `flight_time` — их приложение и пишет. Кода аэропорта
/// вылета у объявления нет: столбцы `flight_departure_code` и `flight_id` в
/// таблице есть, но `POST/PATCH /listings` их не принимает и ресурс их не
/// отдаёт (§15, пробел 1). А тройка без кода вылета неполная — один номер в
/// один день может выполнять несколько плеч.
///
/// Подписка тоже не вытягивает связку: `POST /watch` ждёт `listing_id`
/// внутренним числом, а приложение видит только ULID (§15, пробел 2).
///
/// Поэтому код вылета и ULID объявления хранятся здесь, рядом. Как только
/// бэкенд закроет оба пробела, хранилище убирается — связка начнёт приходить
/// в самом объявлении.
class FlightLinkStore extends ChangeNotifier {
  FlightLinkStore._();

  static final FlightLinkStore instance = FlightLinkStore._();

  static const _key = 'flight_listing_links';
  static const _max = 50;

  List<FlightLink> _links = const [];
  bool _loaded = false;

  List<FlightLink> get links => _links;
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _links = _decode(prefs.getString(_key));
    _loaded = true;
    notifyListeners();
  }

  /// Связка объявления, если она есть.
  FlightLink? forListing(String listingId) {
    for (final link in _links) {
      if (link.listingId == listingId) return link;
    }
    return null;
  }

  /// Объявления, привязанные к этому рейсу.
  List<FlightLink> forFlight(FlightKey key) => _links
      .where((link) => link.key == key)
      .toList(growable: false);

  Future<void> save(FlightLink link) async {
    final next = <FlightLink>[
      link,
      ..._links.where((e) => e.listingId != link.listingId),
    ];
    _links = next.length > _max ? next.sublist(0, _max) : next;
    notifyListeners();
    await _write();
  }

  Future<void> remove(String listingId) async {
    _links = _links.where((e) => e.listingId != listingId).toList();
    notifyListeners();
    await _write();
  }

  Future<void> _write() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_links.map((e) => e.toJson()).toList()),
    );
  }

  static List<FlightLink> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => FlightLink.fromJson(Map<String, dynamic>.from(e)))
          .whereType<FlightLink>()
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

/// Одна связка. Хранится ровно то, чего нет в ответе сервера.
class FlightLink {
  /// ULID объявления — такой, каким его отдаёт приложению ресурс.
  final String listingId;

  final String number;
  final String flightDate;
  final String? departureCode;

  /// Чтобы показать строку, пока объявление не загружено.
  final String? title;

  final DateTime linkedAt;

  const FlightLink({
    required this.listingId,
    required this.number,
    required this.flightDate,
    this.departureCode,
    this.title,
    required this.linkedAt,
  });

  FlightKey get key => FlightKey(
        number: number,
        flightDate: flightDate,
        departureCode: departureCode,
      );

  Map<String, dynamic> toJson() => {
        'listing_id': listingId,
        'number': number,
        'flight_date': flightDate,
        if (departureCode != null) 'departure_code': departureCode,
        if (title != null) 'title': title,
        'linked_at': linkedAt.toIso8601String(),
      };

  static FlightLink? fromJson(Map<String, dynamic> json) {
    final listingId = json['listing_id']?.toString();
    final number = json['number']?.toString();
    final date = json['flight_date']?.toString();
    if (listingId == null || listingId.isEmpty) return null;
    if (number == null || number.isEmpty) return null;
    if (date == null || date.isEmpty) return null;
    return FlightLink(
      listingId: listingId,
      number: number,
      flightDate: date,
      departureCode: json['departure_code']?.toString(),
      title: json['title']?.toString(),
      linkedAt:
          DateTime.tryParse(json['linked_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}
