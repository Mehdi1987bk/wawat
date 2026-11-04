import 'package:dio/dio.dart';

import '../../../../../main.dart';

const bool kPromoFeatureEnabled = false;

class PromoApi {
  PromoApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  Future<PromoCodesPage> getPromoCodes({String status = 'active'}) async {
    if (!kPromoFeatureEnabled) return const PromoCodesPage.empty();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/me/promo-codes',
        queryParameters: {'status': status},
      );
      return PromoCodesPage.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (_isMissing(error)) return const PromoCodesPage.empty();
      rethrow;
    }
  }

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

  Future<void> markReviewShown({String? promptToken}) =>
      _postReview('shown', body: _tokenBody(promptToken));

  Future<void> markReviewDismissed({String? promptToken}) =>
      _postReview('dismissed', body: _tokenBody(promptToken));

  Future<ReviewReward?> markReviewRated(
      {String? promptToken, int? rating}) async {
    if (!kPromoFeatureEnabled) return null;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/me/app-review-prompt/rated',
        data: {
          if (promptToken != null) 'prompt_token': promptToken,
          if (rating != null) 'rating': rating,
        },
      );
      final data = res.data?['data'];
      if (data is Map) {
        final reward = ReviewReward.fromJson(Map<String, dynamic>.from(data));
        return reward.hasCode ? reward : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _tokenBody(String? token) =>
      token == null ? null : {'prompt_token': token};

  Future<void> _postReview(String action, {Map<String, dynamic>? body}) async {
    if (!kPromoFeatureEnabled) return;
    try {
      await _dio.post<void>(
        '$baseUrl/me/app-review-prompt/$action',
        data: body,
      );
    } catch (_) {
    }
  }

  bool _isMissing(DioException error) {
    final code = error.response?.statusCode;
    return code == 404 || code == 204 || code == 501;
  }
}

class PromoCode {
  final String id;
  final String code;
  final num amount;
  final String currency;
  final String status;
  final String source;
  final String sourceLabel;
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

  String get amountLabel {
    final symbol = currency == 'AZN' ? '\$' : currency;
    final rounded = amount == amount.roundToDouble()
        ? amount.round().toString()
        : '$amount';
    return '$rounded$symbol';
  }

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
      currency: json['currency']?.toString() ?? '\$',
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

class AppReviewPrompt {
  final bool shouldShow;
  final bool alreadyRated;
  final String? promptId;
  final String? promptToken;
  final num rewardAmount;
  final String rewardCurrency;
  final String? rewardCode;
  final DateTime? rewardExpiresAt;
  final num? rewardMinOrder;
  final String? storeUrlIos;
  final String? storeUrlAndroid;
  final Map<String, String> content;

  const AppReviewPrompt({
    required this.shouldShow,
    required this.alreadyRated,
    required this.promptId,
    required this.promptToken,
    required this.rewardAmount,
    required this.rewardCurrency,
    required this.rewardCode,
    required this.rewardExpiresAt,
    required this.rewardMinOrder,
    required this.storeUrlIos,
    required this.storeUrlAndroid,
    required this.content,
  });

  const AppReviewPrompt.fallback()
      : shouldShow = true,
        alreadyRated = false,
        promptId = null,
        promptToken = null,
        rewardAmount = 5,
        rewardCurrency = '\$',
        rewardCode = null,
        rewardExpiresAt = null,
        rewardMinOrder = null,
        storeUrlIos = null,
        storeUrlAndroid = null,
        content = const {};

  String rewardLabel() {
    final symbol = rewardCurrency == 'AZN' ? '\$' : rewardCurrency;
    final rounded = rewardAmount == rewardAmount.roundToDouble()
        ? rewardAmount.round().toString()
        : '$rewardAmount';
    return '$rounded $symbol';
  }

  ReviewReward? get existingReward => (rewardCode ?? '').isEmpty
      ? null
      : ReviewReward(
          code: rewardCode!,
          amount: rewardAmount,
          currency: rewardCurrency,
          expiresAt: rewardExpiresAt,
          minOrderAmount: rewardMinOrder,
        );

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
      alreadyRated: json['already_rated'] == true,
      promptId: json['prompt_id']?.toString(),
      promptToken: json['prompt_token']?.toString(),
      rewardAmount: _num(reward['amount']) ?? 5,
      rewardCurrency: reward['currency']?.toString() ?? '\$',
      rewardCode: reward['code']?.toString(),
      rewardExpiresAt: _dateTime(reward['expires_at']),
      rewardMinOrder: _num(reward['min_order_amount']),
      storeUrlIos: store['ios']?.toString(),
      storeUrlAndroid: store['android']?.toString(),
      content: rawContent.map((key, value) => MapEntry(key, '$value')),
    );
  }
}

class ReviewReward {
  final String code;
  final num amount;
  final String currency;
  final DateTime? expiresAt;
  final num? minOrderAmount;

  const ReviewReward({
    required this.code,
    required this.amount,
    required this.currency,
    this.expiresAt,
    this.minOrderAmount,
  });

  bool get hasCode => code.isNotEmpty;

  String amountLabel() {
    final symbol = currency == 'AZN' ? '\$' : currency;
    final rounded = amount == amount.roundToDouble()
        ? amount.round().toString()
        : '$amount';
    return '$rounded $symbol';
  }

  int? get daysLeft {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    return expiresAt!.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  factory ReviewReward.fromJson(Map<String, dynamic> json) {
    return ReviewReward(
      code: json['code']?.toString() ?? '',
      amount: _num(json['amount']) ?? 0,
      currency: json['currency']?.toString() ?? '\$',
      expiresAt: _dateTime(json['expires_at']),
      minOrderAmount: _num(json['min_order_amount']),
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
