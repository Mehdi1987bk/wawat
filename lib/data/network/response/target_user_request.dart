import 'package:json_annotation/json_annotation.dart';

part 'target_user_request.g.dart';

@JsonSerializable()
class TargetUserRequest {
  @JsonKey(name: 'target_user_id')
  final int targetUserId;

  TargetUserRequest({
    required this.targetUserId,
  });

  factory TargetUserRequest.fromJson(Map<String, dynamic> json) =>
      _$TargetUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TargetUserRequestToJson(this);
}