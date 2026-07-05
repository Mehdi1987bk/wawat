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
      lastPage: (_lastPageFromJson(json, 'last_page') as num).toInt(),
      currentPage:
          (_currentPageFromJson(json, 'current_page') as num?)?.toInt(),
      perPage: (_perPageFromJson(json, 'per_page') as num?)?.toInt(),
      total: (_totalFromJson(json, 'total') as num?)?.toInt(),
      seed: (_seedFromJson(json, 'seed') as num?)?.toInt(),
      suggestions: _suggestionsReadValue(json, 'suggestions') == null
          ? const []
          : _suggestionsFromJson(_suggestionsReadValue(json, 'suggestions')),
    );

Map<String, dynamic> _$PaginationToJson<T>(Pagination<T> instance) =>
    <String, dynamic>{
      'data': instance.data.map(_Converter<T>().toJson).toList(),
      'last_page': instance.lastPage,
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'seed': instance.seed,
      'suggestions': instance.suggestions,
    };

PaginationSuggestion _$PaginationSuggestionFromJson(
        Map<String, dynamic> json) =>
    PaginationSuggestion(
      action: json['action'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$PaginationSuggestionToJson(
        PaginationSuggestion instance) =>
    <String, dynamic>{
      'action': instance.action,
      'label': instance.label,
    };
