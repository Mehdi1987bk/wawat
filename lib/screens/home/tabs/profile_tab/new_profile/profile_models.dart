import 'package:characters/characters.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../domain/entities/pagination.dart';

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _doubleValue(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool _boolValue(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return fallback;
}

Map<String, dynamic> _mapValue(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _listMapValue(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

class WawatProfileResponse {
  final WawatProfileUser data;

  const WawatProfileResponse({required this.data});

  factory WawatProfileResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return WawatProfileResponse(
      data: WawatProfileUser.fromJson(
        raw is Map ? Map<String, dynamic>.from(raw) : json,
      ),
    );
  }
}

class WawatProfileUser {
  final String id;
  final String? username;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final bool isVerified;
  final String? status;
  final String? tier;
  final bool isFollowing;
  final int followersCount;
  final int followingCount;
  final DateTime? memberSince;
  final String? email;
  final String? phone;
  final bool emailVerified;
  final String? preferredLocale;
  final List<WawatLanguage> languages;
  final WawatTrust trust;
  final WawatProfileStats stats;
  final WawatProfileSettings settings;

  const WawatProfileUser({
    required this.id,
    required this.fullName,
    this.username,
    this.firstName,
    this.lastName,
    this.bio,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.isVerified = false,
    this.status,
    this.tier,
    this.isFollowing = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.memberSince,
    this.email,
    this.phone,
    this.emailVerified = false,
    this.preferredLocale,
    this.languages = const [],
    this.trust = const WawatTrust(),
    this.stats = const WawatProfileStats(),
    this.settings = const WawatProfileSettings(),
  });

  factory WawatProfileUser.fromJson(Map<String, dynamic> json) {
    final trust = WawatTrust.fromJson(_mapValue(json['trust']));
    final stats = WawatProfileStats.fromJson(_mapValue(json['stats']));
    return WawatProfileUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString(),
      fullName: (json['full_name'] ??
              json['fullname'] ??
              [
                json['first_name']?.toString(),
                json['last_name']?.toString(),
              ]
                  .where((part) => part != null && part.trim().isNotEmpty)
                  .join(' '))
          .toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      bio: (json['bio'] ?? json['about'])?.toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatar'])?.toString(),
      avatarThumbUrl: json['avatar_thumb_url']?.toString(),
      isVerified: _boolValue(json['is_verified']),
      status: json['status']?.toString(),
      tier: json['tier']?.toString(),
      isFollowing: _boolValue(json['is_following']),
      followersCount: _intValue(json['followers_count']) ?? 0,
      followingCount: _intValue(json['following_count']) ?? 0,
      memberSince: DateTime.tryParse(json['member_since']?.toString() ?? '') ??
          DateTime.tryParse(json['created_at']?.toString() ?? ''),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      emailVerified: _boolValue(json['email_verified']),
      preferredLocale: json['preferred_locale']?.toString(),
      languages:
          _listMapValue(json['languages']).map(WawatLanguage.fromJson).toList(),
      trust: trust,
      stats: stats.copyWith(
        deliveriesCount: stats.deliveriesCount ?? trust.completedShipmentsCount,
        reviewsReceivedCount: stats.reviewsReceivedCount ?? trust.ratingCount,
      ),
      settings: WawatProfileSettings.fromJson(_mapValue(json['settings'])),
    );
  }

  String get safeFullName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (username != null && username!.trim().isNotEmpty) return '@$username';
    return 'Wawatair';
  }

  String get initials {
    final source = safeFullName.replaceAll('@', '').trim();
    final parts = source.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final letters = parts.take(2).map((e) => e.characters.first).join();
    return letters.isEmpty ? 'W' : letters.toUpperCase();
  }

  WawatProfileUser copyWith({
    bool? isFollowing,
    int? followersCount,
  }) {
    return WawatProfileUser(
      id: id,
      username: username,
      fullName: fullName,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      avatarUrl: avatarUrl,
      avatarThumbUrl: avatarThumbUrl,
      isVerified: isVerified,
      status: status,
      tier: tier,
      isFollowing: isFollowing ?? this.isFollowing,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount,
      memberSince: memberSince,
      email: email,
      phone: phone,
      emailVerified: emailVerified,
      preferredLocale: preferredLocale,
      languages: languages,
      trust: trust,
      stats: stats,
      settings: settings,
    );
  }
}

class WawatLanguage {
  final String code;
  final String name;

  const WawatLanguage({required this.code, required this.name});

  factory WawatLanguage.fromJson(Map<String, dynamic> json) {
    return WawatLanguage(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['code']?.toString() ?? '',
    );
  }
}

class WawatTrust {
  final double? ratingAvg;
  final int? ratingCount;
  final int? completedShipmentsCount;
  final double? cancelRate;
  final int? avgResponseMinutes;

  const WawatTrust({
    this.ratingAvg,
    this.ratingCount,
    this.completedShipmentsCount,
    this.cancelRate,
    this.avgResponseMinutes,
  });

  factory WawatTrust.fromJson(Map<String, dynamic> json) {
    return WawatTrust(
      ratingAvg: _doubleValue(json['rating_avg']),
      ratingCount: _intValue(json['rating_count']),
      completedShipmentsCount: _intValue(json['completed_shipments_count']),
      cancelRate: _doubleValue(json['cancel_rate']),
      avgResponseMinutes: _intValue(json['avg_response_minutes']),
    );
  }
}

class WawatProfileStats {
  final int? listingsTotal;
  final int? listingsActive;
  final int? deliveriesCount;
  final int? reviewsReceivedCount;
  final double? successRate;
  final int? yearsOnPlatform;

  const WawatProfileStats({
    this.listingsTotal,
    this.listingsActive,
    this.deliveriesCount,
    this.reviewsReceivedCount,
    this.successRate,
    this.yearsOnPlatform,
  });

  factory WawatProfileStats.fromJson(Map<String, dynamic> json) {
    return WawatProfileStats(
      listingsTotal: _intValue(json['listings_total']),
      listingsActive: _intValue(json['listings_active']),
      deliveriesCount: _intValue(json['deliveries_count']),
      reviewsReceivedCount: _intValue(json['reviews_received_count']),
      successRate: _doubleValue(json['success_rate']),
      yearsOnPlatform: _intValue(json['years_on_platform']),
    );
  }

  WawatProfileStats copyWith({
    int? deliveriesCount,
    int? reviewsReceivedCount,
  }) {
    return WawatProfileStats(
      listingsTotal: listingsTotal,
      listingsActive: listingsActive,
      deliveriesCount: deliveriesCount ?? this.deliveriesCount,
      reviewsReceivedCount: reviewsReceivedCount ?? this.reviewsReceivedCount,
      successRate: successRate,
      yearsOnPlatform: yearsOnPlatform,
    );
  }
}

class WawatProfileSettings {
  final WawatPrivacySettings privacy;

  const WawatProfileSettings({
    this.privacy = const WawatPrivacySettings(),
  });

  factory WawatProfileSettings.fromJson(Map<String, dynamic> json) {
    return WawatProfileSettings(
      privacy: WawatPrivacySettings.fromJson(_mapValue(json['privacy'])),
    );
  }
}

class WawatPrivacySettings {
  final bool showPhone;
  final bool showEmail;
  final bool showActivityTime;
  final bool showLanguages;

  const WawatPrivacySettings({
    this.showPhone = false,
    this.showEmail = false,
    this.showActivityTime = true,
    this.showLanguages = true,
  });

  factory WawatPrivacySettings.fromJson(Map<String, dynamic> json) {
    return WawatPrivacySettings(
      showPhone: _boolValue(json['show_phone']),
      showEmail: _boolValue(json['show_email']),
      showActivityTime: _boolValue(json['show_activity_time'], fallback: true),
      showLanguages: _boolValue(json['show_languages'], fallback: true),
    );
  }

  Map<String, dynamic> toJson() => {
        'show_phone': showPhone,
        'show_email': showEmail,
        'show_activity_time': showActivityTime,
        'show_languages': showLanguages,
      };

  WawatPrivacySettings copyWith({
    bool? showPhone,
    bool? showEmail,
    bool? showActivityTime,
    bool? showLanguages,
  }) {
    return WawatPrivacySettings(
      showPhone: showPhone ?? this.showPhone,
      showEmail: showEmail ?? this.showEmail,
      showActivityTime: showActivityTime ?? this.showActivityTime,
      showLanguages: showLanguages ?? this.showLanguages,
    );
  }
}

class WawatReviewResponse {
  final List<WawatReview> data;
  final Map<int, int> distribution;
  final int total;

  const WawatReviewResponse({
    required this.data,
    required this.distribution,
    this.total = 0,
  });

  factory WawatReviewResponse.fromJson(Map<String, dynamic> json) {
    final meta = _mapValue(json['meta']);
    final rawDistribution = _mapValue(meta['distribution']);
    return WawatReviewResponse(
      data: _listMapValue(json['data']).map(WawatReview.fromJson).toList(),
      distribution: {
        for (var star = 1; star <= 5; star++)
          star: _intValue(rawDistribution['$star']) ?? 0,
      },
      total: _intValue(meta['total']) ?? 0,
    );
  }
}

class WawatReview {
  final String id;
  final int rating;
  final String? comment;
  final String? status;
  final bool isVerifiedShipment;
  final String? reply;
  final WawatReviewUser? author;
  final WawatReviewUser? target;
  final DateTime? createdAt;

  const WawatReview({
    required this.id,
    required this.rating,
    this.comment,
    this.status,
    this.isVerifiedShipment = true,
    this.reply,
    this.author,
    this.target,
    this.createdAt,
  });

  factory WawatReview.fromJson(Map<String, dynamic> json) {
    return WawatReview(
      id: json['id']?.toString() ?? '',
      rating: _intValue(json['rating']) ?? 0,
      comment: json['comment']?.toString(),
      status: json['status']?.toString(),
      isVerifiedShipment:
          _boolValue(json['is_verified_shipment'], fallback: true),
      reply: json['reply']?.toString(),
      author: json['author'] is Map
          ? WawatReviewUser.fromJson(_mapValue(json['author']))
          : null,
      target: json['target'] is Map
          ? WawatReviewUser.fromJson(_mapValue(json['target']))
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class WawatReviewUser {
  final String? username;
  final bool isVerified;

  const WawatReviewUser({this.username, this.isVerified = false});

  factory WawatReviewUser.fromJson(Map<String, dynamic> json) {
    return WawatReviewUser(
      username: json['username']?.toString(),
      isVerified: _boolValue(json['is_verified']),
    );
  }

  String get displayName {
    final value = username?.trim() ?? '';
    if (value.isEmpty) return '@user';
    return value.startsWith('@') ? value : '@$value';
  }

  String get initials {
    final clean = (username ?? 'U').replaceAll('@', '').trim();
    return clean.isEmpty ? 'U' : clean.characters.first.toUpperCase();
  }
}

class WawatProfileBundle {
  final WawatProfileUser user;
  final Pagination<Listing> listings;
  final WawatReviewResponse reviews;
  final Map<String, String> content;
  final Map<String, String> packageNames;

  const WawatProfileBundle({
    required this.user,
    required this.listings,
    required this.reviews,
    required this.content,
    required this.packageNames,
  });
}
