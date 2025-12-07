// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerUserResponse _$PartnerUserResponseFromJson(Map<String, dynamic> json) =>
    PartnerUserResponse(
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      message: json['message'] as String,
    );

Map<String, dynamic> _$PartnerUserResponseToJson(
        PartnerUserResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
      'message': instance.message,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      professional:
          Professional.fromJson(json['professional'] as Map<String, dynamic>),
      stats: Stats.fromJson(json['stats'] as Map<String, dynamic>),
      reviewsReceived: (json['reviews_received'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviewsLeft: json['reviews_left'] as List<dynamic>,
      offers:
          OfferModelResponse.fromJson(json['offers'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'user': instance.user,
      'profile': instance.profile,
      'professional': instance.professional,
      'stats': instance.stats,
      'reviews_received': instance.reviewsReceived,
      'reviews_left': instance.reviewsLeft,
      'offers': instance.offers,
    };

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      avatar: json['avatar'] as String?,
      isVerified: json['is_verified'] as bool,
      preferredLocale: json['preferred_locale'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] as String?,
      lastSeenAt: json['last_seen_at'] as String?,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'avatar': instance.avatar,
      'is_verified': instance.isVerified,
      'preferred_locale': instance.preferredLocale,
      'email': instance.email,
      'phone': instance.phone,
      'last_seen_at': instance.lastSeenAt,
      'created_at': instance.createdAt,
      'languages': instance.languages,
    };

Language _$LanguageFromJson(Map<String, dynamic> json) => Language(
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
    };

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      locationCityId: json['location_city_id'] as String?,
      locationCityName: json['location_city_name'] as String?,
      locationCountryName: json['location_country_name'] as String?,
      locationText: json['location_text'] as String?,
      about: json['about'] as String?,
      yearsOfExperienceText: json['years_of_experience_text'] as String?,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'location_city_id': instance.locationCityId,
      'location_city_name': instance.locationCityName,
      'location_country_name': instance.locationCountryName,
      'location_text': instance.locationText,
      'about': instance.about,
      'years_of_experience_text': instance.yearsOfExperienceText,
    };

Professional _$ProfessionalFromJson(Map<String, dynamic> json) => Professional(
      experienceYears: json['experience_years'] as String?,
      maxWeightKg: json['max_weight_kg'] as String?,
      insuranceUsd: json['insurance_usd'] as String?,
      priceFrom: json['price_from'] as String?,
      priceTo: json['price_to'] as String?,
      workTimeFrom: json['work_time_from'] as String?,
      workTimeTo: json['work_time_to'] as String?,
      responseTimeMinutes: json['response_time_minutes'] as String?,
      onTimePercent: json['on_time_percent'] as String?,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
      packageTypes: json['package_types'] as List<dynamic>,
    );

Map<String, dynamic> _$ProfessionalToJson(Professional instance) =>
    <String, dynamic>{
      'experience_years': instance.experienceYears,
      'max_weight_kg': instance.maxWeightKg,
      'insurance_usd': instance.insuranceUsd,
      'price_from': instance.priceFrom,
      'price_to': instance.priceTo,
      'work_time_from': instance.workTimeFrom,
      'work_time_to': instance.workTimeTo,
      'response_time_minutes': instance.responseTimeMinutes,
      'on_time_percent': instance.onTimePercent,
      'languages': instance.languages,
      'package_types': instance.packageTypes,
    };

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
      offersTotal: json['offers_total'] as int,
      offersActive: json['offers_active'] as int,
      ratingAvg: (json['rating_avg'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
      positivePercent: json['positive_percent'] as int,
      yearsOnPlatform: (json['years_on_platform'] as num).toDouble(),
    );

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'offers_total': instance.offersTotal,
      'offers_active': instance.offersActive,
      'rating_avg': instance.ratingAvg,
      'rating_count': instance.ratingCount,
      'positive_percent': instance.positivePercent,
      'years_on_platform': instance.yearsOnPlatform,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: json['id'] as int,
      rating: json['rating'] as String,
      comment: json['comment'] as String,
      isPublic: json['is_public'] as bool,
      isVerifiedDelivery: json['is_verified_delivery'] as String?,
      author: ReviewAuthor.fromJson(json['author'] as Map<String, dynamic>),
      upvotes: json['upvotes'] as int,
      downvotes: json['downvotes'] as int,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'is_public': instance.isPublic,
      'is_verified_delivery': instance.isVerifiedDelivery,
      'author': instance.author,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ReviewAuthor _$ReviewAuthorFromJson(Map<String, dynamic> json) => ReviewAuthor(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      avatar: json['avatar'] as String?,
      cityName: json['city_name'] as String?,
      countryName: json['country_name'] as String?,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReviewAuthorToJson(ReviewAuthor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'avatar': instance.avatar,
      'city_name': instance.cityName,
      'country_name': instance.countryName,
      'languages': instance.languages,
    };

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
      locale: json['locale'] as String,
    );

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
      'locale': instance.locale,
    };
