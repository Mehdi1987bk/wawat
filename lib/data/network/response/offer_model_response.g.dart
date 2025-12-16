// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_model_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferModelResponse _$OfferModelResponseFromJson(Map<String, dynamic> json) =>
    OfferModelResponse(
      active: (json['active'] as List<dynamic>)
          .map((e) =>
              e == null ? null : OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      inactive: (json['inactive'] as List<dynamic>)
          .map((e) =>
              e == null ? null : OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OfferModelResponseToJson(OfferModelResponse instance) =>
    <String, dynamic>{
      'active': instance.active,
      'inactive': instance.inactive,
    };
