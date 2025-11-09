import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'type_option.g.dart';

@JsonSerializable()
@HiveType(typeId: 11)
class TypeOption extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;

  TypeOption(this.id, this.name);

  factory TypeOption.fromJson(Map<String, dynamic> json) => _$TypeOptionFromJson(json);

  Map<String, dynamic> toJson() => _$TypeOptionToJson(this);
}
