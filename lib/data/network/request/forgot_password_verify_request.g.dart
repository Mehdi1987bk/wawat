// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_verify_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordVerifyRequest _$ForgotPasswordVerifyRequestFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordVerifyRequest(
      verificationToken: json['verification_token'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$ForgotPasswordVerifyRequestToJson(
        ForgotPasswordVerifyRequest instance) =>
    <String, dynamic>{
      'verification_token': instance.verificationToken,
      'otp': instance.otp,
    };
