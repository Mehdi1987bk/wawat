

import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'packet_type_resp.g.dart';

@JsonSerializable()
@HiveType(typeId: 16)
class PacketTypeResp extends HiveObject {
  @HiveField(0)
  final String? code;

  @HiveField(1)
  final String? title;

  @HiveField(2)
  final String? icon;

  PacketTypeResp({
    this.code,
    this.title,
    this.icon,
  });

  factory PacketTypeResp.fromJson(Map<String, dynamic> json) => _$PacketTypeRespFromJson(json);

  Map<String, dynamic> toJson() => _$PacketTypeRespToJson(this);
}