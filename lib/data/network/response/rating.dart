import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';
@JsonSerializable()
@HiveType(typeId: 6)
class Rating extends HiveObject {
  @HiveField(0)
  final double? average;

  @HiveField(1)
  final int? count;

  Rating({this.average, this.count});

  factory Rating.fromJson(Map<String, dynamic> json) =>
      _$RatingFromJson(json);

  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
