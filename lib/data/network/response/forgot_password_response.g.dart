// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordResponse _$ForgotPasswordResponseFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordResponse(
      data: ForgotPasswordData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ForgotPasswordResponseToJson(
        ForgotPasswordResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
    };

ForgotPasswordData _$ForgotPasswordDataFromJson(Map<String, dynamic> json) =>
    ForgotPasswordData(
      verificationToken: json['verification_token'] as String,
      expiresInSeconds: json['expires_in_seconds'] as int,
    );

Map<String, dynamic> _$ForgotPasswordDataToJson(ForgotPasswordData instance) =>
    <String, dynamic>{
      'verification_token': instance.verificationToken,
      'expires_in_seconds': instance.expiresInSeconds,
    };
