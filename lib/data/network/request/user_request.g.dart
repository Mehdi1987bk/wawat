// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRequest _$UserRequestFromJson(Map<String, dynamic> json) => UserRequest(
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      locationCityId: json['location_city_id'] as int?,
      locationText: json['location_text'] as String?,
      about: json['about'] as String?,
      yearsOfExperienceText: json['years_of_experience_text'] as String?,
    );

Map<String, dynamic> _$UserRequestToJson(UserRequest instance) {
  final val = <String, dynamic>{
    'fullname': instance.fullname,
    'email': instance.email,
    'phone': instance.phone,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('location_city_id', instance.locationCityId);
  writeNotNull('location_text', instance.locationText);
  writeNotNull('about', instance.about);
  writeNotNull('years_of_experience_text', instance.yearsOfExperienceText);
  return val;
}
