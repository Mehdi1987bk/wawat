import 'package:json_annotation/json_annotation.dart';

import 'package.dart';
part 'packages_response.g.dart';
@JsonSerializable()
class PackagesResponse{
  final List<Package> packages;

  PackagesResponse({required this.packages});

factory PackagesResponse.fromJson(Map<String, dynamic> json) => _$PackagesResponseFromJson(json);

Map<String, dynamic> toJson() => _$PackagesResponseToJson(this);
}