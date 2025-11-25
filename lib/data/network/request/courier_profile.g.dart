// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourierProfile _$CourierProfileFromJson(Map<String, dynamic> json) =>
    CourierProfile(
      experienceYears: json['experience_years'] as int,
      maxWeightKg: json['max_weight_kg'] as int,
      insuranceUsd: json['insurance_usd'] as int,
      priceFrom: (json['price_from'] as num).toDouble(),
      priceTo: (json['price_to'] as num).toDouble(),
      workTimeFrom: json['work_time_from'] as String,
      workTimeTo: json['work_time_to'] as String,
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      packageTypes: (json['package_types'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CourierProfileToJson(CourierProfile instance) =>
    <String, dynamic>{
      'experience_years': instance.experienceYears,
      'max_weight_kg': instance.maxWeightKg,
      'insurance_usd': instance.insuranceUsd,
      'price_from': instance.priceFrom,
      'price_to': instance.priceTo,
      'work_time_from': instance.workTimeFrom,
      'work_time_to': instance.workTimeTo,
      'languages': instance.languages,
      'package_types': instance.packageTypes,
    };
