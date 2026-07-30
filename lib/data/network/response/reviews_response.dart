import 'package:json_annotation/json_annotation.dart';

part 'reviews_response.g.dart';

@JsonSerializable()
class ReviewsResponse {
  final List<ReviewModel> data;

  ReviewsResponse({required this.data});

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewsResponseToJson(this);
}

@JsonSerializable()
class ReviewModel {
  final int id;
  final int rating;
  final String? comment;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'offer_id')
  final int? offerId;
  final AuthorModel? author;
  final AuthorModel? target;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'dislikes_count')
  final int dislikesCount;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.isPublic,
    this.offerId,
    this.author,
    this.target,
    required this.likesCount,
    required this.dislikesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}

@JsonSerializable()
class AuthorModel {
  final int id;
  final String fullname;
  final String? avatar;
  @JsonKey(name: 'avatar_thumb_url')
  final String? avatarThumbUrl;
  @JsonKey(name: 'city_name')
  final String? cityName;
  @JsonKey(name: 'country_name')
  final String? countryName;
  final List<LanguageModel> languages;

  AuthorModel({
    required this.id,
    required this.fullname,
    this.avatar,
    this.avatarThumbUrl,
    this.cityName,
    this.countryName,
    required this.languages,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);
}

@JsonSerializable()
class LanguageModel {
  final String code;
  final String name;

  LanguageModel({
    required this.code,
    required this.name,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);
}
