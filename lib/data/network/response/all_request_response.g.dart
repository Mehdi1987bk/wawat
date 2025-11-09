// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllRequestResponse _$AllRequestResponseFromJson(Map<String, dynamic> json) =>
    AllRequestResponse(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      packageId: json['package_id'] as int,
      frontIdImg: json['front_id_img'] as String,
      backIdImg: json['back_id_img'] as String,
      faceImg: json['face_img'] as String,
      contactFile: json['contact_file'] as String,
      cardNumber: json['card_number'] as String,
      lastPaymentDay: json['last_payment_day'] as String,
      paidAmount: json['paid_amount'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AllRequestResponseToJson(AllRequestResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'package_id': instance.packageId,
      'front_id_img': instance.frontIdImg,
      'back_id_img': instance.backIdImg,
      'face_img': instance.faceImg,
      'contact_file': instance.contactFile,
      'card_number': instance.cardNumber,
      'last_payment_day': instance.lastPaymentDay,
      'paid_amount': instance.paidAmount,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
