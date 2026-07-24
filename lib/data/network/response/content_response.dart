import 'package:json_annotation/json_annotation.dart';

part 'content_response.g.dart';

@JsonSerializable()
class ContentResponse {
  final Map<String, String> data;

  ContentResponse({
    this.data = const {},
  });

  factory ContentResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is Map) {
      return ContentResponse(
        data: raw.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        ),
      );
    }
    return ContentResponse();
  }

  Map<String, dynamic> toJson() => _$ContentResponseToJson(this);
}
