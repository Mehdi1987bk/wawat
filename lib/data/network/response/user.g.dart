// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int?,
      fullname: fields[1] as String,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      avatar: fields[4] as String?,
      location: fields[5] as String?,
      about: fields[6] as String?,
      professional: fields[7] as Professional?,
      privacy: fields[8] as Privacy?,
      notifications: fields[9] as Notifications?,
      rating: fields[10] as Rating?,
      createdAt: fields[11] as DateTime?,
      profile: fields[12] as ProfileInfo?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullname)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.avatar)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.about)
      ..writeByte(7)
      ..write(obj.professional)
      ..writeByte(8)
      ..write(obj.privacy)
      ..writeByte(9)
      ..write(obj.notifications)
      ..writeByte(10)
      ..write(obj.rating)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.profile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int?,
      fullname: json['fullname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      location: json['location'] as String?,
      about: json['about'] as String?,
      professional: json['professional'] == null
          ? null
          : Professional.fromJson(json['professional'] as Map<String, dynamic>),
      privacy: json['privacy'] == null
          ? null
          : Privacy.fromJson(json['privacy'] as Map<String, dynamic>),
      notifications: json['notifications'] == null
          ? null
          : Notifications.fromJson(
              json['notifications'] as Map<String, dynamic>),
      rating: json['rating'] == null
          ? null
          : Rating.fromJson(json['rating'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      profile: json['profile'] == null
          ? null
          : ProfileInfo.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'email': instance.email,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'location': instance.location,
      'about': instance.about,
      'professional': instance.professional,
      'privacy': instance.privacy,
      'notifications': instance.notifications,
      'rating': instance.rating,
      'created_at': instance.createdAt?.toIso8601String(),
      'profile': instance.profile,
    };
