import 'package:flutter/material.dart';

import 'data/models/flight.dart';
import 'flight_shell.dart';
import 'screens/airport/airport_list_screen.dart';
import 'screens/flight_home_screen.dart';
import 'screens/map/map_radar_screen.dart';
import 'screens/more/more_root_screen.dart';
import 'screens/search/search_home_screen.dart';
import 'screens/watch/watch_center_screen.dart';

/// Переходы раздела рейсов.
///
/// Раздел — обычный стек поверх вкладки «Kəşf»: у домашнего экрана модуля
/// стрелка назад ведёт в приложение, у остальных — на шаг назад. Панель
/// разделов (`mbar`) переключает пять корневых экранов заменой верхнего
/// экрана, поэтому стек не растёт, а «назад» с любого из них возвращает на
/// домашний экран модуля.
abstract final class FlightNav {
  static Future<T?> push<T>(BuildContext context, Widget screen) =>
      Navigator.of(context).push<T>(
        MaterialPageRoute<T>(builder: (_) => screen),
      );

  static Future<T?> replace<T>(BuildContext context, Widget screen) =>
      Navigator.of(context).pushReplacement<T, dynamic>(
        MaterialPageRoute<T>(builder: (_) => screen),
      );

  /// Вход в раздел с вкладки «Kəşf».
  static Future<void> open(BuildContext context) =>
      push(context, const FlightHomeScreen());

  /// Переключение корневых экранов панелью разделов.
  static Future<void> section(BuildContext context, FlightSection section) {
    final screen = switch (section) {
      FlightSection.map => const MapRadarScreen(),
      FlightSection.search => const SearchHomeScreen(),
      FlightSection.airports => const AirportListScreen(),
      FlightSection.watch => const WatchCenterScreen(),
      FlightSection.more => const MoreRootScreen(),
    };
    return replace(context, screen);
  }

  /// Переход на корневой экран раздела с обычного экрана: верхний экран
  /// заменяется, чтобы «назад» вёл на домашний экран модуля, а не по цепочке
  /// посещённых разделов.
  static Future<void> toSection(BuildContext context, FlightSection s) =>
      section(context, s);
}

/// Что открывать после выбора рейса. Экран выбора плеча и табло возвращают
/// тройку, а не объект: карточка рейса грузит `/detail` сама.
typedef FlightPicked = void Function(FlightKey key);
