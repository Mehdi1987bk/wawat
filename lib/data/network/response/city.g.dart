// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      countryId: (_countryIdFromJson(json, 'country_id') as num).toInt(),
      countryCode: _countryCodeFromJson(json, 'country_code') as String,
      countryName: _countryNameFromJson(json, 'country_name') as String,
    );

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country_id': instance.countryId,
      'country_code': instance.countryCode,
      'country_name': instance.countryName,
    };
