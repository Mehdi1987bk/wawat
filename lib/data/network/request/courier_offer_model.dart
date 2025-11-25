import 'package:json_annotation/json_annotation.dart';

part 'courier_offer_model.g.dart';

@JsonSerializable()
class CourierOfferModel {
  @JsonKey(name: 'offer_type')
  final String offerType;

  @JsonKey(name: 'city_from_id')
  final int cityFromId;

  @JsonKey(name: 'city_to_id')
  final int cityToId;

  @JsonKey(name: 'flight_date')
  final String flightDate;

  @JsonKey(name: 'flight_time')
  final String flightTime;

  @JsonKey(name: 'delivery_date_from')
  final String deliveryDateFrom;

  @JsonKey(name: 'delivery_date_to')
  final String deliveryDateTo;

  @JsonKey(name: 'purchase_date')
  final String purchaseDate;

  @JsonKey(name: 'purchase_time')
  final String purchaseTime;

  @JsonKey(name: 'package_type')
  final String packageType;

  @JsonKey(name: 'max_weight_kg')
  final int maxWeightKg;

  @JsonKey(name: 'price_per_kg')
  final double pricePerKg;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'languages')
  final List<String> languages;

  CourierOfferModel({
    required this.offerType,
    required this.cityFromId,
    required this.cityToId,
    required this.flightDate,
    required this.flightTime,
    required this.deliveryDateFrom,
    required this.deliveryDateTo,
    required this.purchaseDate,
    required this.purchaseTime,
    required this.packageType,
    required this.maxWeightKg,
    required this.pricePerKg,
    required this.description,
    required this.languages,
  });

  factory CourierOfferModel.fromJson(Map<String, dynamic> json) =>
      _$CourierOfferModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourierOfferModelToJson(this);
}