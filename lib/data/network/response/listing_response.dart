import 'package:json_annotation/json_annotation.dart';

part 'listing_response.g.dart';

double? _doubleFromJson(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _intFromJson(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

@JsonSerializable()
class ListingResponse {
  final Listing data;
  final String? message;
  final ListingMeta? meta;

  ListingResponse({
    required this.data,
    this.message,
    this.meta,
  });

  factory ListingResponse.fromJson(Map<String, dynamic> json) =>
      _$ListingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListingResponseToJson(this);
}

@JsonSerializable()
class ListingMessageResponse {
  final String? message;

  ListingMessageResponse({this.message});

  factory ListingMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$ListingMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListingMessageResponseToJson(this);
}

@JsonSerializable()
class ListingMeta {
  final List<Listing>? similar;

  @JsonKey(name: 'remaining_listings')
  final int? remainingListings;

  final int? matches;

  ListingMeta({
    this.similar,
    this.remainingListings,
    this.matches,
  });

  factory ListingMeta.fromJson(Map<String, dynamic> json) =>
      _$ListingMetaFromJson(json);

  Map<String, dynamic> toJson() => _$ListingMetaToJson(this);
}

@JsonSerializable()
class Listing {
  final String id;
  final String type;

  @JsonKey(name: 'type_label')
  final String? typeLabel;

  final String? status;

  @JsonKey(name: 'status_label')
  final String? statusLabel;

  @JsonKey(name: 'city_from_id')
  final int? cityFromId;

  @JsonKey(name: 'city_to_id')
  final int? cityToId;

  @JsonKey(name: 'city_from')
  final String? cityFrom;

  @JsonKey(name: 'city_to')
  final String? cityTo;

  @JsonKey(name: 'package_type_codes')
  final List<String> packageTypeCodes;

  final String? description;

  @JsonKey(name: 'view_count', fromJson: _intFromJson)
  final int? viewCount;

  @JsonKey(name: 'promotion_type')
  final String? promotionType;

  @JsonKey(name: 'favorites_count', fromJson: _intFromJson)
  final int? favoritesCount;

  @JsonKey(name: 'is_favorited')
  final bool isFavorited;

  final ListingOwner? owner;

  @JsonKey(name: 'flight_date')
  final String? flightDate;

  @JsonKey(name: 'flight_time')
  final String? flightTime;

  @JsonKey(name: 'flight_number')
  final String? flightNumber;

  @JsonKey(name: 'max_weight_kg', fromJson: _doubleFromJson)
  final double? maxWeightKg;

  @JsonKey(name: 'reserved_kg', fromJson: _doubleFromJson)
  final double? reservedKg;

  @JsonKey(name: 'price_per_kg', fromJson: _doubleFromJson)
  final double? pricePerKg;

  @JsonKey(name: 'allow_price_negotiation')
  final bool? allowPriceNegotiation;

  @JsonKey(name: 'delivery_date_from')
  final String? deliveryDateFrom;

  @JsonKey(name: 'delivery_date_to')
  final String? deliveryDateTo;

  @JsonKey(name: 'weight_kg', fromJson: _doubleFromJson)
  final double? weightKg;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  Listing({
    required this.id,
    required this.type,
    this.typeLabel,
    this.status,
    this.statusLabel,
    this.cityFromId,
    this.cityToId,
    this.cityFrom,
    this.cityTo,
    this.packageTypeCodes = const [],
    this.description,
    this.viewCount,
    this.promotionType,
    this.favoritesCount,
    this.isFavorited = false,
    this.owner,
    this.flightDate,
    this.flightTime,
    this.flightNumber,
    this.maxWeightKg,
    this.reservedKg,
    this.pricePerKg,
    this.allowPriceNegotiation,
    this.deliveryDateFrom,
    this.deliveryDateTo,
    this.weightKg,
    this.createdAt,
  });

  bool get isTrip => type == 'trip';

  bool get isShipment => type == 'shipment_post';

  double? get freeWeightKg {
    if (maxWeightKg == null) return null;
    return maxWeightKg! - (reservedKg ?? 0);
  }

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  Map<String, dynamic> toJson() => _$ListingToJson(this);
}

@JsonSerializable()
class ListingOwner {
  final String? id;

  final String? username;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'full_name')
  final String? fullName;

  @JsonKey(name: 'is_verified')
  final bool isVerified;

  final String? tier;

  @JsonKey(name: 'rating_avg', fromJson: _doubleFromJson)
  final double? ratingAvg;

  @JsonKey(name: 'rating_count', fromJson: _intFromJson)
  final int? ratingCount;

  @JsonKey(name: 'completed_shipments_count', fromJson: _intFromJson)
  final int? completedShipmentsCount;

  @JsonKey(name: 'avg_response_minutes', fromJson: _intFromJson)
  final int? avgResponseMinutes;

  ListingOwner({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.isVerified = false,
    this.tier,
    this.ratingAvg,
    this.ratingCount,
    this.completedShipmentsCount,
    this.avgResponseMinutes,
  });

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!;
    }
    final parts = [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .join(' ');
    if (parts.isNotEmpty) return parts;
    return username ?? '';
  }

  factory ListingOwner.fromJson(Map<String, dynamic> json) =>
      _$ListingOwnerFromJson(json);

  Map<String, dynamic> toJson() => _$ListingOwnerToJson(this);
}
