import 'package:json_annotation/json_annotation.dart';

import 'login_response.dart';
import 'user.dart';

part 'login_response_data.g.dart';

@JsonSerializable()
class LoginResponseData {
  final LoginResponse data;

  LoginResponseData({required this.data,  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) => _$LoginResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDataToJson(this);
}
