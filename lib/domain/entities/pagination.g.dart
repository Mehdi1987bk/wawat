// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination<T> _$PaginationFromJson<T>(Map<String, dynamic> json) =>
    Pagination<T>(
      data: (json['data'] as List<dynamic>)
          .map((e) => _Converter<T>().fromJson(e as Object))
          .toList(),
      lastPage: _lastPageFromJson(json, 'last_page') as int,
    );

Map<String, dynamic> _$PaginationToJson<T>(Pagination<T> instance) =>
    <String, dynamic>{
      'data': instance.data.map(_Converter<T>().toJson).toList(),
      'last_page': instance.lastPage,
    };
