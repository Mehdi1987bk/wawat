// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrivacyAdapter extends TypeAdapter<Privacy> {
  @override
  final int typeId = 3;

  @override
  Privacy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Privacy(
      showPhone: fields[0] as bool?,
      showEmail: fields[1] as bool?,
      showActivityTime: fields[2] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Privacy obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.showPhone)
      ..writeByte(1)
      ..write(obj.showEmail)
      ..writeByte(2)
      ..write(obj.showActivityTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Privacy _$PrivacyFromJson(Map<String, dynamic> json) => Privacy(
      showPhone: json['show_phone'] as bool?,
      showEmail: json['show_email'] as bool?,
      showActivityTime: json['show_activity_time'] as bool?,
    );

Map<String, dynamic> _$PrivacyToJson(Privacy instance) => <String, dynamic>{
      'show_phone': instance.showPhone,
      'show_email': instance.showEmail,
      'show_activity_time': instance.showActivityTime,
    };
