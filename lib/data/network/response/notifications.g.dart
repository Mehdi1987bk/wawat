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
      notifyReviews: fields[1] as bool?,
      notifyMarketing: fields[2] as bool?,
      notifyPush: fields[3] as bool?,
      notifyEmail: fields[4] as bool?,
      notifyShipments: fields[5] as bool?,
      notifyListings: fields[6] as bool?,
      notifyFollows: fields[7] as bool?,
      notifySavedSearch: fields[8] as bool?,
      quietHoursStart: fields[9] as String?,
      quietHoursEnd: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Notifications obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.notifyNewMessages)
      ..writeByte(1)
      ..write(obj.notifyReviews)
      ..writeByte(2)
      ..write(obj.notifyMarketing)
      ..writeByte(3)
      ..write(obj.notifyPush)
      ..writeByte(4)
      ..write(obj.notifyEmail)
      ..writeByte(5)
      ..write(obj.notifyShipments)
      ..writeByte(6)
      ..write(obj.notifyListings)
      ..writeByte(7)
      ..write(obj.notifyFollows)
      ..writeByte(8)
      ..write(obj.notifySavedSearch)
      ..writeByte(9)
      ..write(obj.quietHoursStart)
      ..writeByte(10)
      ..write(obj.quietHoursEnd);
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
      notifyReviews: json['notify_reviews'] as bool?,
      notifyMarketing: json['notify_marketing'] as bool?,
      notifyPush: json['notify_push'] as bool?,
      notifyEmail: json['notify_email'] as bool?,
      notifyShipments: json['notify_shipments'] as bool?,
      notifyListings: json['notify_listings'] as bool?,
      notifyFollows: json['notify_follows'] as bool?,
      notifySavedSearch: json['notify_saved_search'] as bool?,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
    );

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'notify_new_messages': instance.notifyNewMessages,
      'notify_reviews': instance.notifyReviews,
      'notify_marketing': instance.notifyMarketing,
      'notify_push': instance.notifyPush,
      'notify_email': instance.notifyEmail,
      'notify_shipments': instance.notifyShipments,
      'notify_listings': instance.notifyListings,
      'notify_follows': instance.notifyFollows,
      'notify_saved_search': instance.notifySavedSearch,
      'quiet_hours_start': instance.quietHoursStart,
      'quiet_hours_end': instance.quietHoursEnd,
    };
