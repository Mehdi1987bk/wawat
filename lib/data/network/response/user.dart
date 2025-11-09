import 'package:buking/data/network/response/type_option.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  final String? email;
  @HiveField(4)
  final String? photo;
  @HiveField(5)
  final TypeOption? gender;
  @HiveField(6)
  final TypeOption? status;
  @HiveField(7)
  final String? address;
  @HiveField(8)
  final String? birthday;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photo,
    this.gender,
    this.status,
    this.address,
    this.birthday,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
