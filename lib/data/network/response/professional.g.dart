// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professional.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfessionalAdapter extends TypeAdapter<Professional> {
  @override
  final int typeId = 1;

  @override
  Professional read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Professional(
      workExperienceYears: fields[0] as int?,
      maxWeightKg: fields[1] as double?,
      insuranceAmount: fields[2] as double?,
      pricePerKgMin: fields[3] as double?,
      pricePerKgMax: fields[4] as double?,
      workTimeFrom: fields[5] as String?,
      workTimeTo: fields[6] as String?,
      languages: (fields[7] as List).cast<Language>(),
      packageTypes: (fields[8] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Professional obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.workExperienceYears)
      ..writeByte(1)
      ..write(obj.maxWeightKg)
      ..writeByte(2)
      ..write(obj.insuranceAmount)
      ..writeByte(3)
      ..write(obj.pricePerKgMin)
      ..writeByte(4)
      ..write(obj.pricePerKgMax)
      ..writeByte(5)
      ..write(obj.workTimeFrom)
      ..writeByte(6)
      ..write(obj.workTimeTo)
      ..writeByte(7)
      ..write(obj.languages)
      ..writeByte(8)
      ..write(obj.packageTypes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Professional _$ProfessionalFromJson(Map<String, dynamic> json) => Professional(
      workExperienceYears: json['work_experience_years'] as int?,
      maxWeightKg: (json['max_weight_kg'] as num?)?.toDouble(),
      insuranceAmount: (json['insurance_amount'] as num?)?.toDouble(),
      pricePerKgMin: (json['price_per_kg_min'] as num?)?.toDouble(),
      pricePerKgMax: (json['price_per_kg_max'] as num?)?.toDouble(),
      workTimeFrom: json['work_time_from'] as String?,
      workTimeTo: json['work_time_to'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => Language.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      packageTypes: json['package_types'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$ProfessionalToJson(Professional instance) =>
    <String, dynamic>{
      'work_experience_years': instance.workExperienceYears,
      'max_weight_kg': instance.maxWeightKg,
      'insurance_amount': instance.insuranceAmount,
      'price_per_kg_min': instance.pricePerKgMin,
      'price_per_kg_max': instance.pricePerKgMax,
      'work_time_from': instance.workTimeFrom,
      'work_time_to': instance.workTimeTo,
      'languages': instance.languages,
      'package_types': instance.packageTypes,
    };
