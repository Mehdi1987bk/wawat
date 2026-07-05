// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_listing_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteListingRequest _$DeleteListingRequestFromJson(
        Map<String, dynamic> json) =>
    DeleteListingRequest(
      reasonCode: json['reason_code'] as String,
      reasonNote: json['reason_note'] as String?,
    );

Map<String, dynamic> _$DeleteListingRequestToJson(
        DeleteListingRequest instance) =>
    <String, dynamic>{
      'reason_code': instance.reasonCode,
      if (instance.reasonNote case final value?) 'reason_note': value,
    };
