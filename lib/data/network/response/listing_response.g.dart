// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingResponse _$ListingResponseFromJson(Map<String, dynamic> json) =>
    ListingResponse(
      data: Listing.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
      meta: json['meta'] == null
          ? null
          : ListingMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListingResponseToJson(ListingResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'meta': instance.meta,
    };

ListingMessageResponse _$ListingMessageResponseFromJson(
        Map<String, dynamic> json) =>
    ListingMessageResponse(
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ListingMessageResponseToJson(
        ListingMessageResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

ListingMeta _$ListingMetaFromJson(Map<String, dynamic> json) => ListingMeta(
      similar: (json['similar'] as List<dynamic>?)
          ?.map((e) => Listing.fromJson(e as Map<String, dynamic>))
          .toList(),
      remainingListings: (json['remaining_listings'] as num?)?.toInt(),
      matches: (json['matches'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ListingMetaToJson(ListingMeta instance) =>
    <String, dynamic>{
      'similar': instance.similar,
      'remaining_listings': instance.remainingListings,
      'matches': instance.matches,
    };

Listing _$ListingFromJson(Map<String, dynamic> json) => Listing(
      id: json['id'] as String,
      type: json['type'] as String,
      typeLabel: json['type_label'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      cityFromId: (json['city_from_id'] as num?)?.toInt(),
      cityToId: (json['city_to_id'] as num?)?.toInt(),
      cityFrom: json['city_from'] as String?,
      cityTo: json['city_to'] as String?,
      packageTypeCodes: (json['package_type_codes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
      viewCount: _intFromJson(json['view_count']),
      promotionType: json['promotion_type'] as String?,
      favoritesCount: _intFromJson(json['favorites_count']),
      isFavorited: json['is_favorited'] as bool? ?? false,
      owner: json['owner'] == null
          ? null
          : ListingOwner.fromJson(json['owner'] as Map<String, dynamic>),
      flightDate: json['flight_date'] as String?,
      flightTime: json['flight_time'] as String?,
      flightNumber: json['flight_number'] as String?,
      maxWeightKg: _doubleFromJson(json['max_weight_kg']),
      reservedKg: _doubleFromJson(json['reserved_kg']),
      pricePerKg: _doubleFromJson(json['price_per_kg']),
      allowPriceNegotiation: json['allow_price_negotiation'] as bool?,
      deliveryDateFrom: json['delivery_date_from'] as String?,
      deliveryDateTo: json['delivery_date_to'] as String?,
      weightKg: _doubleFromJson(json['weight_kg']),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ListingToJson(Listing instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'type_label': instance.typeLabel,
      'status': instance.status,
      'status_label': instance.statusLabel,
      'city_from_id': instance.cityFromId,
      'city_to_id': instance.cityToId,
      'city_from': instance.cityFrom,
      'city_to': instance.cityTo,
      'package_type_codes': instance.packageTypeCodes,
      'description': instance.description,
      'view_count': instance.viewCount,
      'promotion_type': instance.promotionType,
      'favorites_count': instance.favoritesCount,
      'is_favorited': instance.isFavorited,
      'owner': instance.owner,
      'flight_date': instance.flightDate,
      'flight_time': instance.flightTime,
      'flight_number': instance.flightNumber,
      'max_weight_kg': instance.maxWeightKg,
      'reserved_kg': instance.reservedKg,
      'price_per_kg': instance.pricePerKg,
      'allow_price_negotiation': instance.allowPriceNegotiation,
      'delivery_date_from': instance.deliveryDateFrom,
      'delivery_date_to': instance.deliveryDateTo,
      'weight_kg': instance.weightKg,
      'created_at': instance.createdAt,
    };

ListingOwner _$ListingOwnerFromJson(Map<String, dynamic> json) => ListingOwner(
      id: json['id']?.toString(),
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      tier: json['tier'] as String?,
      ratingAvg: _doubleFromJson(json['rating_avg']),
      ratingCount: _intFromJson(json['rating_count']),
      completedShipmentsCount: _intFromJson(json['completed_shipments_count']),
      avgResponseMinutes: _intFromJson(json['avg_response_minutes']),
    );

Map<String, dynamic> _$ListingOwnerToJson(ListingOwner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'full_name': instance.fullName,
      'is_verified': instance.isVerified,
      'tier': instance.tier,
      'rating_avg': instance.ratingAvg,
      'rating_count': instance.ratingCount,
      'completed_shipments_count': instance.completedShipmentsCount,
      'avg_response_minutes': instance.avgResponseMinutes,
    };
