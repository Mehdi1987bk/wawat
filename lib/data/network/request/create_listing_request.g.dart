// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_listing_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateListingRequest _$CreateListingRequestFromJson(
        Map<String, dynamic> json) =>
    CreateListingRequest(
      type: json['type'] as String,
      cityFromId: (json['city_from_id'] as num).toInt(),
      cityToId: (json['city_to_id'] as num).toInt(),
      packageTypeCodes: (json['package_type_codes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      allowPriceNegotiation: json['allow_price_negotiation'] as bool?,
      flightDate: json['flight_date'] as String?,
      flightTime: json['flight_time'] as String?,
      flightNumber: json['flight_number'] as String?,
      maxWeightKg: (json['max_weight_kg'] as num?)?.toDouble(),
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      deliveryDateFrom: json['delivery_date_from'] as String?,
      deliveryDateTo: json['delivery_date_to'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreateListingRequestToJson(
        CreateListingRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'city_from_id': instance.cityFromId,
      'city_to_id': instance.cityToId,
      'package_type_codes': instance.packageTypeCodes,
      if (instance.description case final value?) 'description': value,
      if (instance.allowPriceNegotiation case final value?)
        'allow_price_negotiation': value,
      if (instance.flightDate case final value?) 'flight_date': value,
      if (instance.flightTime case final value?) 'flight_time': value,
      if (instance.flightNumber case final value?) 'flight_number': value,
      if (instance.maxWeightKg case final value?) 'max_weight_kg': value,
      if (instance.pricePerKg case final value?) 'price_per_kg': value,
      if (instance.deliveryDateFrom case final value?)
        'delivery_date_from': value,
      if (instance.deliveryDateTo case final value?) 'delivery_date_to': value,
      if (instance.weightKg case final value?) 'weight_kg': value,
    };
