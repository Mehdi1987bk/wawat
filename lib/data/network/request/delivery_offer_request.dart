import 'package:json_annotation/json_annotation.dart';

part 'delivery_offer_request.g.dart';

@JsonSerializable()
class DeliveryOfferRequest {
  @JsonKey(name: 'offer_type_id')
  final int offerTypeId;

  @JsonKey(name: 'package_type_id')
  final int packageTypeId;

  @JsonKey(name: 'from_city_id')
  final int fromCityId;

  @JsonKey(name: 'to_city_id')
  final int toCityId;

  @JsonKey(name: 'date_from')
  final String dateFrom;

  @JsonKey(name: 'date_to')
  final String dateTo;

  @JsonKey(name: 'time_from')
  final String timeFrom;

  @JsonKey(name: 'max_weight_kg')
  final int maxWeightKg;

  @JsonKey(name: 'price_per_kg')
  final double pricePerKg;

  final String description;

  @JsonKey(name: 'is_active')
  final bool isActive;

  DeliveryOfferRequest({
    required this.offerTypeId,
    required this.packageTypeId,
    required this.fromCityId,
    required this.toCityId,
    required this.dateFrom,
    required this.dateTo,
    required this.timeFrom,
    required this.maxWeightKg,
    required this.pricePerKg,
    required this.description,
    required this.isActive,
  });

  factory DeliveryOfferRequest.fromJson(Map<String, dynamic> json) =>
      _$DeliveryOfferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOfferRequestToJson(this);
}