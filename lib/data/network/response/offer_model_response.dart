import 'offer_models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'offer_model_response.g.dart';
@JsonSerializable( )
class OfferModelResponse {
  final List<OfferModel?> active;
  final List<OfferModel?> inactive;

  OfferModelResponse({required this.active, required this.inactive});

  factory OfferModelResponse.fromJson(Map<String, dynamic> json) =>
      _$OfferModelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OfferModelResponseToJson(this);
}