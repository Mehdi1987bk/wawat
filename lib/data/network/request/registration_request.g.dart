// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationRequest _$RegistrationRequestFromJson(Map<String, dynamic> json) =>
    RegistrationRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      communicationLanguageIds:
          (json['communication_language_ids'] as List<dynamic>)
              .map((e) => e as int)
              .toList(),
      acceptedTerms: json['accepted_terms'] as bool,
    );

Map<String, dynamic> _$RegistrationRequestToJson(
        RegistrationRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'communication_language_ids': instance.communicationLanguageIds,
      'accepted_terms': instance.acceptedTerms,
    };
