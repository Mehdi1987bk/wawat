import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_request_email.g.dart';

@JsonSerializable()
class ForgotPasswordRequestEmail {
  final String email;

  ForgotPasswordRequestEmail({required this.email});

  factory ForgotPasswordRequestEmail.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestEmailFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestEmailToJson(this);
}
