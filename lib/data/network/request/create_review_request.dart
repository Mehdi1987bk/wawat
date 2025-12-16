import 'package:json_annotation/json_annotation.dart';

part 'create_review_request.g.dart';

@JsonSerializable()
class CreateReviewRequest {
  @JsonKey(name: 'review_request_id')
  final int? reviewRequestId;

  @JsonKey(name: 'target_id')
  final int targetId;

  final int rating;
  final String comment;


  CreateReviewRequest({
    required this.reviewRequestId,
    required this.targetId,
    required this.rating,
    required this.comment,
   });

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}