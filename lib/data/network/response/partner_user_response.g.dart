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
      settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
      reviewsReceived: (json['reviews_received'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviewsLeft: json['reviews_left'] as List<dynamic>,
      offers: Offers.fromJson(json['offers'] as Map<String, dynamic>),
      favorites: json['favorites'] as List<dynamic>,
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'user': instance.user,
      'profile': instance.profile,
      'professional': instance.professional,
      'stats': instance.stats,
      'settings': instance.settings,
      'reviews_received': instance.reviewsReceived,
      'reviews_left': instance.reviewsLeft,
      'offers': instance.offers,
      'favorites': instance.favorites,
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
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
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
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
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
      locationCityId: json['location_city_id'] as int?,
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
      maxWeightKg: json['max_weight_kg'] as int?,
      insuranceUsd: json['insurance_usd'] as int?,
      priceFrom: json['price_from'] as String?,
      priceTo: json['price_to'] as String?,
      workTimeFrom: json['work_time_from'] as String?,
      workTimeTo: json['work_time_to'] as String?,
      responseTimeMinutes: json['response_time_minutes'] as String?,
      onTimePercent: json['on_time_percent'] as String?,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
      packageTypes: (json['package_types'] as List<dynamic>)
          .map((e) => PackageType.fromJson(e as Map<String, dynamic>))
          .toList(),
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

PackageType _$PackageTypeFromJson(Map<String, dynamic> json) => PackageType(
      code: json['code'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$PackageTypeToJson(PackageType instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'icon': instance.icon,
    };

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
      offersTotal: json['offers_total'] as int,
      offersActive: json['offers_active'] as int,
      ratingAvg: (json['rating_avg'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
      reviewsReceivedCount: json['reviews_received_count'] as int,
      positivePercent: (json['positive_percent'] as num).toDouble(),
      yearsOnPlatform: json['years_on_platform'] as int,
    );

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'offers_total': instance.offersTotal,
      'offers_active': instance.offersActive,
      'rating_avg': instance.ratingAvg,
      'rating_count': instance.ratingCount,
      'reviews_received_count': instance.reviewsReceivedCount,
      'positive_percent': instance.positivePercent,
      'years_on_platform': instance.yearsOnPlatform,
    };

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      privacy: Privacy.fromJson(json['privacy'] as Map<String, dynamic>),
      notificationSettings: NotificationSettingsaa.fromJson(
          json['notificationSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'privacy': instance.privacy,
      'notificationSettings': instance.notificationSettings,
    };

Privacy _$PrivacyFromJson(Map<String, dynamic> json) => Privacy(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      showPhone: json['show_phone'] as bool,
      showEmail: json['show_email'] as bool,
      showActivityTime: json['show_activity_time'] as bool,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$PrivacyToJson(Privacy instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'show_phone': instance.showPhone,
      'show_email': instance.showEmail,
      'show_activity_time': instance.showActivityTime,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

NotificationSettingsaa _$NotificationSettingsaaFromJson(
        Map<String, dynamic> json) =>
    NotificationSettingsaa(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      notifyNewMessages: json['notify_new_messages'] as bool,
      notifyNewReviews: json['notify_new_reviews'] as bool,
      notifyMarketing: json['notify_marketing'] as bool,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$NotificationSettingsaaToJson(
        NotificationSettingsaa instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'notify_new_messages': instance.notifyNewMessages,
      'notify_new_reviews': instance.notifyNewReviews,
      'notify_marketing': instance.notifyMarketing,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

Offers _$OffersFromJson(Map<String, dynamic> json) => Offers(
      active: (json['active'] as List<dynamic>)
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      inactive: (json['inactive'] as List<dynamic>)
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OffersToJson(Offers instance) => <String, dynamic>{
      'active': instance.active,
      'inactive': instance.inactive,
    };

OfferType _$OfferTypeFromJson(Map<String, dynamic> json) => OfferType(
      code: json['code'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$OfferTypeToJson(OfferType instance) => <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
    };

City _$CityFromJson(Map<String, dynamic> json) => City(
      id: json['id'] as int,
      name: json['name'] as String,
      country: json['country'] as String,
    );

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
    };

OfferUser _$OfferUserFromJson(Map<String, dynamic> json) => OfferUser(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      avatar: json['avatar'] as String?,
      isVerified: json['is_verified'] as bool,
      ratingAvg: (json['rating_avg'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
    );

Map<String, dynamic> _$OfferUserToJson(OfferUser instance) => <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'avatar': instance.avatar,
      'is_verified': instance.isVerified,
      'rating_avg': instance.ratingAvg,
      'rating_count': instance.ratingCount,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: json['id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
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
