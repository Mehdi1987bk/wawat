import 'package:json_annotation/json_annotation.dart';

part 'courier_profile.g.dart';

@JsonSerializable()
class CourierProfile {
  @JsonKey(name: 'experience_years')
  final int experienceYears;

  @JsonKey(name: 'max_weight_kg')
  final int maxWeightKg;

  @JsonKey(name: 'insurance_usd')
  final int insuranceUsd;

  @JsonKey(name: 'price_from')
  final double priceFrom;

  @JsonKey(name: 'price_to')
  final double priceTo;

  @JsonKey(name: 'work_time_from')
  final String workTimeFrom;

  @JsonKey(name: 'work_time_to')
  final String workTimeTo;

  @JsonKey(name: 'languages')
  final List<String> languages;

  @JsonKey(name: 'package_types')
  final List<String> packageTypes;

  CourierProfile({
    required this.experienceYears,
    required this.maxWeightKg,
    required this.insuranceUsd,
    required this.priceFrom,
    required this.priceTo,
    required this.workTimeFrom,
    required this.workTimeTo,
    required this.languages,
    required this.packageTypes,
  });

  @override
  String toString() {
    return 'CreatePostRequest('
        'experienceYears: $experienceYears, '
        'maxWeightKg: $maxWeightKg, '
        'insuranceUsd: $insuranceUsd, '
        'priceFrom: $priceFrom, '
        'priceTo: $priceTo, '
        'workTimeFrom: $workTimeFrom, '
        'workTimeTo: $workTimeTo, '
        'languages: $languages, '
        'packageTypes: $packageTypes'
        ')';
  }

  factory CourierProfile.fromJson(Map<String, dynamic> json) =>
      _$CourierProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CourierProfileToJson(this);
}
