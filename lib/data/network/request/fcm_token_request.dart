import 'package:json_annotation/json_annotation.dart';

part 'fcm_token_request.g.dart';

@JsonSerializable()
class FcmTokenRequest {
  @JsonKey(name: 'fcm_token')
  final String fcmToken;

  FcmTokenRequest({required this.fcmToken});

  factory FcmTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FcmTokenRequestToJson(this);
}
