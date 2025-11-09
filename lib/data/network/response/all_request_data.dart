import 'package:json_annotation/json_annotation.dart';

import 'all_request_response.dart';

part 'all_request_data.g.dart';
@JsonSerializable(explicitToJson: true)
class AllrequestData{
final List<AllRequestResponse> data;

  AllrequestData({required this.data});  

factory AllrequestData.fromJson(Map<String, dynamic> json) => _$AllrequestDataFromJson(json);

Map<String, dynamic> toJson() => _$AllrequestDataToJson(this);
}
