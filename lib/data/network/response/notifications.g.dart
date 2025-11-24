// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationsAdapter extends TypeAdapter<Notifications> {
  @override
  final int typeId = 4;

  @override
  Notifications read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notifications(
      newMessages: fields[0] as bool?,
      newReviews: fields[1] as bool?,
      marketing: fields[2] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Notifications obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.newMessages)
      ..writeByte(1)
      ..write(obj.newReviews)
      ..writeByte(2)
      ..write(obj.marketing);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notifications _$NotificationsFromJson(Map<String, dynamic> json) =>
    Notifications(
      newMessages: json['new_messages'] as bool?,
      newReviews: json['new_reviews'] as bool?,
      marketing: json['marketing'] as bool?,
    );

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'new_messages': instance.newMessages,
      'new_reviews': instance.newReviews,
      'marketing': instance.marketing,
    };
