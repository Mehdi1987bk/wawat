import 'package:json_annotation/json_annotation.dart';

part 'package_types_response.g.dart';

@JsonSerializable()
class PackageTypesResponse {
   final List<PackageType> data;

  PackageTypesResponse({required this.data});

  factory PackageTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$PackageTypesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PackageTypesResponseToJson(this);
}

@JsonSerializable()
class PackageType {
  final String code;
  final String name;
  final String icon;


  PackageType({
    required this.code,
    required this.name,
    required this.icon,

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