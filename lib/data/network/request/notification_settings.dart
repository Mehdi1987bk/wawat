import 'package:json_annotation/json_annotation.dart';

part 'notification_settings.g.dart';

@JsonSerializable()
class NotificationSettings {
  @JsonKey(name: 'notify_new_messages')
  final bool notifyNewMessages;

  @JsonKey(name: 'notify_new_reviews')
  final bool notifyNewReviews;

  @JsonKey(name: 'notify_marketing')
  final bool notifyMarketing;

  NotificationSettings({

    required this.notifyNewMessages,
    required this.notifyNewReviews,
    required this.notifyMarketing,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);
}