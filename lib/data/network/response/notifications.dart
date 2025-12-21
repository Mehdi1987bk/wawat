import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notifications.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 4)
class Notifications extends HiveObject {
  @HiveField(0)
  final bool? notifyNewMessages;

  @HiveField(1)
  final bool? notifyNewReviews;

  @HiveField(2)
  final bool? notifyMarketing;

  Notifications({
    required this.notifyNewMessages,
    required this.notifyNewReviews,
    required this.notifyMarketing,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsToJson(this);
}

