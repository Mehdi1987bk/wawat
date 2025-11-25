// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourierOfferModel _$CourierOfferModelFromJson(Map<String, dynamic> json) =>
    CourierOfferModel(
      offerType: json['offer_type'] as String,
      cityFromId: json['city_from_id'] as int,
      cityToId: json['city_to_id'] as int,
      flightDate: json['flight_date'] as String,
      flightTime: json['flight_time'] as String,
      deliveryDateFrom: json['delivery_date_from'] as String,
      deliveryDateTo: json['delivery_date_to'] as String,
      purchaseDate: json['purchase_date'] as String,
      purchaseTime: json['purchase_time'] as String,
      packageType: json['package_type'] as String,
      maxWeightKg: json['max_weight_kg'] as int,
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      description: json['description'] as String,
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CourierOfferModelToJson(CourierOfferModel instance) =>
    <String, dynamic>{
      'offer_type': instance.offerType,
      'city_from_id': instance.cityFromId,
      'city_to_id': instance.cityToId,
      'flight_date': instance.flightDate,
      'flight_time': instance.flightTime,
      'delivery_date_from': instance.deliveryDateFrom,
      'delivery_date_to': instance.deliveryDateTo,
      'purchase_date': instance.purchaseDate,
      'purchase_time': instance.purchaseTime,
      'package_type': instance.packageType,
      'max_weight_kg': instance.maxWeightKg,
      'price_per_kg': instance.pricePerKg,
      'description': instance.description,
      'languages': instance.languages,
    };
