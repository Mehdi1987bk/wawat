import 'package:json_annotation/json_annotation.dart';
import 'country.dart';

part 'countries_response.g.dart';

@JsonSerializable()
class CountriesResponse {
  final List<Country> data;
  final String? message;

  CountriesResponse({required this.data, this.message});

  factory CountriesResponse.fromJson(Map<String, dynamic> json) =>
      _$CountriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CountriesResponseToJson(this);
}
