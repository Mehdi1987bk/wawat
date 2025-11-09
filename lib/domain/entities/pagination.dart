import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';



part 'pagination.g.dart';

Pagination paginationFromJson(String str) =>
    Pagination.fromJson(json.decode(str));

String paginationToJson(Pagination data) => json.encode(data.toJson());

@JsonSerializable(fieldRename: FieldRename.snake)
class Pagination<T> {
  final int currentPage;
  @_Converter()
  final List<T> data;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  Pagination({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

class _Converter<T> implements JsonConverter<T, Object> {
  const _Converter();

  @override
  T fromJson(Object json) {
    // if (T == Declaration) {
    //   return Declaration.fromJson(json as Map<String, dynamic>) as T;
    // }

    throw 'Unknown type. Type $T';
  }

  @override
  Object toJson(T object) {
    return object as Object;
  }
}
