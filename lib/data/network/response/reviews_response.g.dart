// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewsResponse _$ReviewsResponseFromJson(Map<String, dynamic> json) =>
    ReviewsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReviewsResponseToJson(ReviewsResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
      id: (json['id'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      isPublic: json['is_public'] as bool,
      offerId: (json['offer_id'] as num?)?.toInt(),
      author: json['author'] == null
          ? null
          : AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      target: json['target'] == null
          ? null
          : AuthorModel.fromJson(json['target'] as Map<String, dynamic>),
      likesCount: (json['likes_count'] as num).toInt(),
      dislikesCount: (json['dislikes_count'] as num).toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'is_public': instance.isPublic,
      'offer_id': instance.offerId,
      'author': instance.author,
      'target': instance.target,
      'likes_count': instance.likesCount,
      'dislikes_count': instance.dislikesCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

AuthorModel _$AuthorModelFromJson(Map<String, dynamic> json) => AuthorModel(
      id: (json['id'] as num).toInt(),
      fullname: json['fullname'] as String,
      avatar: json['avatar'] as String?,
      avatarThumbUrl: json['avatar_thumb_url'] as String?,
      cityName: json['city_name'] as String?,
      countryName: json['country_name'] as String?,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuthorModelToJson(AuthorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'avatar': instance.avatar,
      'avatar_thumb_url': instance.avatarThumbUrl,
      'city_name': instance.cityName,
      'country_name': instance.countryName,
      'languages': instance.languages,
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
