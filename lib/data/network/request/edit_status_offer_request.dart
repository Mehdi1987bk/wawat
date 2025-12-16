import 'package:json_annotation/json_annotation.dart';

part 'edit_status_offer_request.g.dart';

@JsonSerializable()
class EditStatusOfferRequest {
  final String status;

  EditStatusOfferRequest(this.status);

  factory EditStatusOfferRequest.fromJson(Map<String, dynamic> json) =>
      _$EditStatusOfferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EditStatusOfferRequestToJson(this);
}
