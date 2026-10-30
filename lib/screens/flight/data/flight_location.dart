import 'package:geolocator/geolocator.dart';

/// Где находится телефон — только для экрана «Yaxınlıqda».
///
/// Имя не `FlightLocation`: так называется позиция самолёта в ответе `/detail`.
///
/// `/airports/nearby` принимает одни координаты: поиска по IP у провайдера
/// нет (§15). Точность нужна грубая — аэропорты ищутся в радиусе сотен
/// километров, поэтому запрашивается `low`, и без разрешения экран просто
/// показывает выбранные вручную аэропорты.
class FlightGeo {
  FlightGeo._();

  /// Чем кончилась попытка определить место.
  static Future<FlightPlace> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const FlightPlace.unavailable(FlightPlaceProblem.serviceOff);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const FlightPlace.unavailable(FlightPlaceProblem.blocked);
    }
    if (permission == LocationPermission.denied) {
      return const FlightPlace.unavailable(FlightPlaceProblem.denied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return FlightPlace(
        lat: position.latitude,
        lon: position.longitude,
        accuracyM: position.accuracy,
      );
    } catch (_) {
      // Таймаут или отказ железа: это не ошибка экрана, просто места нет.
      return const FlightPlace.unavailable(FlightPlaceProblem.noFix);
    }
  }
}

enum FlightPlaceProblem { serviceOff, denied, blocked, noFix }

class FlightPlace {
  final double? lat;
  final double? lon;
  final double? accuracyM;
  final FlightPlaceProblem? problem;

  const FlightPlace({
    required this.lat,
    required this.lon,
    this.accuracyM,
  }) : problem = null;

  const FlightPlace.unavailable(this.problem)
      : lat = null,
        lon = null,
        accuracyM = null;

  bool get hasPlace => lat != null && lon != null;
}
