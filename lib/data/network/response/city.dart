import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class City {
  final int id;
  final String name;
  @JsonKey(name: 'country_id', readValue: _countryIdFromJson)
  final int countryId;
  @JsonKey(name: 'country_code', readValue: _countryCodeFromJson)
  final String countryCode;
  @JsonKey(name: 'country_name', readValue: _countryNameFromJson)
  final String countryName;

  City({
    required this.id,
    required this.name,
    required this.countryId,
    required this.countryCode,
    required this.countryName,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}

Object? _countryIdFromJson(Map<dynamic, dynamic> json, String key) {
  final flat = json[key];
  if (flat != null) return flat;
  final country = json['country'];
  if (country is Map) return country['id'];
  return 0;
}

Object? _countryCodeFromJson(Map<dynamic, dynamic> json, String key) {
  final flat = json[key];
  if (flat != null) return flat;
  final country = json['country'];
  if (country is Map) return country['code'];
  return '';
}

Object? _countryNameFromJson(Map<dynamic, dynamic> json, String key) {
  final flat = json[key];
  if (flat != null) return flat;
  final country = json['country'];
  if (country is Map) return country['name'];
  return '';
}
