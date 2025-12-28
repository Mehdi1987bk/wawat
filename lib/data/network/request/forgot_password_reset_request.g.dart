// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_reset_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordResetRequest _$ForgotPasswordResetRequestFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordResetRequest(
      verificationToken: json['verification_token'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
    );

Map<String, dynamic> _$ForgotPasswordResetRequestToJson(
        ForgotPasswordResetRequest instance) =>
    <String, dynamic>{
      'verification_token': instance.verificationToken,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
    };
