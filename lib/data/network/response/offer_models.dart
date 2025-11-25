import 'package:json_annotation/json_annotation.dart';

part 'offer_models.g.dart';

// ================ Main Response Model ================
@JsonSerializable()
class OfferListResponse {
   final List<OfferModel> data;

  OfferListResponse({
    required this.data,
  });

  factory OfferListResponse.fromJson(Map<String, dynamic> json) =>
      _$OfferListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OfferListResponseToJson(this);
}

// ================ Offer Model ================
@JsonSerializable()
class OfferModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'offer_type')
  final OfferTypeModel offerType;

  @JsonKey(name: 'city_from')
  final CityModel cityFrom;

  @JsonKey(name: 'city_to')
  final CityModel cityTo;

  @JsonKey(name: 'flight_date')
  final String? flightDate;

  @JsonKey(name: 'flight_time')
  final String? flightTime;

  @JsonKey(name: 'delivery_date_from')
  final String? deliveryDateFrom;

  @JsonKey(name: 'delivery_date_to')
  final String? deliveryDateTo;

  @JsonKey(name: 'purchase_date')
  final String? purchaseDate;

  @JsonKey(name: 'purchase_time')
  final String? purchaseTime;

  @JsonKey(name: 'main_date')
  final String mainDate;

  @JsonKey(name: 'main_time')
  final String? mainTime;

  @JsonKey(name: 'package_type')
  final PackageTypeModel packageType;

  @JsonKey(name: 'max_weight_kg')
  final String maxWeightKg;

  @JsonKey(name: 'price_per_kg')
  final String pricePerKg;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'published_at')
  final String publishedAt;

  @JsonKey(name: 'languages')
  final List<LanguageModel> languages;

  @JsonKey(name: 'user')
  final UserModel user;

  @JsonKey(name: 'is_favorited')
  final bool isFavorited;

  OfferModel({
    required this.id,
    required this.offerType,
    required this.cityFrom,
    required this.cityTo,
    this.flightDate,
    this.flightTime,
    this.deliveryDateFrom,
    this.deliveryDateTo,
    this.purchaseDate,
    this.purchaseTime,
    required this.mainDate,
    required this.mainTime,
    required this.packageType,
    required this.maxWeightKg,
    required this.pricePerKg,
    required this.description,
    required this.status,
    required this.publishedAt,
    required this.languages,
    required this.user,
    required this.isFavorited,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) =>
      _$OfferModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfferModelToJson(this);
}

// ================ Offer Type Model ================
@JsonSerializable()
class OfferTypeModel {
  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'title')
  final String title;

  OfferTypeModel({
    required this.code,
    required this.title,
  });

  factory OfferTypeModel.fromJson(Map<String, dynamic> json) =>
      _$OfferTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfferTypeModelToJson(this);
}

// ================ City Model ================
@JsonSerializable()
class CityModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'country')
  final String country;

  CityModel({
    required this.id,
    required this.name,
    required this.country,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CityModelToJson(this);
}

// ================ Package Type Model ================
@JsonSerializable()
class PackageTypeModel {
  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'icon')
  final String icon;

  PackageTypeModel({
    required this.code,
    required this.title,
    required this.icon,
  });

  factory PackageTypeModel.fromJson(Map<String, dynamic> json) =>
      _$PackageTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageTypeModelToJson(this);
}

// ================ Language Model ================
@JsonSerializable()
class LanguageModel {
  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'name')
  final String name;

  LanguageModel({
    required this.code,
    required this.name,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);
}

// ================ User Model ================
@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'fullname')
  final String fullname;

  @JsonKey(name: 'avatar')
  final String? avatar;

  @JsonKey(name: 'is_verified')
  final bool isVerified;

  @JsonKey(name: 'rating_avg')
  final num ratingAvg;

  @JsonKey(name: 'rating_count')
  final int ratingCount;

  UserModel({
    required this.id,
    required this.fullname,
    this.avatar,
    required this.isVerified,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}