import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ForgotPasswordResponse {
  final ForgotPasswordData data;
  final String? message;

  ForgotPasswordResponse({required this.data, this.message});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ForgotPasswordData {
  final String? verificationToken;
  final int expiresInSeconds;

  ForgotPasswordData({
    required this.verificationToken,
    required this.expiresInSeconds,
  });

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordDataFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordDataToJson(this);
}
