// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordrRequest _$ForgotPasswordrRequestFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordrRequest(
      password: json['password'] as String,
      password_confirmation: json['password_confirmation'] as String,
    );

Map<String, dynamic> _$ForgotPasswordrRequestToJson(
        ForgotPasswordrRequest instance) =>
    <String, dynamic>{
      'password': instance.password,
      'password_confirmation': instance.password_confirmation,
    };
