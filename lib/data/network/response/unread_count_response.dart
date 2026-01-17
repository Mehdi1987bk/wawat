import 'package:json_annotation/json_annotation.dart';

part 'unread_count_response.g.dart';

@JsonSerializable()
class UnreadCountResponse {
  final UnreadCountData data;

  UnreadCountResponse({
    required this.data,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}

@JsonSerializable()
class UnreadCountData {
  @JsonKey(name: 'unread_count')
  final int unreadCount;

  UnreadCountData({
    required this.unreadCount,
  });

  factory UnreadCountData.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountDataToJson(this);
}