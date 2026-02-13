// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationResponseToJson(
        NotificationResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String?,
      icon: json['icon'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] == null
          ? null
          : NotificationData.fromJson(json['data'] as Map<String, dynamic>),
      isRead: json['is_read'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'icon': instance.icon,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
    };

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    NotificationData(
      requesterId: (json['requester_id'] as num?)?.toInt(),
      requesterName: json['requester_name'] as String?,
      senderId: (json['sender_id'] as num?)?.toInt(),
      senderName: json['sender_name'] as String?,
      conversationId: (json['conversation_id'] as num?)?.toInt(),
      reviewRequestId: (json['review_request_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NotificationDataToJson(NotificationData instance) =>
    <String, dynamic>{
      'requester_id': instance.requesterId,
      'requester_name': instance.requesterName,
      'sender_id': instance.senderId,
      'sender_name': instance.senderName,
      'conversation_id': instance.conversationId,
      'review_request_id': instance.reviewRequestId,
    };
