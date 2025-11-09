import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_request.g.dart';

@JsonSerializable()
class ForgotPasswordrRequest {
  final String password;
  final String password_confirmation;

  ForgotPasswordrRequest({required this.password, required this.password_confirmation});

  factory ForgotPasswordrRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordrRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordrRequestToJson(this);
}
