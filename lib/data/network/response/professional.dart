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
  final String? workExperienceYears; // Изменено на int

  @HiveField(1)
  @JsonKey(name: 'max_weight_kg')
  final int? maxWeightKg; // Изменено на int

  @HiveField(2)
  @JsonKey(name: 'insurance_usd')
  final int? insuranceAmount; // Изменено на int

  @HiveField(3)
  @JsonKey(name: 'price_from')
  final String? pricePerKgMin; // Остается String, т.к. в JSON "43.00"

  @HiveField(4)
  @JsonKey(name: 'price_to')
  final String? pricePerKgMax; // Остается String, т.к. в JSON "43.00"

  @HiveField(5)
  @JsonKey(name: 'work_time_from')
  final String? workTimeFrom;

  @HiveField(6)
  @JsonKey(name: 'work_time_to')
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