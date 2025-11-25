// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferListResponse _$OfferListResponseFromJson(Map<String, dynamic> json) =>
    OfferListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OfferListResponseToJson(OfferListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

OfferModel _$OfferModelFromJson(Map<String, dynamic> json) => OfferModel(
      id: json['id'] as int,
      offerType:
          OfferTypeModel.fromJson(json['offer_type'] as Map<String, dynamic>),
      cityFrom: CityModel.fromJson(json['city_from'] as Map<String, dynamic>),
      cityTo: CityModel.fromJson(json['city_to'] as Map<String, dynamic>),
      flightDate: json['flight_date'] as String?,
      flightTime: json['flight_time'] as String?,
      deliveryDateFrom: json['delivery_date_from'] as String?,
      deliveryDateTo: json['delivery_date_to'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      purchaseTime: json['purchase_time'] as String?,
      mainDate: json['main_date'] as String,
      mainTime: json['main_time'] as String?,
      packageType: PackageTypeModel.fromJson(
          json['package_type'] as Map<String, dynamic>),
      maxWeightKg: json['max_weight_kg'] as String,
      pricePerKg: json['price_per_kg'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      publishedAt: json['published_at'] as String,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      isFavorited: json['is_favorited'] as bool,
    );

Map<String, dynamic> _$OfferModelToJson(OfferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offer_type': instance.offerType,
      'city_from': instance.cityFrom,
      'city_to': instance.cityTo,
      'flight_date': instance.flightDate,
      'flight_time': instance.flightTime,
      'delivery_date_from': instance.deliveryDateFrom,
      'delivery_date_to': instance.deliveryDateTo,
      'purchase_date': instance.purchaseDate,
      'purchase_time': instance.purchaseTime,
      'main_date': instance.mainDate,
      'main_time': instance.mainTime,
      'package_type': instance.packageType,
      'max_weight_kg': instance.maxWeightKg,
      'price_per_kg': instance.pricePerKg,
      'description': instance.description,
      'status': instance.status,
      'published_at': instance.publishedAt,
      'languages': instance.languages,
      'user': instance.user,
      'is_favorited': instance.isFavorited,
    };

OfferTypeModel _$OfferTypeModelFromJson(Map<String, dynamic> json) =>
    OfferTypeModel(
      code: json['code'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$OfferTypeModelToJson(OfferTypeModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
    };

CityModel _$CityModelFromJson(Map<String, dynamic> json) => CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
    );

Map<String, dynamic> _$CityModelToJson(CityModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
    };

PackageTypeModel _$PackageTypeModelFromJson(Map<String, dynamic> json) =>
    PackageTypeModel(
      code: json['code'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$PackageTypeModelToJson(PackageTypeModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'icon': instance.icon,
    };

LanguageModel _$LanguageModelFromJson(Map<String, dynamic> json) =>
    LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$LanguageModelToJson(LanguageModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      avatar: json['avatar'] as String?,
      isVerified: json['is_verified'] as bool,
      ratingAvg: json['rating_avg'] as num,
      ratingCount: json['rating_count'] as int,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'avatar': instance.avatar,
      'is_verified': instance.isVerified,
      'rating_avg': instance.ratingAvg,
      'rating_count': instance.ratingCount,
    };
