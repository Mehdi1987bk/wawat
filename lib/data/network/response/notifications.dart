import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notifications.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 4)
class Notifications extends HiveObject {
  @HiveField(0)
  final bool? notifyNewMessages;

  @HiveField(1)
  @JsonKey(name: 'notify_reviews')
  final bool? notifyReviews;

  @HiveField(2)
  final bool? notifyMarketing;

  @HiveField(3)
  final bool? notifyPush;

  @HiveField(4)
  final bool? notifyEmail;

  @HiveField(5)
  final bool? notifyShipments;

  @HiveField(6)
  final bool? notifyListings;

  @HiveField(7)
  final bool? notifyFollows;

  @HiveField(8)
  final bool? notifySavedSearch;

  @HiveField(9)
  final String? quietHoursStart;

  @HiveField(10)
  final String? quietHoursEnd;

  bool? get notifyNewReviews => notifyReviews;

  Notifications({
    required this.notifyNewMessages,
    this.notifyReviews,
    required this.notifyMarketing,
    this.notifyPush,
    this.notifyEmail,
    this.notifyShipments,
    this.notifyListings,
    this.notifyFollows,
    this.notifySavedSearch,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsToJson(this);
}
