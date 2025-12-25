import 'package:json_annotation/json_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'stats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 99) // убедись что typeId уникальный
class Stats extends HiveObject {
  @HiveField(0)
  final int? offersTotal;

  @HiveField(1)
  final int? offersActive;

  @HiveField(2)
  final double? ratingAvg;

  @HiveField(3)
  final int? ratingCount;

  @HiveField(4)
  final int? deliveriesCount;

  @HiveField(5)
  final double? yearsOnPlatform;

  @HiveField(6)
  final int? reviewsReceivedCount;

  Stats({
    this.offersTotal,
    this.offersActive,
    this.ratingAvg,
    this.ratingCount,
    this.reviewsReceivedCount,
    this.deliveriesCount,
    this.yearsOnPlatform,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);

  Map<String, dynamic> toJson() => _$StatsToJson(this);
}
