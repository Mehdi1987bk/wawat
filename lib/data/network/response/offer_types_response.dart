import 'package:json_annotation/json_annotation.dart';

part 'offer_types_response.g.dart';

@JsonSerializable()
class OfferTypesResponse {
  @JsonKey(name: 'offer_types')
  final List<OfferType> offerTypes;

  OfferTypesResponse({required this.offerTypes});

  factory OfferTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$OfferTypesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OfferTypesResponseToJson(this);
}

@JsonSerializable()
class OfferType {
  final int id;
  final String key;
  final String icon;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<OfferTypeTranslation> translations;

  OfferType({
    required this.id,
    required this.key,
    required this.icon,
    required this.isActive,
    required this.translations,
  });

  factory OfferType.fromJson(Map<String, dynamic> json) =>
      _$OfferTypeFromJson(json);

  Map<String, dynamic> toJson() => _$OfferTypeToJson(this);
}

@JsonSerializable()
class OfferTypeTranslation {
  @JsonKey(name: 'language_code')
  final String languageCode;
  final String title;

  OfferTypeTranslation({
    required this.languageCode,
    required this.title,
  });

  factory OfferTypeTranslation.fromJson(Map<String, dynamic> json) =>
      _$OfferTypeTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$OfferTypeTranslationToJson(this);
}