// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportRequest _$ReportRequestFromJson(Map<String, dynamic> json) =>
    ReportRequest(
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      reasonCode: json['reason_code'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ReportRequestToJson(ReportRequest instance) =>
    <String, dynamic>{
      'target_type': instance.targetType,
      'target_id': instance.targetId,
      if (instance.reasonCode case final value?) 'reason_code': value,
      if (instance.note case final value?) 'note': value,
    };
