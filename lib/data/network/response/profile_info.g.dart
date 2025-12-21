// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileInfoAdapter extends TypeAdapter<ProfileInfo> {
  @override
  final int typeId = 9;

  @override
  ProfileInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileInfo(
      locationText: fields[0] as String?,
      about: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.locationText)
      ..writeByte(1)
      ..write(obj.about);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileInfo _$ProfileInfoFromJson(Map<String, dynamic> json) => ProfileInfo(
      locationText: json['location_text'] as String?,
      about: json['about'] as String?,
    );

Map<String, dynamic> _$ProfileInfoToJson(ProfileInfo instance) =>
    <String, dynamic>{
      'location_text': instance.locationText,
      'about': instance.about,
    };
