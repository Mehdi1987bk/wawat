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
      id: fields[0] as dynamic,
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
      isVerified: fields[13] as bool?,
      profile: fields[12] as ProfileInfo?,
      stats: fields[14] as Stats?,
      listingQuota: fields[21] as ListingQuota?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.profile)
      ..writeByte(13)
      ..write(obj.isVerified)
      ..writeByte(14)
      ..write(obj.stats)
      ..writeByte(21)
      ..write(obj.listingQuota);
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

class ListingQuotaAdapter extends TypeAdapter<ListingQuota> {
  @override
  final int typeId = 61;

  @override
  ListingQuota read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListingQuota(
      trip: fields[0] as ListingQuotaItem?,
      shipmentPost: fields[1] as ListingQuotaItem?,
    );
  }

  @override
  void write(BinaryWriter writer, ListingQuota obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.trip)
      ..writeByte(1)
      ..write(obj.shipmentPost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingQuotaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListingQuotaItemAdapter extends TypeAdapter<ListingQuotaItem> {
  @override
  final int typeId = 62;

  @override
  ListingQuotaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListingQuotaItem(
      active: fields[0] as int,
      limit: fields[1] as int,
      remaining: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ListingQuotaItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.active)
      ..writeByte(1)
      ..write(obj.limit)
      ..writeByte(2)
      ..write(obj.remaining);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingQuotaItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      fullname: _readFullName(json, 'fullname') as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: _readAvatar(json, 'avatar') as String?,
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
      isVerified: json['is_verified'] as bool?,
      profile: json['profile'] == null
          ? null
          : ProfileInfo.fromJson(json['profile'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? null
          : Stats.fromJson(json['stats'] as Map<String, dynamic>),
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      emailVerified: json['email_verified'] as bool?,
      preferredLocale: json['preferred_locale'] as String?,
      avatarThumbUrl: json['avatar_thumb_url'] as String?,
      status: json['status'] as String?,
      tier: json['tier'] as String?,
      ratingAvg: (_readRatingAvg(json, 'rating_avg') as num?)?.toDouble(),
      ratingCount: (_readRatingCount(json, 'rating_count') as num?)?.toInt(),
      completedShipmentsCount:
          (_readCompletedShipmentsCount(json, 'completed_shipments_count')
                  as num?)
              ?.toInt(),
      memberSince: json['member_since'] == null
          ? null
          : DateTime.parse(json['member_since'] as String),
      country: json['country'] == null
          ? null
          : Country.fromJson(json['country'] as Map<String, dynamic>),
      listingQuota: json['listing_quota'] == null
          ? null
          : ListingQuota.fromJson(
              json['listing_quota'] as Map<String, dynamic>),
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
      'is_verified': instance.isVerified,
      'stats': instance.stats,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email_verified': instance.emailVerified,
      'preferred_locale': instance.preferredLocale,
      'avatar_thumb_url': instance.avatarThumbUrl,
      'status': instance.status,
      'tier': instance.tier,
      'rating_avg': instance.ratingAvg,
      'rating_count': instance.ratingCount,
      'completed_shipments_count': instance.completedShipmentsCount,
      'member_since': instance.memberSince?.toIso8601String(),
      'country': instance.country,
      'listing_quota': instance.listingQuota,
    };

ListingQuota _$ListingQuotaFromJson(Map<String, dynamic> json) => ListingQuota(
      trip: json['trip'] == null
          ? null
          : ListingQuotaItem.fromJson(json['trip'] as Map<String, dynamic>),
      shipmentPost: json['shipment_post'] == null
          ? null
          : ListingQuotaItem.fromJson(
              json['shipment_post'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListingQuotaToJson(ListingQuota instance) =>
    <String, dynamic>{
      'trip': instance.trip,
      'shipment_post': instance.shipmentPost,
    };

ListingQuotaItem _$ListingQuotaItemFromJson(Map<String, dynamic> json) =>
    ListingQuotaItem(
      active: (json['active'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ListingQuotaItemToJson(ListingQuotaItem instance) =>
    <String, dynamic>{
      'active': instance.active,
      'limit': instance.limit,
      'remaining': instance.remaining,
    };
