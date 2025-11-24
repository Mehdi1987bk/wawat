import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

import 'language.dart';

part 'professional.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 1)
class Professional extends HiveObject {
  @HiveField(0)
  final int? workExperienceYears;

  @HiveField(1)
  final double? maxWeightKg;

  @HiveField(2)
  final double? insuranceAmount;

  @HiveField(3)
  final double? pricePerKgMin;

  @HiveField(4)
  final double? pricePerKgMax;

  @HiveField(5)
  final String? workTimeFrom;

  @HiveField(6)
  final String? workTimeTo;

  @HiveField(7)
  final List<Language> languages;

  @HiveField(8)
  final List<dynamic> packageTypes; // Могу заменить на List<TypeOption>

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
