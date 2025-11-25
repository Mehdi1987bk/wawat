import 'package:buking/data/network/response/privacy.dart';
import 'package:buking/data/network/response/professional.dart';
import 'package:buking/data/network/response/rating.dart';
import 'package:buking/data/network/response/type_option.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'notifications.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String fullname;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
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
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
