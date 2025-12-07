// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationResponse _$VerificationResponseFromJson(
        Map<String, dynamic> json) =>
    VerificationResponse(
      data: VerificationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerificationResponseToJson(
        VerificationResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

VerificationData _$VerificationDataFromJson(Map<String, dynamic> json) =>
    VerificationData(
      hasVerification: json['has_verification'] as bool,
      isVerified: json['is_verified'] as bool,
      canSubmit: json['can_submit'] as bool,
    );

Map<String, dynamic> _$VerificationDataToJson(VerificationData instance) =>
    <String, dynamic>{
      'has_verification': instance.hasVerification,
      'is_verified': instance.isVerified,
      'can_submit': instance.canSubmit,
    };
