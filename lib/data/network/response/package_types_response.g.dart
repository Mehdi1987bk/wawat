// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageTypesResponse _$PackageTypesResponseFromJson(
        Map<String, dynamic> json) =>
    PackageTypesResponse(
      data: (json['package_types'] as List<dynamic>)
          .map((e) => PackageType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PackageTypesResponseToJson(
        PackageTypesResponse instance) =>
    <String, dynamic>{
      'package_types': instance.data,
    };

PackageType _$PackageTypeFromJson(Map<String, dynamic> json) => PackageType(
      code: json['code'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$PackageTypeToJson(PackageType instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'icon': instance.icon,
    };

PackageTypeTranslation _$PackageTypeTranslationFromJson(
        Map<String, dynamic> json) =>
    PackageTypeTranslation(
      languageCode: json['language_code'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$PackageTypeTranslationToJson(
        PackageTypeTranslation instance) =>
    <String, dynamic>{
      'language_code': instance.languageCode,
      'title': instance.title,
    };
