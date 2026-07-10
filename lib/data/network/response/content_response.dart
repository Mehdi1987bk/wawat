import 'package:json_annotation/json_annotation.dart';

part 'content_response.g.dart';

@JsonSerializable()
class ContentResponse {
  final Map<String, String> data;

  ContentResponse({
    this.data = const {},
  });

  factory ContentResponse.fromJson(Map<String, dynamic> json) =>
      _$ContentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ContentResponseToJson(this);
}
