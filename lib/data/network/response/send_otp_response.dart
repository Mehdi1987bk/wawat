import 'package:json_annotation/json_annotation.dart';
part 'send_otp_response.g.dart';
@JsonSerializable()
class SendOtpResponse{
  final String status;
  final String token;

  SendOtpResponse({required this.status, required this.token});

factory SendOtpResponse.fromJson(Map<String, dynamic> json) => _$SendOtpResponseFromJson(json);

Map<String, dynamic> toJson() => _$SendOtpResponseToJson(this);
}

