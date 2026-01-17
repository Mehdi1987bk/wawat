import 'package:json_annotation/json_annotation.dart';

part 'unread_chat_count_response.g.dart';

@JsonSerializable()
class UnreadChatCountResponse {
  final UnreadChatCountData data;

  UnreadChatCountResponse({
    required this.data,
  });

  factory UnreadChatCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadChatCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadChatCountResponseToJson(this);
}

@JsonSerializable()
class UnreadChatCountData {
  @JsonKey(name: 'unread_conversations_count')
  final int unreadCount;

  UnreadChatCountData({
    required this.unreadCount,
  });

  factory UnreadChatCountData.fromJson(Map<String, dynamic> json) =>
      _$UnreadChatCountDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadChatCountDataToJson(this);
}
