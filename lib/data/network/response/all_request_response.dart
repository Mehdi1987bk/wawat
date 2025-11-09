import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'all_request_response.g.dart';
@JsonSerializable(explicitToJson: true)
class AllRequestResponse {
  final int id;
  @JsonKey(name: "customer_id")
  final int customerId;
  @JsonKey(name: "package_id")
  final int packageId;
  @JsonKey(name: "front_id_img")
  final String frontIdImg;
  @JsonKey(name: "back_id_img")
  final String backIdImg;
  @JsonKey(name: "face_img")
  final String faceImg;
  @JsonKey(name: "contact_file")
  final String contactFile;
  @JsonKey(name: "card_number")
  final String cardNumber;
  @JsonKey(name: "last_payment_day")
  final String lastPaymentDay;
  @JsonKey(name: "paid_amount")
  final int paidAmount;
  final String status;
  @JsonKey(name: "created_at")
  final DateTime createdAt;
  @JsonKey(name: "updated_at")
  final DateTime updatedAt;

  AllRequestResponse(
      {
       required this.id,
   required  this.customerId,
   required  this.packageId,
   required  this.frontIdImg,
   required  this.backIdImg,
   required  this.faceImg,
   required  this.contactFile,
   required  this.cardNumber,
   required  this.lastPaymentDay,
   required  this.paidAmount,
   required  this.status,
   required  this.createdAt,
   required  this.updatedAt});

factory AllRequestResponse.fromJson(Map<String, dynamic> json) => _$AllRequestResponseFromJson(json);

Map<String, dynamic> toJson() => _$AllRequestResponseToJson(this);
}
