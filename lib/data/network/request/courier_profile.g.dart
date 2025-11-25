// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourierProfile _$CourierProfileFromJson(Map<String, dynamic> json) =>
    CourierProfile(
      workExperienceYears: json['work_experience_years'] as int,
      maxWeightKg: json['max_weight_kg'] as int,
      insuranceAmount: json['insurance_amount'] as int,
      pricePerKgMin: (json['price_per_kg_min'] as num).toDouble(),
      pricePerKgMax: (json['price_per_kg_max'] as num).toDouble(),
      workTimeFrom: json['work_time_from'] as String,
      workTimeTo: json['work_time_to'] as String,
      communicationLanguageIds:
          (json['communication_language_ids'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      packageTypeIds: (json['package_type_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CourierProfileToJson(CourierProfile instance) =>
    <String, dynamic>{
      'work_experience_years': instance.workExperienceYears,
      'max_weight_kg': instance.maxWeightKg,
      'insurance_amount': instance.insuranceAmount,
      'price_per_kg_min': instance.pricePerKgMin,
      'price_per_kg_max': instance.pricePerKgMax,
      'work_time_from': instance.workTimeFrom,
      'work_time_to': instance.workTimeTo,
      'communication_language_ids': instance.communicationLanguageIds,
      'package_type_ids': instance.packageTypeIds,
    };
