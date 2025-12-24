import 'package:json_annotation/json_annotation.dart';

part 'support_request.g.dart';

@JsonSerializable()
class SupportRequest {
  final String message;

  SupportRequest({
    required this.message,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) =>
      _$SupportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SupportRequestToJson(this);
}
