import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notifications.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 4)
class Notifications extends HiveObject {
  @HiveField(0)
  final bool? newMessages;

  @HiveField(1)
  final bool? newReviews;

  @HiveField(2)
  final bool? marketing;

  Notifications({
    required this.newMessages,
    required this.newReviews,
    required this.marketing,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsToJson(this);
}
