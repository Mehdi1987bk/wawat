import 'package:json_annotation/json_annotation.dart';

part 'listing_proposal_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ListingProposalRequest {
  @JsonKey(name: 'package_type_code')
  final String packageTypeCode;

  @JsonKey(name: 'weight_kg')
  final double? weightKg;

  @JsonKey(name: 'price_total')
  final double? priceTotal;

  final String? note;

  ListingProposalRequest({
    required this.packageTypeCode,
    this.weightKg,
    this.priceTotal,
    this.note,
  });

  factory ListingProposalRequest.fromJson(Map<String, dynamic> json) =>
      _$ListingProposalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ListingProposalRequestToJson(this);
}
