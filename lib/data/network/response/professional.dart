import 'package:buking/data/network/response/packet_type_resp.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

import 'language.dart';
import 'type_option.dart';

part 'professional.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 1)
class Professional extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'experience_years')
  final String? workExperienceYears;

  @HiveField(1)
  final String? maxWeightKg;

  @HiveField(2)
  @JsonKey(name: 'insurance_usd')
  final String? insuranceAmount;

  @HiveField(3)
  @JsonKey(name: 'price_from')
  final String? pricePerKgMin;

  @HiveField(4)
  @JsonKey(name: 'price_to')
  final String? pricePerKgMax;

  @HiveField(5)
  final String? workTimeFrom;

  @HiveField(6)
  final String? workTimeTo;

  @HiveField(7)
  final List<Language> languages;

  @HiveField(8)
  final List<PacketTypeResp> packageTypes;

  Professional({
    this.workExperienceYears,
    this.maxWeightKg,
    this.insuranceAmount,
    this.pricePerKgMin,
    this.pricePerKgMax,
    this.workTimeFrom,
    this.workTimeTo,
    this.languages = const [],
    this.packageTypes = const [],
  });

  factory Professional.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionalToJson(this);
}