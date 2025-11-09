import 'package:json_annotation/json_annotation.dart';

part 'registration_request.g.dart';

@JsonSerializable(fieldRename:  FieldRename.snake)
class RegistrationRequest {
  final String name;
  final String phone;
  final String password;
  final String passwordConfirmation;

  RegistrationRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}
