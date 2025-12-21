import 'package:json_annotation/json_annotation.dart';

part 'verification_response.g.dart';

@JsonSerializable()
class VerificationResponse {
  @JsonKey(name: 'data')
  final VerificationData data;

  VerificationResponse({
    required this.data,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$VerificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationResponseToJson(this);
}

@JsonSerializable()
class VerificationData {
  @JsonKey(name: 'has_verification')
  final bool hasVerification;

  @JsonKey(name: 'is_verified')
  final bool isVerified;

  @JsonKey(name: 'can_submit')
  final bool canSubmit;

  VerificationData({
    required this.hasVerification,
    required this.isVerified,
    required this.canSubmit,
  });

  factory VerificationData.fromJson(Map<String, dynamic> json) =>
      _$VerificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationDataToJson(this);
}