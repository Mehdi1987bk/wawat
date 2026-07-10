// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_proposal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingProposalRequest _$ListingProposalRequestFromJson(
        Map<String, dynamic> json) =>
    ListingProposalRequest(
      packageTypeCode: json['package_type_code'] as String,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      priceTotal: (json['price_total'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ListingProposalRequestToJson(
        ListingProposalRequest instance) =>
    <String, dynamic>{
      'package_type_code': instance.packageTypeCode,
      if (instance.weightKg case final value?) 'weight_kg': value,
      if (instance.priceTotal case final value?) 'price_total': value,
      if (instance.note case final value?) 'note': value,
    };
