import 'package:json_annotation/json_annotation.dart';

part 'registration_request.g.dart';

@JsonSerializable(fieldRename:  FieldRename.snake)
class RegistrationRequest {
  final String name;
  final String email;
  final String password;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
   });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}
