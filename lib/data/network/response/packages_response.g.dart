// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packages_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackagesResponse _$PackagesResponseFromJson(Map<String, dynamic> json) =>
    PackagesResponse(
      packages: (json['packages'] as List<dynamic>)
          .map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PackagesResponseToJson(PackagesResponse instance) =>
    <String, dynamic>{
      'packages': instance.packages,
    };
