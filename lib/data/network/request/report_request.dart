import 'package:json_annotation/json_annotation.dart';

part 'report_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ReportRequest {
  @JsonKey(name: 'target_type')
  final String targetType;

  @JsonKey(name: 'target_id')
  final String targetId;

  @JsonKey(name: 'reason_code')
  final String? reasonCode;

  final String? note;

  ReportRequest({
    required this.targetType,
    required this.targetId,
    this.reasonCode,
    this.note,
  });

  factory ReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReportRequestToJson(this);
}
