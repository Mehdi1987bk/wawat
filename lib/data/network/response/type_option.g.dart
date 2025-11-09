// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_option.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeOptionAdapter extends TypeAdapter<TypeOption> {
  @override
  final int typeId = 11;

  @override
  TypeOption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TypeOption(
      fields[0] as int,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TypeOption obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypeOption _$TypeOptionFromJson(Map<String, dynamic> json) => TypeOption(
      json['id'] as int,
      json['name'] as String,
    );

Map<String, dynamic> _$TypeOptionToJson(TypeOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
