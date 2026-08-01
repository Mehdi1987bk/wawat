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

bool _boolFromJson(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

String? _stringFromJson(Object? value) {
  final result = value?.toString().trim();
  return result == null || result.isEmpty ? null : result;
}

/// Pulls a usable URL/path out of a raw JSON value that may be a plain string
/// or a nested media object like `{"url": ...}` / `{"path": ...}`.
String? _unwrapUrl(Object? raw) {
  if (raw is String) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (raw is Map) {
    for (final key in const ['url', 'path', 'src', 'original', 'full']) {
      final value = raw[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  return null;
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

  final ListingPromotion? promotion;

  @JsonKey(name: 'favorites_count', fromJson: _intFromJson)
  final int? favoritesCount;

  @JsonKey(name: 'is_favorited')
  final bool isFavorited;

  final ListingOwner? owner;

  @JsonKey(name: 'owner_id')
  final String? ownerId;

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
    this.promotion,
    this.favoritesCount,
    this.isFavorited = false,
    this.owner,
    this.ownerId,
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

  /// No space left. The backend sends is_full=true only when
  /// status == 'fully_booked', so deriving it keeps the model in sync with the
  /// server contract without a separate JSON field / codegen run.
  bool get isFull => status == 'fully_booked';

  /// Some space taken but offers are still possible.
  bool get isPartiallyBooked => status == 'partially_booked';

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  Map<String, dynamic> toJson() => _$ListingToJson(this);
}

class ListingPromotion {
  final String? id;
  final String type;
  final String typeLabel;
  final String? tier;
  final String? tierLabel;
  final String? status;
  final String? statusLabel;
  final String? startsAt;
  final String? endsAt;
  final int? remainingSeconds;

  const ListingPromotion({
    this.id,
    required this.type,
    required this.typeLabel,
    this.tier,
    this.tierLabel,
    this.status,
    this.statusLabel,
    this.startsAt,
    this.endsAt,
    this.remainingSeconds,
  });

  factory ListingPromotion.fromJson(Map<String, dynamic> json) {
    return ListingPromotion(
      id: _stringFromJson(json['id']),
      type: json['type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? '',
      tier: _stringFromJson(json['tier']),
      tierLabel: _stringFromJson(json['tier_label']),
      status: _stringFromJson(json['status']) ?? 'active',
      statusLabel: _stringFromJson(json['status_label']),
      startsAt: _stringFromJson(json['starts_at']),
      endsAt: _stringFromJson(json['ends_at']),
      remainingSeconds: _intFromJson(json['remaining_seconds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'type_label': typeLabel,
      if (tier != null) 'tier': tier,
      if (tierLabel != null) 'tier_label': tierLabel,
      if (status != null) 'status': status,
      if (statusLabel != null) 'status_label': statusLabel,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (remainingSeconds != null) 'remaining_seconds': remainingSeconds,
    };
  }
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

  final String? avatar;

  /// 96×96 thumbnail url (`avatar_thumb_url`) — for the small card avatar.
  @JsonKey(name: 'avatar_thumb')
  final String? avatarThumb;

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
    this.avatar,
    this.avatarThumb,
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

  static String _resolve(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return 'https://api.wawatair.com/storage/$value';
  }

  /// Full avatar URL — use ONLY for a large/tap-to-open avatar.
  String get avatarUrl => _resolve(avatar);

  /// 96×96 thumbnail — use for the small card/list avatar. Falls back to the
  /// full url when the backend didn't send a thumb.
  String get avatarThumbUrl {
    final thumb = _resolve(avatarThumb);
    return thumb.isNotEmpty ? thumb : avatarUrl;
  }

  factory ListingOwner.fromJson(Map<String, dynamic> json) {
    final nestedUser = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    Object? value(String key) => json[key] ?? nestedUser[key];
    final normalized = Map<String, dynamic>.from(json)
      ..['id'] = _stringFromJson(
        value('id') ??
            value('user_id') ??
            value('ulid') ??
            value('uuid') ??
            json['owner_id'],
      )
      ..['username'] = _stringFromJson(value('username'))
      ..['first_name'] = _stringFromJson(value('first_name'))
      ..['last_name'] = _stringFromJson(value('last_name'))
      ..['full_name'] = _stringFromJson(value('full_name') ?? value('fullname'))
      ..['is_verified'] = _boolFromJson(value('is_verified'))
      ..['avatar'] = _unwrapUrl(value('avatar_url')) ??
          _unwrapUrl(value('avatar')) ??
          _unwrapUrl(value('avatar_thumb_url')) ??
          _unwrapUrl(value('photo_url')) ??
          _unwrapUrl(value('photo')) ??
          _unwrapUrl(value('profile_photo_url')) ??
          _unwrapUrl(value('profile_photo')) ??
          _unwrapUrl(value('profile_photo_path')) ??
          _unwrapUrl(value('picture_url')) ??
          _unwrapUrl(value('picture')) ??
          _unwrapUrl(value('image_url'))
      ..['avatar_thumb'] = _unwrapUrl(value('avatar_thumb_url')) ??
          _unwrapUrl(value('avatar_thumb')) ??
          _unwrapUrl(value('thumb_url'))
      ..['tier'] = _stringFromJson(value('tier'))
      ..['rating_avg'] = value('rating_avg')
      ..['rating_count'] = value('rating_count')
      ..['completed_shipments_count'] = value('completed_shipments_count')
      ..['avg_response_minutes'] = value('avg_response_minutes');
    return _$ListingOwnerFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$ListingOwnerToJson(this);
}
