import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'package.g.dart';

@JsonSerializable(explicitToJson: true)
class Package {
  final int id;
  @JsonKey(name: "credit_amount")
  final int creditAmount;
  @JsonKey(name: "credit_day")
  final int creditDay;
  final int payment;
  final int status;
  @JsonKey(name: "created_at")
  final DateTime createdAt;
  @JsonKey(name: "updated_at")
  final DateTime updatedAt;

  Package(
      {required this.id,
      required this.creditAmount,
      required this.creditDay,
      required this.payment,
      required this.status,
      required this.createdAt,
      required this.updatedAt});

  factory Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);

  Map<String, dynamic> toJson() => _$PackageToJson(this);
}
