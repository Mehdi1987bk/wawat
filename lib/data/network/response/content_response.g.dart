// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentResponse _$ContentResponseFromJson(Map<String, dynamic> json) =>
    ContentResponse(
      data: (json['data'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ContentResponseToJson(ContentResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
