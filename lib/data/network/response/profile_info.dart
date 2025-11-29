import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_info.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 9)
class ProfileInfo extends HiveObject {
  @HiveField(0)
  final String? locationText;
  @HiveField(1)
  final String? about;



  ProfileInfo({
    required this.locationText,
    required this.about,
   });



  factory ProfileInfo.fromJson(Map<String, dynamic> json) =>
      _$ProfileInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileInfoToJson(this);
}
