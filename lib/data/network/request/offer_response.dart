import 'package:json_annotation/json_annotation.dart';

part 'offer_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OfferResponse {
  final int offerId;

  OfferResponse({
    required this.offerId,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) =>
      _$OfferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OfferResponseToJson(this);
}