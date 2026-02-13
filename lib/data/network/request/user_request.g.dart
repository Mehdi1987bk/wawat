// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRequest _$UserRequestFromJson(Map<String, dynamic> json) => UserRequest(
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      locationCityId: (json['location_city_id'] as num?)?.toInt(),
      locationText: json['location_text'] as String?,
      about: json['about'] as String?,
      yearsOfExperienceText: json['years_of_experience_text'] as String?,
      callingCode: json['calling_code'] as String?,
    );

Map<String, dynamic> _$UserRequestToJson(UserRequest instance) =>
    <String, dynamic>{
      'fullname': instance.fullname,
      'email': instance.email,
      'phone': instance.phone,
      if (instance.locationCityId case final value?) 'location_city_id': value,
      if (instance.locationText case final value?) 'location_text': value,
      if (instance.about case final value?) 'about': value,
      if (instance.yearsOfExperienceText case final value?)
        'years_of_experience_text': value,
      if (instance.callingCode case final value?) 'calling_code': value,
    };
