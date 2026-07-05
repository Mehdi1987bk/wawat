import 'package:json_annotation/json_annotation.dart';

part 'fcm_token_request.g.dart';

@JsonSerializable()
class FcmTokenRequest {
  final String token;
  @JsonKey(name: 'device_type')
  final String? deviceType;

  FcmTokenRequest({
    required this.token,
    this.deviceType,
  });

  factory FcmTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FcmTokenRequestToJson(this);
}
