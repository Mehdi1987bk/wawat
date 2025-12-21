// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReviewRequest _$CreateReviewRequestFromJson(Map<String, dynamic> json) =>
    CreateReviewRequest(
      reviewRequestId: json['review_request_id'] as int?,
      targetId: json['target_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$CreateReviewRequestToJson(
        CreateReviewRequest instance) =>
    <String, dynamic>{
      'review_request_id': instance.reviewRequestId,
      'target_id': instance.targetId,
      'rating': instance.rating,
      'comment': instance.comment,
    };
