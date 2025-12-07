import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'conversation_response.g.dart';

@JsonSerializable()
class ConversationResponse {
  final ConversationData? data;
  final Meta? meta;
  final String? message;

  ConversationResponse({
    this.data,
    this.meta,
    this.message,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

@JsonSerializable()
class ConversationData {
  final int? id;
  final User? user;
  @JsonKey(name: 'is_pinned')
  final bool? isPinned;
  @JsonKey(name: 'is_archived')
  final bool? isArchived;

  ConversationData({
    this.id,
    this.user,
    this.isPinned,
    this.isArchived,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) =>
      _$ConversationDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDataToJson(this);
}

@JsonSerializable()
class Meta {
  final String? locale;

  Meta({
    this.locale,
  });

  factory Meta.fromJson(Map<String, dynamic> json) =>
      _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
