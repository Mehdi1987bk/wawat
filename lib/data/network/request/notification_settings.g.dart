// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      notifyNewMessages: json['notify_new_messages'] as bool,
      notifyNewReviews: json['notify_new_reviews'] as bool,
      notifyMarketing: json['notify_marketing'] as bool,
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'notify_new_messages': instance.notifyNewMessages,
      'notify_new_reviews': instance.notifyNewReviews,
      'notify_marketing': instance.notifyMarketing,
    };
