import 'package:json_annotation/json_annotation.dart';

part 'privacy_settings.g.dart';

@JsonSerializable()
class PrivacySettings {
  @JsonKey(name: 'show_phone')
  final bool showPhone;

  @JsonKey(name: 'show_email')
  final bool showEmail;

  @JsonKey(name: 'show_last_seen')
  final bool showLastSeen;

  @JsonKey(name: 'notify_new_messages')
  final bool notifyNewMessages;

  @JsonKey(name: 'notify_new_reviews')
  final bool notifyNewReviews;

  @JsonKey(name: 'notify_marketing')
  final bool notifyMarketing;

  PrivacySettings({
    required this.showPhone,
    required this.showEmail,
    required this.showLastSeen,
    required this.notifyNewMessages,
    required this.notifyNewReviews,
    required this.notifyMarketing,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);
}