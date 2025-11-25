import 'package:json_annotation/json_annotation.dart';

part 'privacy_settings.g.dart';

@JsonSerializable()
class PrivacySettings {
  @JsonKey(name: 'show_phone')
  final bool showPhone;

  @JsonKey(name: 'show_email')
  final bool showEmail;

  @JsonKey(name: 'show_activity_time')
  final bool showLastSeen;

  PrivacySettings({
    required this.showPhone,
    required this.showEmail,
    required this.showLastSeen,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);
}
