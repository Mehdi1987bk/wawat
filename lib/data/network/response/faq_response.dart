import 'package:json_annotation/json_annotation.dart';

part 'faq_response.g.dart';

@JsonSerializable()
class FaqResponse {
  final bool success;
  final String message;
  final List<FaqItem> data;

  FaqResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) =>
      _$FaqResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FaqResponseToJson(this);
}

@JsonSerializable()
class FaqItem {
  final int id;
  final String question;
  final String answer;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) =>
      _$FaqItemFromJson(json);

  Map<String, dynamic> toJson() => _$FaqItemToJson(this);
}