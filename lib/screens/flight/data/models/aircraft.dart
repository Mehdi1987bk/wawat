import '../flight_json.dart';

/// Фото борта. Подпись обязательна по лицензии (§4.5): показываете фото —
/// показывайте `attributions`. Нет `image` — не показывать ни рамку, ни
/// строки автора и лицензии.
class AircraftImage {
  final String? url;
  final String? webUrl;
  final String? author;
  final String? title;

  /// Сырой enum провайдера — на экран не выводится, человеческий текст
  /// собирается в приложении.
  final String? license;

  /// Готовые HTML-строки.
  final List<String> attributions;

  const AircraftImage({
    this.url,
    this.webUrl,
    this.author,
    this.title,
    this.license,
    this.attributions = const [],
  });

  factory AircraftImage.fromJson(Map<String, dynamic> json) => AircraftImage(
        url: jString(json['url']),
        webUrl: jString(json['web_url']),
        author: jString(json['author']),
        title: jString(json['title']),
        license: jString(json['license']),
        attributions: jStringList(json['attributions']),
      );

  bool get hasImage => url != null;

  /// «Источник» — домен страницы снимка.
  String? get sourceDomain {
    final raw = webUrl;
    if (raw == null) return null;
    final host = Uri.tryParse(raw)?.host;
    if (host == null || host.isEmpty) return null;
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

/// 11 значений лицензии провайдера.
class AircraftLicense {
  AircraftLicense._();

  static const allRightsReserved = 'AllRightsReserved';
  static const byNcSa = 'AttributionNoncommercialShareAlikeCC';
  static const byNc = 'AttributionNoncommercialCC';
  static const byNcNd = 'AttributionNoncommercialNoDerivativesCC';
  static const by = 'AttributionCC';
  static const bySa = 'AttributionShareAlikeCC';
  static const byNd = 'AttributionNoDerivativesCC';
  static const noKnownRestrictions = 'NoKnownCopyrightRestrictions';
  static const usGovernmentWork = 'UnitedStatesGovernmentWork';
  static const cc0 = 'PublicDomainDedicationCC0';
  static const publicDomainMark = 'PublicDomainMark';

  /// Человеческое имя лицензии. Сырой enum на экране не показывается.
  static String? shortName(String? license) {
    switch (license) {
      case allRightsReserved:
        return 'All rights reserved';
      case byNcSa:
        return 'CC BY-NC-SA 4.0';
      case byNc:
        return 'CC BY-NC 4.0';
      case byNcNd:
        return 'CC BY-NC-ND 4.0';
      case by:
        return 'CC BY 4.0';
      case bySa:
        return 'CC BY-SA 4.0';
      case byNd:
        return 'CC BY-ND 4.0';
      case noKnownRestrictions:
        return 'No known copyright restrictions';
      case usGovernmentWork:
        return 'U.S. Government work';
      case cc0:
        return 'CC0 1.0';
      case publicDomainMark:
        return 'Public Domain Mark';
      default:
        return license;
    }
  }
}

/// Борт внутри карточки рейса.
class AircraftRef {
  final String? reg;
  final String? modeS;
  final String? model;
  final AircraftImage? image;

  const AircraftRef({this.reg, this.modeS, this.model, this.image});

  factory AircraftRef.fromJson(Map<String, dynamic> json) {
    final image = jMap(json['image']);
    return AircraftRef(
      reg: jString(json['reg']),
      modeS: jString(json['mode_s']),
      model: jString(json['model']),
      image: image == null ? null : AircraftImage.fromJson(image),
    );
  }
}

/// Запись в цепочке регистраций (наш формат, внутри паспорта борта).
class AircraftRegistration {
  final String? reg;
  final String? modeS;
  final String? airlineName;
  final String? registeredOn;
  final bool active;

  const AircraftRegistration({
    this.reg,
    this.modeS,
    this.airlineName,
    this.registeredOn,
    this.active = false,
  });

  factory AircraftRegistration.fromJson(Map<String, dynamic> json) =>
      AircraftRegistration(
        reg: jString(json['reg']),
        modeS: jString(json['mode_s']),
        airlineName: jString(json['airline_name']),
        registeredOn: jString(json['registered_on']),
        active: jBool(json['active']),
      );
}

/// Паспорт борта (§7.6). Для карточки хватает одного запроса
/// `GET /aircraft/{reg}` — `registrations[]` и `image` уже внутри и в нашем
/// формате.
class Aircraft {
  final String registration;
  final String? modeS;
  final String? serial;
  final String? model;
  final String? modelCode;
  final String? typeName;
  final String? iataType;
  final String? icaoCode;
  final String? airlineName;
  final String? productionLine;
  final int? seats;
  final int? engines;

  /// Слово провайдера: Unknown · Jet · Turboprop · Piston.
  final String? engineType;

  final bool isFreighter;
  final bool active;
  final bool verified;
  final double? ageYears;
  final String? rolloutDate;
  final String? firstFlightDate;
  final String? deliveryDate;
  final String? registrationDate;
  final AircraftImage? image;
  final List<AircraftRegistration> registrations;

  const Aircraft({
    required this.registration,
    this.modeS,
    this.serial,
    this.model,
    this.modelCode,
    this.typeName,
    this.iataType,
    this.icaoCode,
    this.airlineName,
    this.productionLine,
    this.seats,
    this.engines,
    this.engineType,
    this.isFreighter = false,
    this.active = false,
    this.verified = false,
    this.ageYears,
    this.rolloutDate,
    this.firstFlightDate,
    this.deliveryDate,
    this.registrationDate,
    this.image,
    this.registrations = const [],
  });

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    final image = jMap(json['image']);
    return Aircraft(
      registration: jString(json['registration']) ?? '',
      modeS: jString(json['mode_s']),
      serial: jString(json['serial']),
      model: jString(json['model']),
      modelCode: jString(json['model_code']),
      typeName: jString(json['type_name']),
      iataType: jString(json['iata_type']),
      icaoCode: jString(json['icao_code']),
      airlineName: jString(json['airline_name']),
      productionLine: jString(json['production_line']),
      seats: jInt(json['seats']),
      engines: jInt(json['engines']),
      engineType: jString(json['engine_type']),
      isFreighter: jBool(json['is_freighter']),
      active: jBool(json['active']),
      verified: jBool(json['verified']),
      ageYears: jDouble(json['age_years']),
      rolloutDate: jString(json['rollout_date']),
      firstFlightDate: jString(json['first_flight_date']),
      deliveryDate: jString(json['delivery_date']),
      registrationDate: jString(json['registration_date']),
      image: image == null ? null : AircraftImage.fromJson(image),
      registrations: jMapList(json['registrations'])
          .map(AircraftRegistration.fromJson)
          .toList(growable: false),
    );
  }

  /// «A20N · Airbus A320neo»
  String? get typeLine {
    final parts = [icaoCode, typeName].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// Элемент парка авиакомпании. Ответ провайдера проходит как есть, поэтому
/// имена полей здесь camelCase.
class FleetItem {
  final String? reg;
  final String? model;
  final String? modelCode;
  final String? typeName;
  final int? numSeats;
  final int? numEngines;
  final String? engineType;
  final bool isFreighter;
  final bool active;
  final double? ageYears;
  final String? airlineName;

  const FleetItem({
    this.reg,
    this.model,
    this.modelCode,
    this.typeName,
    this.numSeats,
    this.numEngines,
    this.engineType,
    this.isFreighter = false,
    this.active = false,
    this.ageYears,
    this.airlineName,
  });

  factory FleetItem.fromJson(Map<String, dynamic> json) => FleetItem(
        reg: jString(json['reg']),
        model: jString(json['model']),
        modelCode: jString(json['modelCode']),
        typeName: jString(json['typeName']),
        numSeats: jInt(json['numSeats']),
        numEngines: jInt(json['numEngines']),
        engineType: jString(json['engineType']),
        isFreighter: jBool(json['isFreighter']),
        active: jBool(json['active']),
        ageYears: jDouble(json['ageYears']),
        airlineName: jString(json['airlineName']),
      );
}

/// Страница парка: `totalCount` · `pageOffset` · `pageSize` · `hasNextPage` ·
/// `count` · `items[]`.
class FleetPage {
  final int? totalCount;
  final int? pageOffset;
  final int? pageSize;
  final bool hasNextPage;
  final int? count;
  final List<FleetItem> items;

  const FleetPage({
    this.totalCount,
    this.pageOffset,
    this.pageSize,
    this.hasNextPage = false,
    this.count,
    this.items = const [],
  });

  factory FleetPage.fromJson(Map<String, dynamic> json) => FleetPage(
        totalCount: jInt(json['totalCount']),
        pageOffset: jInt(json['pageOffset']),
        pageSize: jInt(json['pageSize']),
        hasNextPage: jBool(json['hasNextPage']),
        count: jInt(json['count']),
        items: jMapList(json['items'])
            .map(FleetItem.fromJson)
            .toList(growable: false),
      );
}

/// Запись регистрации из отдельного эндпоинта `#24`: тело провайдера как
/// есть, ключи camelCase. Это **другой формат**, чем `registrations[]` внутри
/// паспорта — смешивать их нельзя.
class ProviderRegistration {
  final String? reg;
  final bool active;
  final String? hexIcao;
  final String? airlineName;
  final String? registrationDate;

  const ProviderRegistration({
    this.reg,
    this.active = false,
    this.hexIcao,
    this.airlineName,
    this.registrationDate,
  });

  factory ProviderRegistration.fromJson(Map<String, dynamic> json) =>
      ProviderRegistration(
        reg: jString(json['reg']),
        active: jBool(json['active']),
        hexIcao: jString(json['hexIcao']),
        airlineName: jString(json['airlineName']),
        registrationDate: jString(json['registrationDate']),
      );
}

/// Фото из отдельного эндпоинта `#25`: тело провайдера как есть — подписи
/// лежат в `htmlAttributions`, а не в `attributions`, и есть `description`,
/// которого нет в нашем формате.
class ProviderAircraftImage {
  final String? url;
  final String? webUrl;
  final String? author;
  final String? title;
  final String? description;
  final String? license;
  final List<String> htmlAttributions;

  const ProviderAircraftImage({
    this.url,
    this.webUrl,
    this.author,
    this.title,
    this.description,
    this.license,
    this.htmlAttributions = const [],
  });

  factory ProviderAircraftImage.fromJson(Map<String, dynamic> json) =>
      ProviderAircraftImage(
        url: jString(json['url']),
        webUrl: jString(json['webUrl']),
        author: jString(json['author']),
        title: jString(json['title']),
        description: jString(json['description']),
        license: jString(json['license']),
        htmlAttributions: jStringList(json['htmlAttributions']),
      );

  /// Приводит провайдерский формат к нашему, чтобы экран галереи рисовался
  /// одним кодом независимо от источника.
  AircraftImage toAircraftImage() => AircraftImage(
        url: url,
        webUrl: webUrl,
        author: author,
        title: title,
        license: license,
        attributions: htmlAttributions,
      );
}
