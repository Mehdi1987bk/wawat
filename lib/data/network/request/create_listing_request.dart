import 'package:json_annotation/json_annotation.dart';

part 'create_listing_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CreateListingRequest {
  final String type;

  @JsonKey(name: 'city_from_id')
  final int cityFromId;

  @JsonKey(name: 'city_to_id')
  final int cityToId;

  @JsonKey(name: 'package_type_codes')
  final List<String> packageTypeCodes;

  final String? description;

  @JsonKey(name: 'allow_price_negotiation')
  final bool? allowPriceNegotiation;

  @JsonKey(name: 'flight_date')
  final String? flightDate;

  @JsonKey(name: 'flight_time')
  final String? flightTime;

  @JsonKey(name: 'flight_number')
  final String? flightNumber;

  @JsonKey(name: 'max_weight_kg')
  final double? maxWeightKg;

  @JsonKey(name: 'price_per_kg')
  final double? pricePerKg;

  @JsonKey(name: 'delivery_date_from')
  final String? deliveryDateFrom;

  @JsonKey(name: 'delivery_date_to')
  final String? deliveryDateTo;

  @JsonKey(name: 'weight_kg')
  final double? weightKg;

  CreateListingRequest({
    required this.type,
    required this.cityFromId,
    required this.cityToId,
    required this.packageTypeCodes,
    this.description,
    this.allowPriceNegotiation,
    this.flightDate,
    this.flightTime,
    this.flightNumber,
    this.maxWeightKg,
    this.pricePerKg,
    this.deliveryDateFrom,
    this.deliveryDateTo,
    this.weightKg,
  });

  factory CreateListingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateListingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateListingRequestToJson(this);
}
