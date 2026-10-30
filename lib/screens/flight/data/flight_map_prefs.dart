import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/flight_tokens.dart';

/// Что человек выбрал на экранах «Xəritə qatları» и «Süzgəclər».
///
/// Ни слои, ни фильтры на сервер не уходят: это настройка вида, и запросов
/// от неё не прибавляется (§9.2 — «Yalnız görünüş ayarıdır», «Süzgəc yerli
/// tətbiq olunur»). Храним на телефоне, чтобы радар открывался в том виде,
/// в каком его оставили.
///
/// Отличие от прототипа (§16): в макете «Yalnız havada olanlar» и
/// «Yük uçuşları» выставлены так, что часть подписанных рейсов с радара
/// пропадает сразу при входе. По замеру гайда (§5) бакинский трафик почти
/// целиком не в воздухе, и такой радар выглядел бы сломанным, поэтому по
/// умолчанию показывается всё, а фильтры человек включает сам.
class FlightMapPrefs extends ChangeNotifier {
  FlightMapPrefs._();

  static final FlightMapPrefs instance = FlightMapPrefs._();

  static const _tilesKey = 'flight_map_tiles';
  static const _routesKey = 'flight_map_layer_routes';
  static const _airportsKey = 'flight_map_layer_airports';
  static const _ringKey = 'flight_map_layer_ring';
  static const _scopeKey = 'flight_map_filter_scope';
  static const _altitudeKey = 'flight_map_filter_altitude';
  static const _airlineKey = 'flight_map_filter_airline';
  static const _airborneKey = 'flight_map_filter_airborne';
  static const _cargoKey = 'flight_map_filter_cargo';
  static const _positionKey = 'flight_map_filter_position';

  FMapTiles _tiles = FMapTiles.plain;
  bool _routes = true;
  bool _airports = true;
  bool _ring = true;
  FMapScope _scope = FMapScope.all;
  FMapAltitude _altitude = FMapAltitude.any;
  String? _airline;
  bool _airborneOnly = false;
  bool _cargo = true;
  bool _positionOnly = false;
  bool _loaded = false;

  FMapTiles get tiles => _tiles;
  bool get showRoutes => _routes;
  bool get showAirports => _airports;
  bool get showRing => _ring;
  FMapScope get scope => _scope;
  FMapAltitude get altitude => _altitude;
  String? get airline => _airline;
  bool get airborneOnly => _airborneOnly;
  bool get showCargo => _cargo;

  /// «Mövqesi var» — чип на радаре и тумблер на экране фильтров. По замеру
  /// гайда (§5) в Баку позиция не приходит почти никогда, поэтому по
  /// умолчанию фильтр выключен: иначе радар был бы пуст.
  bool get positionOnly => _positionOnly;

  bool get loaded => _loaded;

  /// Включён ли хоть один фильтр — от этого зависит значок на кнопке воронки.
  bool get filtered =>
      _scope != FMapScope.all ||
      _altitude != FMapAltitude.any ||
      _airline != null ||
      _airborneOnly ||
      _positionOnly ||
      !_cargo;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _tiles = _tilesOf(prefs.getString(_tilesKey));
    _routes = prefs.getBool(_routesKey) ?? true;
    _airports = prefs.getBool(_airportsKey) ?? true;
    _ring = prefs.getBool(_ringKey) ?? true;
    _scope = _scopeOf(prefs.getString(_scopeKey));
    _altitude = _altitudeOf(prefs.getString(_altitudeKey));
    final airline = prefs.getString(_airlineKey);
    _airline = airline == null || airline.isEmpty ? null : airline;
    _airborneOnly = prefs.getBool(_airborneKey) ?? false;
    _cargo = prefs.getBool(_cargoKey) ?? true;
    _positionOnly = prefs.getBool(_positionKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setTiles(FMapTiles value) async {
    if (_tiles == value) return;
    _tiles = value;
    notifyListeners();
    await _save((prefs) => prefs.setString(_tilesKey, value.name));
  }

  Future<void> setRoutes(bool value) async {
    _routes = value;
    notifyListeners();
    await _save((prefs) => prefs.setBool(_routesKey, value));
  }

  Future<void> setAirports(bool value) async {
    _airports = value;
    notifyListeners();
    await _save((prefs) => prefs.setBool(_airportsKey, value));
  }

  Future<void> setRing(bool value) async {
    _ring = value;
    notifyListeners();
    await _save((prefs) => prefs.setBool(_ringKey, value));
  }

  Future<void> setScope(FMapScope value) async {
    _scope = value;
    notifyListeners();
    await _save((prefs) => prefs.setString(_scopeKey, value.name));
  }

  Future<void> setAltitude(FMapAltitude value) async {
    _altitude = value;
    notifyListeners();
    await _save((prefs) => prefs.setString(_altitudeKey, value.name));
  }

  Future<void> setAirline(String? value) async {
    _airline = value;
    notifyListeners();
    await _save((prefs) => prefs.setString(_airlineKey, value ?? ''));
  }

  Future<void> setAirborneOnly(bool value) async {
    _airborneOnly = value;
    notifyListeners();
    await _save((prefs) => prefs.setBool(_airborneKey, value));
  }

  Future<void> setCargo(bool value) async {
    _cargo = value;
    notifyListeners();
    await _save((prefs) => prefs.setBool(_cargoKey, value));
  }

  Future<void> setPositionOnly(bool value) async {
    _positionOnly = value;
    notifyListeners();
    await _save((prefs) => prefs.setBool(_positionKey, value));
  }

  /// «Süzgəcləri sıfırla» — когда фильтр не оставил на радаре ничего.
  Future<void> resetFilters() async {
    _scope = FMapScope.all;
    _altitude = FMapAltitude.any;
    _airline = null;
    _airborneOnly = false;
    _cargo = true;
    _positionOnly = false;
    notifyListeners();
    await _save((prefs) async {
      await prefs.setString(_scopeKey, _scope.name);
      await prefs.setString(_altitudeKey, _altitude.name);
      await prefs.setString(_airlineKey, '');
      await prefs.setBool(_airborneKey, false);
      await prefs.setBool(_cargoKey, true);
      await prefs.setBool(_positionKey, false);
    });
  }

  Future<void> _save(Future<void> Function(SharedPreferences) write) async {
    final prefs = await SharedPreferences.getInstance();
    await write(prefs);
  }

  static FMapTiles _tilesOf(String? raw) => FMapTiles.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => FMapTiles.plain,
      );

  static FMapScope _scopeOf(String? raw) => FMapScope.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => FMapScope.all,
      );

  static FMapAltitude _altitudeOf(String? raw) =>
      FMapAltitude.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => FMapAltitude.any,
      );
}

/// Какие рейсы попадают на радар.
///
/// Радар строится только из подписок и выбранных рейсов — запроса «все
/// самолёты в районе» в API нет (§9.2). Поэтому «Hamısı» это подписки плюс
/// отмеченные на телефоне рейсы, «İzlədiyim» — только подписки с сервера, а
/// «Bizim marşrutlar» — те подписки, у которых есть привязанное объявление.
enum FMapScope { all, ourRoutes, watched }

/// Высота. Применима только к рейсам, у которых пришла позиция: высота,
/// скорость и курс приходят лишь вместе с `location` (§9.2).
enum FMapAltitude { any, high, descending }
