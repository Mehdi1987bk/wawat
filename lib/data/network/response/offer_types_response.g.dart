// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferTypesResponse _$OfferTypesResponseFromJson(Map<String, dynamic> json) =>
    OfferTypesResponse(
      offerTypes: (json['offer_types'] as List<dynamic>)
          .map((e) => OfferType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OfferTypesResponseToJson(OfferTypesResponse instance) =>
    <String, dynamic>{
      'offer_types': instance.offerTypes,
    };

OfferType _$OfferTypeFromJson(Map<String, dynamic> json) => OfferType(
      id: json['id'] as int,
      key: json['key'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
      translations: (json['translations'] as List<dynamic>)
          .map((e) => OfferTypeTranslation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OfferTypeToJson(OfferType instance) => <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'icon': instance.icon,
      'is_active': instance.isActive,
      'translations': instance.translations,
    };

OfferTypeTranslation _$OfferTypeTranslationFromJson(
        Map<String, dynamic> json) =>
    OfferTypeTranslation(
      languageCode: json['language_code'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$OfferTypeTranslationToJson(
        OfferTypeTranslation instance) =>
    <String, dynamic>{
      'language_code': instance.languageCode,
      'title': instance.title,
    };
