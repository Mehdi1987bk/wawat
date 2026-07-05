import 'package:buking/data/network/response/privacy.dart';
import 'package:buking/data/network/response/professional.dart';
import 'package:buking/data/network/response/profile_info.dart';
import 'package:buking/data/network/response/rating.dart';
import 'package:buking/data/network/response/stats.dart';
import 'package:buking/data/network/response/country.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'notifications.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final dynamic id;

  @HiveField(1)
  @JsonKey(readValue: _readFullName)
  final String fullname;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  @JsonKey(readValue: _readAvatar)
  final String? avatar;

  @HiveField(5)
  final String? location;

  @HiveField(6)
  final String? about;

  @HiveField(7)
  final Professional? professional;

  @HiveField(8)
  final Privacy? privacy;

  @HiveField(9)
  final Notifications? notifications;

  @HiveField(10)
  final Rating? rating;

  @HiveField(11)
  final DateTime? createdAt;

  @HiveField(12)
  final ProfileInfo? profile;

  @HiveField(13)
  final bool? isVerified;

  @HiveField(14)
  final Stats? stats;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'email_verified')
  final bool? emailVerified;

  @JsonKey(name: 'preferred_locale')
  final String? preferredLocale;

  @JsonKey(name: 'avatar_thumb_url')
  final String? avatarThumbUrl;

  final Country? country;

  User({
    required this.id,
    required this.fullname,
    this.email,
    this.phone,
    this.avatar,
    this.location,
    this.about,
    this.professional,
    this.privacy,
    this.notifications,
    this.rating,
    this.createdAt,
    this.isVerified,
    this.profile,
    this.stats,
    this.username,
    this.firstName,
    this.lastName,
    this.emailVerified,
    this.preferredLocale,
    this.avatarThumbUrl,
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

Object? _readFullName(Map json, String key) {
  return json['full_name'] ?? json['fullname'] ?? '';
}

Object? _readAvatar(Map json, String key) {
  return json['avatar_url'] ?? json['avatar'];
}
