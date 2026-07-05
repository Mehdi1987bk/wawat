import 'package:json_annotation/json_annotation.dart';

part 'delete_listing_request.g.dart';

@JsonSerializable(includeIfNull: false)
class DeleteListingRequest {
  @JsonKey(name: 'reason_code')
  final String reasonCode;

  @JsonKey(name: 'reason_note')
  final String? reasonNote;

  DeleteListingRequest({
    required this.reasonCode,
    this.reasonNote,
  });

  factory DeleteListingRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteListingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteListingRequestToJson(this);
}
