// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      showPhone: json['show_phone'] as bool,
      showEmail: json['show_email'] as bool,
      showLastSeen: json['show_activity_time'] as bool,
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'show_phone': instance.showPhone,
      'show_email': instance.showEmail,
      'show_activity_time': instance.showLastSeen,
    };
