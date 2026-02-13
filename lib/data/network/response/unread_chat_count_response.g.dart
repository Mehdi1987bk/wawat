// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_chat_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnreadChatCountResponse _$UnreadChatCountResponseFromJson(
        Map<String, dynamic> json) =>
    UnreadChatCountResponse(
      data: UnreadChatCountData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnreadChatCountResponseToJson(
        UnreadChatCountResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

UnreadChatCountData _$UnreadChatCountDataFromJson(Map<String, dynamic> json) =>
    UnreadChatCountData(
      unreadCount: (json['unread_conversations_count'] as num).toInt(),
    );

Map<String, dynamic> _$UnreadChatCountDataToJson(
        UnreadChatCountData instance) =>
    <String, dynamic>{
      'unread_conversations_count': instance.unreadCount,
    };
