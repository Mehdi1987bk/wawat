// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_offer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOfferRequest _$DeliveryOfferRequestFromJson(
        Map<String, dynamic> json) =>
    DeliveryOfferRequest(
      offerTypeId: json['offer_type_id'] as int,
      packageTypeId: json['package_type_id'] as int,
      fromCityId: json['from_city_id'] as int,
      toCityId: json['to_city_id'] as int,
      dateFrom: json['date_from'] as String,
      dateTo: json['date_to'] as String,
      timeFrom: json['time_from'] as String,
      maxWeightKg: json['max_weight_kg'] as int,
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      description: json['description'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$DeliveryOfferRequestToJson(
        DeliveryOfferRequest instance) =>
    <String, dynamic>{
      'offer_type_id': instance.offerTypeId,
      'package_type_id': instance.packageTypeId,
      'from_city_id': instance.fromCityId,
      'to_city_id': instance.toCityId,
      'date_from': instance.dateFrom,
      'date_to': instance.dateTo,
      'time_from': instance.timeFrom,
      'max_weight_kg': instance.maxWeightKg,
      'price_per_kg': instance.pricePerKg,
      'description': instance.description,
      'is_active': instance.isActive,
    };
