// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferTypeModel _$OfferTypeModelFromJson(Map<String, dynamic> json) =>
    OfferTypeModel(
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$OfferTypeModelToJson(OfferTypeModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
    };

OfferTypeResponse _$OfferTypeResponseFromJson(Map<String, dynamic> json) =>
    OfferTypeResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => OfferTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OfferTypeResponseToJson(OfferTypeResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
