// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FcmTokenRequest _$FcmTokenRequestFromJson(Map<String, dynamic> json) =>
    FcmTokenRequest(
      token: json['token'] as String,
      deviceType: json['device_type'] as String?,
    );

Map<String, dynamic> _$FcmTokenRequestToJson(FcmTokenRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
      'device_type': instance.deviceType,
    };
