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

  /// Number of ARCHIVED conversations that have unread messages — counted per
  /// chat, not per message. Shown as a badge on the Archive entry.
  @JsonKey(name: 'archived_unread_count', defaultValue: 0)
  final int archivedUnreadCount;

  UnreadChatCountData({
    required this.unreadCount,
    this.archivedUnreadCount = 0,
  });

  factory UnreadChatCountData.fromJson(Map<String, dynamic> json) =>
      _$UnreadChatCountDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadChatCountDataToJson(this);
}
