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
      notifyNewMessages: fields[0] as bool?,
      notifyNewReviews: fields[1] as bool?,
      notifyMarketing: fields[2] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Notifications obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.notifyNewMessages)
      ..writeByte(1)
      ..write(obj.notifyNewReviews)
      ..writeByte(2)
      ..write(obj.notifyMarketing);
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
      notifyNewMessages: json['notify_new_messages'] as bool?,
      notifyNewReviews: json['notify_new_reviews'] as bool?,
      notifyMarketing: json['notify_marketing'] as bool?,
    );

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'notify_new_messages': instance.notifyNewMessages,
      'notify_new_reviews': instance.notifyNewReviews,
      'notify_marketing': instance.notifyMarketing,
    };
