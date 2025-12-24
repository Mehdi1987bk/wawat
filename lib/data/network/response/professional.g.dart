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
      maxWeightKg: fields[1] as int?,
      insuranceAmount: fields[2] as int?,
      pricePerKgMin: fields[3] as String?,
      pricePerKgMax: fields[4] as String?,
      workTimeFrom: fields[5] as String?,
      workTimeTo: fields[6] as String?,
      languages: (fields[7] as List).cast<Language>(),
      packageTypes: (fields[8] as List).cast<PacketTypeResp>(),
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
      workExperienceYears: json['experience_years'] as int?,
      maxWeightKg: json['max_weight_kg'] as int?,
      insuranceAmount: json['insurance_usd'] as int?,
      pricePerKgMin: json['price_from'] as String?,
      pricePerKgMax: json['price_to'] as String?,
      workTimeFrom: json['work_time_from'] as String?,
      workTimeTo: json['work_time_to'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => Language.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      packageTypes: (json['package_types'] as List<dynamic>?)
              ?.map((e) => PacketTypeResp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProfessionalToJson(Professional instance) =>
    <String, dynamic>{
      'experience_years': instance.workExperienceYears,
      'max_weight_kg': instance.maxWeightKg,
      'insurance_usd': instance.insuranceAmount,
      'price_from': instance.pricePerKgMin,
      'price_to': instance.pricePerKgMax,
      'work_time_from': instance.workTimeFrom,
      'work_time_to': instance.workTimeTo,
      'languages': instance.languages,
      'package_types': instance.packageTypes,
    };
