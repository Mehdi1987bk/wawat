// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationRequest _$RegistrationRequestFromJson(Map<String, dynamic> json) =>
    RegistrationRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredLocale: json['preferred_locale'] as String?,
      termsAccepted: json['terms_accepted'] as bool,
      deviceName: json['device_name'] as String?,
      referralCode: json['referral_code'] as String?,
    );

Map<String, dynamic> _$RegistrationRequestToJson(RegistrationRequest instance) {
  final val = <String, dynamic>{
    'first_name': instance.firstName,
    'last_name': instance.lastName,
    'email': instance.email,
    'password': instance.password,
    'password_confirmation': instance.passwordConfirmation,
    'languages': instance.languages,
    'preferred_locale': instance.preferredLocale,
    'terms_accepted': instance.termsAccepted,
    'device_name': instance.deviceName,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('referral_code', instance.referralCode);
  return val;
}
