// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packet_type_resp.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PacketTypeRespAdapter extends TypeAdapter<PacketTypeResp> {
  @override
  final int typeId = 16;

  @override
  PacketTypeResp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PacketTypeResp(
      code: fields[0] as String?,
      title: fields[1] as String?,
      icon: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PacketTypeResp obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PacketTypeRespAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PacketTypeResp _$PacketTypeRespFromJson(Map<String, dynamic> json) =>
    PacketTypeResp(
      code: json['code'] as String?,
      title: json['title'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$PacketTypeRespToJson(PacketTypeResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'icon': instance.icon,
    };
