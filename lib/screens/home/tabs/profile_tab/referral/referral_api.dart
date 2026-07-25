import 'package:dio/dio.dart';

import '../../../../../main.dart';

/// Feature flag for the referral feature. `true` → calls the endpoints but
/// degrades gracefully on 404 (empty stats / empty invite list). Never fakes.
const bool kReferralEnabled = true;

/// Data-layer for the "Dostunu dəvət et" (referral) feature. Mirrors
/// [BlockedUsersApi]: `sl.get<Dio>()`, global [baseUrl], manual `fromJson`,
/// defensive on 404 so the UI falls back to an empty state, never fake data.
class ReferralApi {
  ReferralApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  /// GET /me/referral → code, share link, stats.
  Future<ReferralInfo> getInfo() async {
    if (!kReferralEnabled) return const ReferralInfo.empty();
    try {
      final res = await _dio.get<Map<String, dynamic>>('$baseUrl/me/referral');
      final data = res.data?['data'] is Map
          ? Map<String, dynamic>.from(res.data!['data'] as Map)
          : (res.data ?? const {});
      return ReferralInfo.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      if (_missing(error)) return const ReferralInfo.empty();
      rethrow;
    }
  }

  /// GET /me/referral/invites → the people this user invited.
  Future<List<ReferralInvite>> getInvites() async {
    if (!kReferralEnabled) return const [];
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('$baseUrl/me/referral/invites');
      final raw = res.data?['data'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => ReferralInvite.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (error) {
      if (_missing(error)) return const [];
      rethrow;
    }
  }

  bool _missing(DioException error) {
    final code = error.response?.statusCode;
    return code == 404 || code == 204 || code == 501;
  }
}

class ReferralInfo {
  final String code;
  final String shareLink;
  final int invited;
  final int joined;
  final num rewarded;
  final num rewardAmount;
  final String currency;

  const ReferralInfo({
    required this.code,
    required this.shareLink,
    required this.invited,
    required this.joined,
    required this.rewarded,
    required this.rewardAmount,
    required this.currency,
  });

  const ReferralInfo.empty()
      : code = '',
        shareLink = '',
        invited = 0,
        joined = 0,
        rewarded = 0,
        rewardAmount = 5,
        currency = '₼';

  bool get isReady => code.isNotEmpty;

  String get currencySymbol => currency == 'AZN' ? '₼' : currency;

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      code: json['code']?.toString() ?? '',
      shareLink: json['share_link']?.toString() ?? '',
      invited: _int(json['invited']) ?? 0,
      joined: _int(json['joined']) ?? 0,
      rewarded: _num(json['rewarded']) ?? 0,
      rewardAmount: _num(json['reward_amount']) ?? 5,
      currency: json['currency']?.toString() ?? '₼',
    );
  }
}

class ReferralInvite {
  final String name;
  final String? avatar;
  final String status; // joined | pending
  final DateTime? joinedAt;
  final num? rewardAmount;

  const ReferralInvite({
    required this.name,
    required this.avatar,
    required this.status,
    required this.joinedAt,
    required this.rewardAmount,
  });

  bool get isJoined => status == 'joined';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  factory ReferralInvite.fromJson(Map<String, dynamic> json) {
    return ReferralInvite(
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      joinedAt: _dateTime(json['joined_at']),
      rewardAmount: _num(json['reward_amount']),
    );
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

num? _num(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

DateTime? _dateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
