// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordRequest _$ChangePasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordRequest(
      currentPassword: json['current_password'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
    );

Map<String, dynamic> _$ChangePasswordRequestToJson(
        ChangePasswordRequest instance) =>
    <String, dynamic>{
      'current_password': instance.currentPassword,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
    };
