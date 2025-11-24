import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'language.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class Language extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String? code;

  @HiveField(2)
  final String? name;

  Language({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}
