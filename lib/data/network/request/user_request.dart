import 'package:json_annotation/json_annotation.dart';

part 'user_request.g.dart';

@JsonSerializable()
class UserRequest {
  @JsonKey(name: 'fullname')
  final String fullname;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String phone;



  @JsonKey(name: 'location_city_id', includeIfNull: false)
  final int? locationCityId;

  @JsonKey(name: 'location_text', includeIfNull: false)
  final String? locationText;

  @JsonKey(name: 'about', includeIfNull: false)
  final String? about;

  @JsonKey(name: 'years_of_experience_text', includeIfNull: false)
  final String? yearsOfExperienceText;

  UserRequest({
    required this.fullname,
    required this.email,
    required this.phone,
     this.locationCityId,
    this.locationText,
    this.about,
    this.yearsOfExperienceText,
  });

  /// Convert a UserRequest instance to JSON map
  factory UserRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRequestFromJson(json);

  /// Convert a UserRequest instance to JSON
  Map<String, dynamic> toJson() => _$UserRequestToJson(this);

  /// Copy with method for easy modifications
  UserRequest copyWith({
    String? fullname,
    String? email,
    String? phone,
     int? locationCityId,
    String? locationText,
    String? about,
    String? yearsOfExperienceText,
  }) {
    return UserRequest(
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
       locationCityId: locationCityId ?? this.locationCityId,
      locationText: locationText ?? this.locationText,
      about: about ?? this.about,
      yearsOfExperienceText: yearsOfExperienceText ?? this.yearsOfExperienceText,
    );
  }

  @override
  String toString() {
    return 'UserRequest(fullname: $fullname, email: $email, phone: $phone,  locationCityId: $locationCityId, locationText: $locationText, about: $about, yearsOfExperienceText: $yearsOfExperienceText)';
  }
}