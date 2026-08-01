import 'package:dio/dio.dart';

import '../../../../../main.dart';

/// Data-layer for the "Dostunu dəvət et" (referral) feature, wired to the live
/// API. Mirrors [BlockedUsersApi]: `sl.get<Dio>()`, global [baseUrl], manual
/// `fromJson`, defensive on 404 (empty stats / empty invite list).
class ReferralApi {
  ReferralApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  /// GET /me/referral → code, share link, stats.
  Future<ReferralInfo> getInfo() async {
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

  /// Public pre-registration preview: GET /referral/{code} (no auth).
  Future<ReferralInviter?> getInviter(String code) async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('$baseUrl/referral/$code');
      final data = res.data?['data'] is Map
          ? Map<String, dynamic>.from(res.data!['data'] as Map)
          : (res.data ?? const {});
      return ReferralInviter.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      if (_missing(error)) return null;
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
  final int rewarded;
  final num earned;
  final num rewardAmount;
  final String currency;

  const ReferralInfo({
    required this.code,
    required this.shareLink,
    required this.invited,
    required this.joined,
    required this.rewarded,
    required this.earned,
    required this.rewardAmount,
    required this.currency,
  });

  const ReferralInfo.empty()
      : code = '',
        shareLink = '',
        invited = 0,
        joined = 0,
        rewarded = 0,
        earned = 0,
        rewardAmount = 5,
        currency = '\$';

  bool get isReady => code.isNotEmpty;

  String get currencySymbol => currency == 'AZN' ? '\$' : currency;

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      code: json['code']?.toString() ?? '',
      shareLink: json['share_link']?.toString() ?? '',
      invited: _int(json['invited']) ?? 0,
      joined: _int(json['joined']) ?? 0,
      rewarded: _int(json['rewarded']) ?? 0,
      earned: _num(json['earned']) ?? 0,
      rewardAmount: _num(json['reward_amount']) ?? 5,
      currency: json['currency']?.toString() ?? '\$',
    );
  }
}

class ReferralInvite {
  final String id;
  final String name;
  final String? avatar;
  final String status; // rewarded | pending | joined | ...
  final String statusLabel;
  final DateTime? invitedAt;
  final DateTime? rewardedAt;

  const ReferralInvite({
    required this.id,
    required this.name,
    required this.avatar,
    required this.status,
    required this.statusLabel,
    required this.invitedAt,
    required this.rewardedAt,
  });

  bool get isRewarded => status == 'rewarded' || status == 'joined';

  DateTime? get displayDate => rewardedAt ?? invitedAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  factory ReferralInvite.fromJson(Map<String, dynamic> json) {
    return ReferralInvite(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      // Ready thumbnail url (the old raw `avatar` path never rendered).
      avatar: json['avatar_thumb_url']?.toString() ??
          json['avatar_url']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? '',
      invitedAt: _dateTime(json['invited_at']),
      rewardedAt: _dateTime(json['rewarded_at']),
    );
  }
}

/// Public inviter preview shown on the pre-registration landing.
class ReferralInviter {
  final String code;
  final String referrerName;
  final String? referrerAvatar;
  final num rewardAmount;

  const ReferralInviter({
    required this.code,
    required this.referrerName,
    required this.referrerAvatar,
    required this.rewardAmount,
  });

  factory ReferralInviter.fromJson(Map<String, dynamic> json) {
    final referrer = json['referrer'] is Map
        ? Map<String, dynamic>.from(json['referrer'] as Map)
        : const <String, dynamic>{};
    return ReferralInviter(
      code: json['code']?.toString() ?? '',
      referrerName: referrer['name']?.toString() ?? '',
      referrerAvatar: referrer['avatar_thumb_url']?.toString() ??
          referrer['avatar_url']?.toString(),
      rewardAmount: _num(json['reward_amount']) ?? 5,
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
