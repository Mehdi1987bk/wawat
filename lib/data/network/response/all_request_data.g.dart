// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_request_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllrequestData _$AllrequestDataFromJson(Map<String, dynamic> json) =>
    AllrequestData(
      data: (json['data'] as List<dynamic>)
          .map((e) => AllRequestResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AllrequestDataToJson(AllrequestData instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
