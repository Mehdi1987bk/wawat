import 'package:json_annotation/json_annotation.dart';

part 'products_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductsResponse {
  final int id;
  final String name;
  final String price;
  final String show;
  final String description;
  final String vip;
  final String active;
  final String createdAt;
  final String updatedAt;

  ProductsResponse({
      required this.id,
      required this.name,
      required this.price,
      required this.show,
      required this.description,
      required this.vip,
      required this.active,
      required this.createdAt,
      required this.updatedAt
  });

   factory ProductsResponse.fromJson(Map<String, dynamic> json) => _$ProductsResponseFromJson(json);
   Map<String, dynamic> toJson() => _$ProductsResponseToJson(this);

}