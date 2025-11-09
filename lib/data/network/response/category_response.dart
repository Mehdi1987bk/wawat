import 'package:json_annotation/json_annotation.dart';

part 'category_response.g.dart';
@JsonSerializable(explicitToJson: true)
class CategoryResponse {
  final int id;
  final String name;

  CategoryResponse({required this.id, required this.name});

 factory CategoryResponse.fromJson(Map<String, dynamic> json) => _$CategoryResponseFromJson(json);
 Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}


