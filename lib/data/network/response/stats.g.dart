// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatsAdapter extends TypeAdapter<Stats> {
  @override
  final int typeId = 99;

  @override
  Stats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Stats(
      offersTotal: fields[0] as int?,
      offersActive: fields[1] as int?,
      ratingAvg: fields[2] as double?,
      ratingCount: fields[3] as int?,
      reviewsReceivedCount: fields[6] as int?,
      deliveriesCount: fields[4] as int?,
      yearsOnPlatform: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Stats obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.offersTotal)
      ..writeByte(1)
      ..write(obj.offersActive)
      ..writeByte(2)
      ..write(obj.ratingAvg)
      ..writeByte(3)
      ..write(obj.ratingCount)
      ..writeByte(4)
      ..write(obj.deliveriesCount)
      ..writeByte(5)
      ..write(obj.yearsOnPlatform)
      ..writeByte(6)
      ..write(obj.reviewsReceivedCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
      offersTotal: (json['offers_total'] as num?)?.toInt(),
      offersActive: (json['offers_active'] as num?)?.toInt(),
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt(),
      reviewsReceivedCount: (json['reviews_received_count'] as num?)?.toInt(),
      deliveriesCount: (json['deliveries_count'] as num?)?.toInt(),
      yearsOnPlatform: (json['years_on_platform'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'offers_total': instance.offersTotal,
      'offers_active': instance.offersActive,
      'rating_avg': instance.ratingAvg,
      'rating_count': instance.ratingCount,
      'deliveries_count': instance.deliveriesCount,
      'years_on_platform': instance.yearsOnPlatform,
      'reviews_received_count': instance.reviewsReceivedCount,
    };
