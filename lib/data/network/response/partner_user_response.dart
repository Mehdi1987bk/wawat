import 'package:json_annotation/json_annotation.dart';

import 'offer_model_response.dart';

part 'partner_user_response.g.dart';

@JsonSerializable()
class PartnerUserResponse {
  final Data data;
  final Meta meta;
  final String message;

  PartnerUserResponse({
    required this.data,
    required this.meta,
    required this.message,
  });

  factory PartnerUserResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerUserResponseToJson(this);
}

@JsonSerializable()
class Data {
  final UserResponse user;
  final Profile profile;
  final Professional professional;
  final Stats stats;
  @JsonKey(name: 'reviews_received')
  final List<Review> reviewsReceived;
  @JsonKey(name: 'reviews_left')
  final List<dynamic> reviewsLeft;
  final OfferModelResponse offers;

  Data({
    required this.user,
    required this.profile,
    required this.professional,
    required this.stats,
    required this.reviewsReceived,
    required this.reviewsLeft,
    required this.offers,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class UserResponse {
  final int id;
  final String fullname;
  final String? avatar;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'preferred_locale')
  final String preferredLocale;
  final String? email;
  final String? phone;
  @JsonKey(name: 'last_seen_at')
  final String? lastSeenAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final List<Language> languages;

  UserResponse({
    required this.id,
    required this.fullname,
    this.avatar,
    required this.isVerified,
    required this.preferredLocale,
    this.email,
    this.phone,
    this.createdAt,
    this.lastSeenAt,
    required this.languages,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

@JsonSerializable()
class Language {
  final String code;
  final String name;

  Language({
    required this.code,
    required this.name,
  });

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}

@JsonSerializable()
class Profile {
  @JsonKey(name: 'location_city_id')
  final String? locationCityId;
  @JsonKey(name: 'location_city_name')
  final String? locationCityName;
  @JsonKey(name: 'location_country_name')
  final String? locationCountryName;
  @JsonKey(name: 'location_text')
  final String? locationText;
  final String? about;
  @JsonKey(name: 'years_of_experience_text')
  final String? yearsOfExperienceText;

  Profile({
    this.locationCityId,
    this.locationCityName,
    this.locationCountryName,
    this.locationText,
    this.about,
    this.yearsOfExperienceText,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class Professional {
  @JsonKey(name: 'experience_years')
  final String? experienceYears;
  @JsonKey(name: 'max_weight_kg')
  final String? maxWeightKg;
  @JsonKey(name: 'insurance_usd')
  final String? insuranceUsd;
  @JsonKey(name: 'price_from')
  final String? priceFrom;
  @JsonKey(name: 'price_to')
  final String? priceTo;
  @JsonKey(name: 'work_time_from')
  final String? workTimeFrom;
  @JsonKey(name: 'work_time_to')
  final String? workTimeTo;
  @JsonKey(name: 'response_time_minutes')
  final String? responseTimeMinutes;
  @JsonKey(name: 'on_time_percent')
  final String? onTimePercent;
  final List<Language> languages;
  @JsonKey(name: 'package_types')
  final List<dynamic> packageTypes;

  Professional({
    this.experienceYears,
    this.maxWeightKg,
    this.insuranceUsd,
    this.priceFrom,
    this.priceTo,
    this.workTimeFrom,
    this.workTimeTo,
    this.responseTimeMinutes,
    this.onTimePercent,
    required this.languages,
    required this.packageTypes,
  });

  factory Professional.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionalToJson(this);
}

@JsonSerializable()
class Stats {
  @JsonKey(name: 'offers_total')
  final int offersTotal;
  @JsonKey(name: 'offers_active')
  final int offersActive;
  @JsonKey(name: 'rating_avg')
  final double ratingAvg;
  @JsonKey(name: 'rating_count')
  final int ratingCount;
  @JsonKey(name: 'positive_percent')
  final int positivePercent;
  @JsonKey(name: 'years_on_platform')
  final double yearsOnPlatform;

  Stats({
    required this.offersTotal,
    required this.offersActive,
    required this.ratingAvg,
    required this.ratingCount,
    required this.positivePercent,
    required this.yearsOnPlatform,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);

  Map<String, dynamic> toJson() => _$StatsToJson(this);
}

@JsonSerializable()
class Review {
  final int id;
  final String rating;
  final String comment;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'is_verified_delivery')
  final String? isVerifiedDelivery;
  final ReviewAuthor author;
  final int upvotes;
  final int downvotes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.isPublic,
    this.isVerifiedDelivery,
    required this.author,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

@JsonSerializable()
class ReviewAuthor {
  final int id;
  final String fullname;
  final String? avatar;
  @JsonKey(name: 'city_name')
  final String? cityName;
  @JsonKey(name: 'country_name')
  final String? countryName;
  final List<Language> languages;

  ReviewAuthor({
    required this.id,
    required this.fullname,
    this.avatar,
    this.cityName,
    this.countryName,
    required this.languages,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) =>
      _$ReviewAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewAuthorToJson(this);
}

@JsonSerializable()
class Meta {
  final String locale;

  Meta({
    required this.locale,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
