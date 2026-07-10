import 'user.dart';

class MeResponseData {
  final User data;

  const MeResponseData({required this.data});

  factory MeResponseData.fromJson(Map<String, dynamic> json) {
    return MeResponseData(
      data: User.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.toJson(),
      };
}
