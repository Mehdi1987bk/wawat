import '../flight_json.dart';

/// Аэропорт внутри `departure` / `arrival` карточки рейса (§7.2).
class AirportRef {
  final String? iata;
  final String? icao;
  final String? name;
  final String? municipality;
  final String? countryCode;
  final String? timeZone;
  final double? lat;
  final double? lon;

  const AirportRef({
    this.iata,
    this.icao,
    this.name,
    this.municipality,
    this.countryCode,
    this.timeZone,
    this.lat,
    this.lon,
  });

  factory AirportRef.fromJson(Map<String, dynamic> json) => AirportRef(
        iata: jString(json['iata']),
        icao: jString(json['icao']),
        name: jString(json['name']),
        municipality: jString(json['municipality']),
        countryCode: jString(json['country_code']),
        timeZone: jString(json['time_zone']),
        lat: jDouble(json['lat']),
        lon: jDouble(json['lon']),
      );

  /// Во всех дальнейших запросах используется IATA, а если его нет — ICAO.
  String? get code => iata ?? icao;

  bool get hasPosition => lat != null && lon != null;
}

/// Полоса (точнее — её голова): в массиве каждый элемент это один конец.
/// Пары «16/34» в API нет, `name` — одно значение.
class Runway {
  final String? name;
  final int? trueHeading;
  final int? lengthM;
  final int? widthM;

  /// Сырое английское значение провайдера: Unknown · Asphalt · Concrete ·
  /// Grass · Dirt · Gravel · DryLakebed · Water · Snow.
  final String? surface;

  final bool isClosed;
  final bool hasLighting;
  final int? displacedThresholdM;
  final double? lat;
  final double? lon;

  const Runway({
    this.name,
    this.trueHeading,
    this.lengthM,
    this.widthM,
    this.surface,
    this.isClosed = false,
    this.hasLighting = false,
    this.displacedThresholdM,
    this.lat,
    this.lon,
  });

  factory Runway.fromJson(Map<String, dynamic> json) => Runway(
        name: jString(json['name']),
        trueHeading: jInt(json['true_heading']),
        lengthM: jInt(json['length_m']),
        widthM: jInt(json['width_m']),
        surface: jString(json['surface']),
        isClosed: jBool(json['is_closed']),
        hasLighting: jBool(json['has_lighting']),
        displacedThresholdM: jInt(json['displaced_threshold_m']),
        lat: jDouble(json['lat']),
        lon: jDouble(json['lon']),
      );
}

/// Аэропорт в списке и в поиске (§7.3).
class AirportSummary {
  /// `iata`, а если его нет — `icao`. Используется во всех запросах.
  final String code;
  final String? iata;
  final String? icao;
  final String? name;
  final String? fullName;
  final String? city;
  final String? countryCode;
  final String? country;
  final String? timeZone;
  final double? lat;
  final double? lon;

  /// Наш редакционный флаг, а не выбор пользователя.
  final bool isFeatured;

  /// Приходит только в поиске по координатам (#11); в остальных ответах
  /// ключа нет и считать его заново не нужно.
  final double? distanceKm;

  const AirportSummary({
    required this.code,
    this.iata,
    this.icao,
    this.name,
    this.fullName,
    this.city,
    this.countryCode,
    this.country,
    this.timeZone,
    this.lat,
    this.lon,
    this.isFeatured = false,
    this.distanceKm,
  });

  factory AirportSummary.fromJson(Map<String, dynamic> json) {
    final iata = jString(json['iata']);
    final icao = jString(json['icao']);
    return AirportSummary(
      code: jString(json['code']) ?? iata ?? icao ?? '',
      iata: iata,
      icao: icao,
      name: jString(json['name']),
      fullName: jString(json['full_name']),
      city: jString(json['city']),
      countryCode: jString(json['country_code']),
      country: jString(json['country']),
      timeZone: jString(json['time_zone']),
      lat: jDouble(json['lat']),
      lon: jDouble(json['lon']),
      isFeatured: jBool(json['is_featured']),
      distanceKm: jDouble(json['distance_km']),
    );
  }

  /// Аэропорт из карточки рейса как запись списка: `departure.airport` и
  /// `arrival.airport` приходят короче (§7.2), но для привязки объявления и
  /// карты этого хватает.
  factory AirportSummary.fromRef(AirportRef ref) => AirportSummary(
        code: ref.code ?? '',
        iata: ref.iata,
        icao: ref.icao,
        name: ref.name,
        city: ref.municipality,
        countryCode: ref.countryCode,
        timeZone: ref.timeZone,
        lat: ref.lat,
        lon: ref.lon,
      );

  bool get hasPosition => lat != null && lon != null;

  /// «İstanbul (IST)» — город, если он есть, иначе название аэропорта.
  String get cityOrName => city ?? name ?? code;
}

/// Полная карточка аэропорта (§7.4).
class Airport {
  final AirportSummary summary;
  final String? continent;

  /// Может быть не латиницей (у Баку это `БАК`) — только показывать.
  final String? localCode;

  final int? elevationM;

  /// Считает сервер. Время устройства по `time_zone` не пересчитывается.
  final String? localTime;

  final Map<String, String> urls;
  final int? runwayCount;
  final List<Runway> runways;

  /// Сколько активных объявлений Wawatair проходит через этот аэропорт.
  /// Открыть их список нечем — показывать как число.
  final int? listingsCount;

  const Airport({
    required this.summary,
    this.continent,
    this.localCode,
    this.elevationM,
    this.localTime,
    this.urls = const {},
    this.runwayCount,
    this.runways = const [],
    this.listingsCount,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    final rawUrls = jMap(json['urls']) ?? const {};
    final urls = <String, String>{};
    rawUrls.forEach((key, value) {
      final v = jString(value);
      if (v != null) urls[key] = v;
    });
    return Airport(
      summary: AirportSummary.fromJson(json),
      continent: jString(json['continent']),
      localCode: jString(json['local_code']),
      elevationM: jInt(json['elevation_m']),
      localTime: jString(json['local_time']),
      urls: urls,
      runwayCount: jInt(json['runway_count']),
      runways:
          jMapList(json['runways']).map(Runway.fromJson).toList(growable: false),
      listingsCount: jInt(json['listings_count']),
    );
  }

  String get code => summary.code;
  String? get name => summary.name;
  String? get city => summary.city;
  String? get timeZone => summary.timeZone;
  double? get lat => summary.lat;
  double? get lon => summary.lon;

  String? get website => urls['website'];
  String? get wikipedia => urls['wikipedia'];
  String? get liveAtc => urls['live_atc'];
  String? get googleMaps => urls['google_maps'];

  /// Единственное исключение из «своих пересчётов не делайте»: API отдаёт
  /// только метры.
  int? get elevationFt =>
      elevationM == null ? null : (elevationM! * 3.280839895).round();
}
