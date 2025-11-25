import 'package:json_annotation/json_annotation.dart';
import 'city.dart';

part 'cities_response.g.dart';

@JsonSerializable()
class CitiesResponse {
  final List<City> data;

  CitiesResponse({
    required this.data,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) =>
      _$CitiesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CitiesResponseToJson(this);
}
