import 'package:buking/data/network/response/user.dart';
import 'package:json_annotation/json_annotation.dart';

import 'language.dart';

part 'language_response.g.dart';

@JsonSerializable()
class LanguageResponse {
  final List<Language> data;

  LanguageResponse({required this.data});

  factory LanguageResponse.fromJson(Map<String, dynamic> json) =>
      _$LanguageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageResponseToJson(this);
}

