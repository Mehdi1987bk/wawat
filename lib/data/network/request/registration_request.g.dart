// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationRequest _$RegistrationRequestFromJson(Map<String, dynamic> json) =>
    RegistrationRequest(
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      acceptedTerms: json['accepted_terms'] as bool,
    );

Map<String, dynamic> _$RegistrationRequestToJson(
        RegistrationRequest instance) =>
    <String, dynamic>{
      'fullname': instance.fullname,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'languages': instance.languages,
      'accepted_terms': instance.acceptedTerms,
    };
