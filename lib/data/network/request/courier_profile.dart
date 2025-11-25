import 'package:json_annotation/json_annotation.dart';

part 'courier_profile.g.dart';

@JsonSerializable()
class CourierProfile {
  @JsonKey(name: 'work_experience_years')
  final int workExperienceYears;

  @JsonKey(name: 'max_weight_kg')
  final int maxWeightKg;

  @JsonKey(name: 'insurance_amount')
  final int insuranceAmount;

  @JsonKey(name: 'price_per_kg_min')
  final double pricePerKgMin;

  @JsonKey(name: 'price_per_kg_max')
  final double pricePerKgMax;

  @JsonKey(name: 'work_time_from')
  final String workTimeFrom;

  @JsonKey(name: 'work_time_to')
  final String workTimeTo;

  @JsonKey(name: 'communication_language_ids')
  final List<String> communicationLanguageIds;

  @JsonKey(name: 'package_type_ids')
  final List<String> packageTypeIds;

  CourierProfile({
    required this.workExperienceYears,
    required this.maxWeightKg,
    required this.insuranceAmount,
    required this.pricePerKgMin,
    required this.pricePerKgMax,
    required this.workTimeFrom,
    required this.workTimeTo,
    required this.communicationLanguageIds,
    required this.packageTypeIds,
  });

  factory CourierProfile.fromJson(Map<String, dynamic> json) =>
      _$CourierProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CourierProfileToJson(this);
}