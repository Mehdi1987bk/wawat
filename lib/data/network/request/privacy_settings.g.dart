// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      showPhone: json['show_phone'] as bool,
      showEmail: json['show_email'] as bool,
      showLastSeen: json['show_last_seen'] as bool,
      notifyNewMessages: json['notify_new_messages'] as bool,
      notifyNewReviews: json['notify_new_reviews'] as bool,
      notifyMarketing: json['notify_marketing'] as bool,
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'show_phone': instance.showPhone,
      'show_email': instance.showEmail,
      'show_last_seen': instance.showLastSeen,
      'notify_new_messages': instance.notifyNewMessages,
      'notify_new_reviews': instance.notifyNewReviews,
      'notify_marketing': instance.notifyMarketing,
    };
