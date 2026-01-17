// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnreadCountResponse _$UnreadCountResponseFromJson(Map<String, dynamic> json) =>
    UnreadCountResponse(
      data: UnreadCountData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnreadCountResponseToJson(
        UnreadCountResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

UnreadCountData _$UnreadCountDataFromJson(Map<String, dynamic> json) =>
    UnreadCountData(
      unreadCount: json['unread_count'] as int,
    );

Map<String, dynamic> _$UnreadCountDataToJson(UnreadCountData instance) =>
    <String, dynamic>{
      'unread_count': instance.unreadCount,
    };
