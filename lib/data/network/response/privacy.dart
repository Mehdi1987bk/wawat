import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'privacy.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 3)
class Privacy extends HiveObject {
  @HiveField(0)
  final bool? showPhone;

  @HiveField(1)
  final bool? showEmail;

  @HiveField(2)
  final bool? showLastSeen;

  Privacy({
    required this.showPhone,
    required this.showEmail,
    required this.showLastSeen,
  });

  factory Privacy.fromJson(Map<String, dynamic> json) =>
      _$PrivacyFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacyToJson(this);
}
