import 'package:json_annotation/json_annotation.dart';

part 'conversation_response.g.dart';

@JsonSerializable()
class ConversationResponse {
  final int? id;
  final String? message;
  final ConversationData? data;

  ConversationResponse({
    this.id,
    this.message,
    this.data,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

@JsonSerializable()
class ConversationData {
  final int? conversationId;
  final String? status;

  ConversationData({
    this.conversationId,
    this.status,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) =>
      _$ConversationDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDataToJson(this);
}
