import 'package:json_annotation/json_annotation.dart';

part 'notification_response.g.dart';

@JsonSerializable()
class NotificationResponse {
  final List<NotificationItem> data;

  NotificationResponse({
     required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

@JsonSerializable()
class NotificationItem {
  final int id;
  final String? type;
  final String? icon;
  final String? title;
  final String? body;
  final NotificationData? data;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  NotificationItem({
    required this.id,
    this.type,
    this.icon,
    this.title,
    this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

@JsonSerializable()
class NotificationData {
  @JsonKey(name: 'requester_id')
  final int? requesterId;
  @JsonKey(name: 'requester_name')
  final String? requesterName;
  @JsonKey(name: 'sender_id')
  final int? senderId;
  @JsonKey(name: 'sender_name')
  final String? senderName;
  @JsonKey(name: 'conversation_id')
  final int? conversationId;

  NotificationData({
    this.requesterId,
    this.requesterName,
    this.senderId,
    this.senderName,
    this.conversationId,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDataToJson(this);
}

