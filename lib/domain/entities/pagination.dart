import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../data/network/response/listing_response.dart';
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

  @JsonKey(readValue: _currentPageFromJson, name: "current_page")
  final int? currentPage;

  @JsonKey(readValue: _perPageFromJson, name: "per_page")
  final int? perPage;

  @JsonKey(readValue: _totalFromJson)
  final int? total;

  @JsonKey(readValue: _seedFromJson)
  final int? seed;

  @JsonKey(readValue: _suggestionsReadValue, fromJson: _suggestionsFromJson)
  final List<PaginationSuggestion> suggestions;

  Pagination({
    required this.data,
    required this.lastPage,
    this.currentPage,
    this.perPage,
    this.total,
    this.seed,
    this.suggestions = const [],
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

int _lastPageFromJson(Map<dynamic, dynamic> json, String key) {
  final meta = json["meta"];
  if (meta is Map && meta[key] != null) {
    return meta[key] as int;
  }
  return 1;
}

int? _currentPageFromJson(Map<dynamic, dynamic> json, String key) {
  return _metaIntFromJson(json, key);
}

int? _perPageFromJson(Map<dynamic, dynamic> json, String key) {
  return _metaIntFromJson(json, key);
}

int? _totalFromJson(Map<dynamic, dynamic> json, String key) {
  return _metaIntFromJson(json, key);
}

int? _seedFromJson(Map<dynamic, dynamic> json, String key) {
  return _metaIntFromJson(json, key);
}

int? _metaIntFromJson(Map<dynamic, dynamic> json, String key) {
  final meta = json["meta"];
  if (meta is! Map) return null;
  final value = meta[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

Object? _suggestionsReadValue(Map<dynamic, dynamic> json, String key) {
  final meta = json["meta"];
  if (meta is! Map) return null;
  return meta["suggestions"];
}

List<PaginationSuggestion> _suggestionsFromJson(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(PaginationSuggestion.fromJson)
      .toList();
}

@JsonSerializable()
class PaginationSuggestion {
  final String? action;
  final String? label;

  PaginationSuggestion({
    this.action,
    this.label,
  });

  factory PaginationSuggestion.fromJson(Map<String, dynamic> json) =>
      _$PaginationSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationSuggestionToJson(this);
}

class _Converter<T> implements JsonConverter<T, Object> {
  const _Converter();

  @override
  T fromJson(Object json) {
    if (T == OfferModel) {
      return OfferModel.fromJson(json as Map<String, dynamic>) as T;
    }

    if (T == Listing) {
      return Listing.fromJson(json as Map<String, dynamic>) as T;
    }

    throw 'Unknown type. Type $T';
  }

  @override
  Object toJson(T object) {
    return object as Object;
  }
}
