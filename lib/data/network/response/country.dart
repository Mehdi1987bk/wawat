import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Country {
  final int id;
  final String code;
  final String name;
  final String? callingCode;

  Country({
    required this.id,
    required this.code,
    required this.name,
    this.callingCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);

  /// Получить флаг эмодзи по коду страны
  String get flagEmoji {
    final codePoints = code.toUpperCase().codeUnits
        .map((char) => char - 0x41 + 0x1F1E6)
        .toList();
    return String.fromCharCodes(codePoints);
  }
}
