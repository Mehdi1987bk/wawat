import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_reset_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ForgotPasswordResetRequest {
  final String verificationToken;
  final String password;
  final String passwordConfirmation;

  ForgotPasswordResetRequest({
    required this.verificationToken,
    required this.password,
    required this.passwordConfirmation,
  });

  factory ForgotPasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResetRequestToJson(this);
}
