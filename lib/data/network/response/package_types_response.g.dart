// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageTypesResponse _$PackageTypesResponseFromJson(
        Map<String, dynamic> json) =>
    PackageTypesResponse(
      packageTypes: (json['package_types'] as List<dynamic>)
          .map((e) => PackageType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PackageTypesResponseToJson(
        PackageTypesResponse instance) =>
    <String, dynamic>{
      'package_types': instance.packageTypes,
    };

PackageType _$PackageTypeFromJson(Map<String, dynamic> json) => PackageType(
      id: json['id'] as int,
      key: json['key'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
      translations: (json['translations'] as List<dynamic>)
          .map(
              (e) => PackageTypeTranslation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PackageTypeToJson(PackageType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'icon': instance.icon,
      'is_active': instance.isActive,
      'translations': instance.translations,
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
