import 'package:json_annotation/json_annotation.dart';

part 'registration_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegistrationRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  @JsonKey(name: 'communication_language_ids')
  final List<int> communicationLanguageIds;
  @JsonKey(name: 'accepted_terms')
  final bool acceptedTerms;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.passwordConfirmation,
    required this.communicationLanguageIds,
    required this.acceptedTerms,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}
