import 'package:json_annotation/json_annotation.dart';

part 'offer_type_model.g.dart';

@JsonSerializable()
class OfferTypeModel {
  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'name')
  final String name;

  OfferTypeModel({
    required this.code,
    required this.name,
  });

  factory OfferTypeModel.fromJson(Map<String, dynamic> json) =>
      _$OfferTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfferTypeModelToJson(this);
}

@JsonSerializable()
class OfferTypeResponse {
   final List<OfferTypeModel> data;

  OfferTypeResponse({
    required this.data,
  });

  factory OfferTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$OfferTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OfferTypeResponseToJson(this);
}