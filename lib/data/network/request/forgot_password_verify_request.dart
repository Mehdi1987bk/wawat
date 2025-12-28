import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_verify_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ForgotPasswordVerifyRequest {
  final String verificationToken;
  final String otp;

  ForgotPasswordVerifyRequest({
    required this.verificationToken,
    required this.otp,
  });

  factory ForgotPasswordVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordVerifyRequestToJson(this);
}
