import 'package:json_annotation/json_annotation.dart';

part 'registration_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegistrationRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  @JsonKey(name: 'languages')
  final List<String>? languages;
  @JsonKey(name: 'preferred_locale')
  final String? preferredLocale;
  @JsonKey(name: 'terms_accepted')
  final bool termsAccepted;
  @JsonKey(name: 'device_name')
  final String? deviceName;

  @JsonKey(name: 'referral_code', includeIfNull: false)
  final String? referralCode;

  RegistrationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.languages,
    this.preferredLocale,
    required this.termsAccepted,
    this.deviceName,
    this.referralCode,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}
