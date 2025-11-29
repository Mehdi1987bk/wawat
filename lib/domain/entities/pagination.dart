import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../data/network/response/offer_models.dart';


part 'pagination.g.dart';

Pagination paginationFromJson(String str) =>
    Pagination.fromJson(json.decode(str));

String paginationToJson(Pagination data) => json.encode(data.toJson());

@JsonSerializable(fieldRename: FieldRename.snake)
class Pagination<T> {
  @_Converter()
  final List<T> data;
  @JsonKey(readValue: _lastPageFromJson, name: "last_page")
  final int lastPage;

  Pagination({
    required this.data,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

int _lastPageFromJson(Map<dynamic, dynamic> json, String key) {
  return json["meta"][key];
}

class _Converter<T> implements JsonConverter<T, Object> {
  const _Converter();

  @override
  T fromJson(Object json) {
    if (T == OfferModel) {
      return OfferModel.fromJson(json as Map<String, dynamic>) as T;
    }


    throw 'Unknown type. Type $T';
  }

  @override
  Object toJson(T object) {
    return object as Object;
  }
}
