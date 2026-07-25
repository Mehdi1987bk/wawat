import 'package:dio/dio.dart';

import '../../../../../main.dart';

/// Feature flag for the promo-codes + app-review-reward feature. The backend
/// endpoints are still being finalized — while this is `true` the client calls
/// them but degrades gracefully on 404 (promo list → empty state, review prompt
/// → not shown). Flip to `false` to hide the menu entry and skip all calls.
const bool kPromoFeatureEnabled = true;

/// Data-layer for promo codes and the store-review reward prompt.
///
/// Mirrors [BlockedUsersApi]: manual `fromJson`, `sl.get<Dio>()`, global
/// [baseUrl]. Every call is defensive — a 404 (endpoint not live yet) or a
/// malformed body resolves to an empty/placeholder result instead of throwing,
/// so nothing fake is ever shown and the UI just falls back to empty/skip.
class PromoApi {
  PromoApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  /// GET /me/promo-codes?status=active|used|expired
  Future<PromoCodesPage> getPromoCodes({String status = 'active'}) async {
    if (!kPromoFeatureEnabled) return const PromoCodesPage.empty();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/me/promo-codes',
        queryParameters: {'status': status},
      );
      return PromoCodesPage.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      // Endpoint not live yet / nothing to show → empty, never fake data.
      if (_isMissing(error)) return const PromoCodesPage.empty();
      rethrow;
    }
  }

  /// GET /me/app-review-prompt → whether to show the store-review alert now.
  /// Returns `null` when the feature is off or the endpoint is missing.
  Future<AppReviewPrompt?> getReviewPrompt() async {
    if (!kPromoFeatureEnabled) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/me/app-review-prompt',
      );
      return AppReviewPrompt.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (_isMissing(error)) return null;
      rethrow;
    }
  }

  /// POST /me/app-review-prompt/{shown|dismissed|rated}. Fire-and-forget:
  /// telemetry must never block or break the UI, so failures are swallowed.
  Future<void> markReviewShown() => _postReview('shown');

  Future<void> markReviewDismissed() => _postReview('dismissed');

  /// Signals the backend the user rated → it credits the promo code (once).
  Future<void> markReviewRated({int? rating}) =>
      _postReview('rated', body: rating == null ? null : {'rating': rating});

  Future<void> _postReview(String action, {Map<String, dynamic>? body}) async {
    if (!kPromoFeatureEnabled) return;
    try {
      await _dio.post<void>(
        '$baseUrl/me/app-review-prompt/$action',
        data: body,
      );
    } catch (_) {
      // best-effort telemetry — ignore.
    }
  }

  bool _isMissing(DioException error) {
    final code = error.response?.statusCode;
    return code == 404 || code == 204 || code == 501;
  }
}

/// A single promo code (coupon) owned by the user.
class PromoCode {
  final String id;
  final String code;
  final num amount;
  final String currency; // e.g. "₼" or "AZN"
  final String status; // active | used | expired
  final String source; // rate_review | referral | welcome | admin
  final String sourceLabel; // localized, straight from backend
  final num? minOrderAmount;
  final DateTime? expiresAt;
  final DateTime? usedAt;
  final String? usedContext;

  const PromoCode({
    required this.id,
    required this.code,
    required this.amount,
    required this.currency,
    required this.status,
    required this.source,
    required this.sourceLabel,
    this.minOrderAmount,
    this.expiresAt,
    this.usedAt,
    this.usedContext,
  });

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';
  bool get isExpired => status == 'expired';

  /// "5₼" — integer amounts drop the decimals.
  String get amountLabel {
    final symbol = currency == 'AZN' ? '₼' : currency;
    final rounded = amount == amount.roundToDouble()
        ? amount.round().toString()
        : '$amount';
    return '$rounded$symbol';
  }

  /// Whole days until expiry (null when no expiry). Negative → already past.
  int? get daysLeft {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    return expiresAt!.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  bool get isExpiringSoon {
    final d = daysLeft;
    return d != null && d >= 0 && d <= 3;
  }

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      amount: _num(json['amount']) ?? 0,
      currency: json['currency']?.toString() ?? '₼',
      status: json['status']?.toString() ?? 'active',
      source: json['source']?.toString() ?? 'admin',
      sourceLabel: json['source_label']?.toString() ?? '',
      minOrderAmount: _num(json['min_order_amount']),
      expiresAt: _dateTime(json['expires_at']),
      usedAt: _dateTime(json['used_at']),
      usedContext: json['used_context']?.toString(),
    );
  }
}

/// A page of promo codes + the active-count meta used by the menu badge.
class PromoCodesPage {
  final List<PromoCode> data;
  final int activeCount;

  const PromoCodesPage({required this.data, required this.activeCount});

  const PromoCodesPage.empty()
      : data = const [],
        activeCount = 0;

  factory PromoCodesPage.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is List
        ? rawData
            .whereType<Map>()
            .map((item) => PromoCode.fromJson(Map<String, dynamic>.from(item)))
            .where((code) => code.id.isNotEmpty)
            .toList()
        : <PromoCode>[];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : const <String, dynamic>{};
    return PromoCodesPage(
      data: data,
      activeCount:
          _int(meta['active_count']) ?? data.where((c) => c.isActive).length,
    );
  }
}

/// The store-review reward prompt payload. Timing/frequency is 100% backend
/// driven — the client only reads [shouldShow] and renders.
class AppReviewPrompt {
  final bool shouldShow;
  final String? promptId;
  final num rewardAmount;
  final String rewardCurrency;
  final String? storeUrlIos;
  final String? storeUrlAndroid;
  final Map<String, String> content;

  const AppReviewPrompt({
    required this.shouldShow,
    required this.promptId,
    required this.rewardAmount,
    required this.rewardCurrency,
    required this.storeUrlIos,
    required this.storeUrlAndroid,
    required this.content,
  });

  String rewardLabel() {
    final symbol = rewardCurrency == 'AZN' ? '₼' : rewardCurrency;
    final rounded = rewardAmount == rewardAmount.roundToDouble()
        ? rewardAmount.round().toString()
        : '$rewardAmount';
    return '$rounded $symbol';
  }

  factory AppReviewPrompt.fromJson(Map<String, dynamic> json) {
    final reward = json['reward'] is Map
        ? Map<String, dynamic>.from(json['reward'] as Map)
        : const <String, dynamic>{};
    final store = json['store_url'] is Map
        ? Map<String, dynamic>.from(json['store_url'] as Map)
        : const <String, dynamic>{};
    final rawContent = json['content'] is Map
        ? Map<String, dynamic>.from(json['content'] as Map)
        : const <String, dynamic>{};
    return AppReviewPrompt(
      shouldShow: json['should_show'] == true,
      promptId: json['prompt_id']?.toString(),
      rewardAmount: _num(reward['amount']) ?? 5,
      rewardCurrency: reward['currency']?.toString() ?? '₼',
      storeUrlIos: store['ios']?.toString(),
      storeUrlAndroid: store['android']?.toString(),
      content: rawContent.map((key, value) => MapEntry(key, '$value')),
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
