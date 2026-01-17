import 'package:json_annotation/json_annotation.dart';

part 'privacy_policy_response.g.dart';

@JsonSerializable()
class PrivacyPolicyResponse {
  final String html;

  PrivacyPolicyResponse({
    required this.html,
  });

  factory PrivacyPolicyResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivacyPolicyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacyPolicyResponseToJson(this);
}