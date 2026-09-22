import 'city.dart';

class PopularRoutesResponse {
  final List<PopularRoute> data;

  const PopularRoutesResponse({required this.data});

  factory PopularRoutesResponse.fromJson(Map<String, dynamic> json) {
    final rawRoutes = json['data'];
    if (rawRoutes is! List) {
      return const PopularRoutesResponse(data: []);
    }

    return PopularRoutesResponse(
      data: rawRoutes
          .whereType<Map>()
          .map((route) => PopularRoute.fromJson(
                Map<String, dynamic>.from(route),
              ))
          .toList(growable: false),
    );
  }
}

class PopularRoute {
  final int cityFromId;
  final int cityToId;
  final String cityFrom;
  final String cityTo;
  final int travelersCount;
  final num minPrice;
  final String currency;

  const PopularRoute({
    required this.cityFromId,
    required this.cityToId,
    required this.cityFrom,
    required this.cityTo,
    required this.travelersCount,
    required this.minPrice,
    required this.currency,
  });

  factory PopularRoute.fromJson(Map<String, dynamic> json) {
    return PopularRoute(
      cityFromId: _asInt(json['city_from_id']),
      cityToId: _asInt(json['city_to_id']),
      cityFrom: json['city_from']?.toString() ?? '',
      cityTo: json['city_to']?.toString() ?? '',
      travelersCount: _asInt(json['travelers_count']),
      minPrice: _asNum(json['min_price']),
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  City get fromCity => City(
        id: cityFromId,
        name: cityFrom,
        countryId: 0,
        countryCode: '',
        countryName: '',
      );

  City get toCity => City(
        id: cityToId,
        name: cityTo,
        countryId: 0,
        countryCode: '',
        countryName: '',
      );

  String get label => '$cityFrom → $cityTo';

  String get formattedMinPrice {
    final value = minPrice.toDouble();
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

num _asNum(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}
