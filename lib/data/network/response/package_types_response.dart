import 'package:json_annotation/json_annotation.dart';

part 'package_types_response.g.dart';

@JsonSerializable()
class PackageTypesResponse {
  @JsonKey(name: 'package_types')
  final List<PackageType> packageTypes;

  PackageTypesResponse({required this.packageTypes});

  factory PackageTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$PackageTypesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PackageTypesResponseToJson(this);
}

@JsonSerializable()
class PackageType {
  final int id;
  final String key;
  final String icon;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<PackageTypeTranslation> translations;

  PackageType({
    required this.id,
    required this.key,
    required this.icon,
    required this.isActive,
    required this.translations,
  });

  factory PackageType.fromJson(Map<String, dynamic> json) =>
      _$PackageTypeFromJson(json);

  Map<String, dynamic> toJson() => _$PackageTypeToJson(this);
}

@JsonSerializable()
class PackageTypeTranslation {
  @JsonKey(name: 'language_code')
  final String languageCode;
  final String title;

  PackageTypeTranslation({
    required this.languageCode,
    required this.title,
  });

  factory PackageTypeTranslation.fromJson(Map<String, dynamic> json) =>
      _$PackageTypeTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$PackageTypeTranslationToJson(this);
}