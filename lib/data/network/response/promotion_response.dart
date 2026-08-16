import 'receipt.dart';

class PromotionPricingResponse {
  final PromotionPricing data;
  final String? message;

  const PromotionPricingResponse({required this.data, this.message});

  factory PromotionPricingResponse.fromJson(Map<String, dynamic> json) {
    return PromotionPricingResponse(
      data: PromotionPricing.fromJson(_map(json['data'])),
      message: json['message']?.toString(),
    );
  }
}

class PromotionPricing {
  final String currency;
  final List<int> durations;
  final PromotionProductPricing vip;
  final PromotionBoostPricing boost;

  const PromotionPricing({
    required this.currency,
    required this.durations,
    required this.vip,
    required this.boost,
  });

  factory PromotionPricing.fromJson(Map<String, dynamic> json) {
    return PromotionPricing(
      currency: json['currency']?.toString() ?? 'AZN',
      durations: _list(json['durations']).map(_int).whereType<int>().toList(),
      vip: PromotionProductPricing.fromJson(_map(json['vip'])),
      boost: PromotionBoostPricing.fromJson(_map(json['boost'])),
    );
  }
}

class PromotionProductPricing {
  final String type;
  final String label;
  final Map<int, double> prices;

  const PromotionProductPricing({
    required this.type,
    required this.label,
    required this.prices,
  });

  factory PromotionProductPricing.fromJson(Map<String, dynamic> json) {
    return PromotionProductPricing(
      type: json['type']?.toString() ?? 'vip',
      label: json['label']?.toString() ?? 'VİP',
      prices: _priceMap(json['prices']),
    );
  }
}

class PromotionBoostPricing {
  final String type;
  final String label;
  final List<PromotionBoostPackage> packages;

  const PromotionBoostPricing({
    required this.type,
    required this.label,
    required this.packages,
  });

  factory PromotionBoostPricing.fromJson(Map<String, dynamic> json) {
    return PromotionBoostPricing(
      type: json['type']?.toString() ?? 'featured',
      label: json['label']?.toString() ?? 'Önə çıxarılan',
      packages: _list(json['packages'])
          .whereType<Map>()
          .map((item) =>
              PromotionBoostPackage.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

/// One guaranteed-impressions boost package (large / medium / small). Price is
/// flat — there are no days. The listing stays boosted until it reaches its
/// target impressions, then finishes automatically. `guaranteedMin`–
/// `guaranteedMax` is the promised impression range, computed server-side from
/// the active-user count, so it must never be hardcoded — always read the fresh
/// values from `/promotions/pricing`.
class PromotionBoostPackage {
  final String package;
  final String label;
  final double price;
  final int guaranteedMin;
  final int guaranteedMax;

  const PromotionBoostPackage({
    required this.package,
    required this.label,
    required this.price,
    required this.guaranteedMin,
    required this.guaranteedMax,
  });

  factory PromotionBoostPackage.fromJson(Map<String, dynamic> json) {
    return PromotionBoostPackage(
      package: json['package']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      price: _double(json['price']) ?? 0,
      guaranteedMin: _int(json['guaranteed_min']) ?? 0,
      guaranteedMax: _int(json['guaranteed_max']) ?? 0,
    );
  }
}

class PromotionResponse {
  final Promotion data;
  final String? message;
  final Receipt? receipt;

  const PromotionResponse({required this.data, this.message, this.receipt});

  factory PromotionResponse.fromJson(Map<String, dynamic> json) {
    return PromotionResponse(
      data: Promotion.fromJson(_map(json['data'])),
      message: json['message']?.toString(),
      receipt: Receipt.fromResponse(json),
    );
  }
}

class PromotionQuoteResponse {
  final PromotionQuote data;
  final String? message;

  const PromotionQuoteResponse({required this.data, this.message});

  factory PromotionQuoteResponse.fromJson(Map<String, dynamic> json) {
    return PromotionQuoteResponse(
      data: PromotionQuote.fromJson(_map(json['data'])),
      message: json['message']?.toString(),
    );
  }
}

/// Preview of a promo code applied to a pending promotion order — returned by
/// `POST /promotions/{id}/quote`. `applicable` gates the discount; when it's
/// false, `reason` explains why (invalid | below_min_order | currency_mismatch
/// | feature_disabled | listing_not_active | no_promo_code).
class PromotionQuote {
  final double baseAmount;
  final double discount;
  final double finalAmount;
  final String currency;
  final bool applicable;
  final String? reason;

  const PromotionQuote({
    required this.baseAmount,
    required this.discount,
    required this.finalAmount,
    required this.currency,
    required this.applicable,
    this.reason,
  });

  factory PromotionQuote.fromJson(Map<String, dynamic> json) {
    return PromotionQuote(
      baseAmount: _double(json['base_amount']) ?? 0,
      discount: _double(json['discount']) ?? 0,
      finalAmount: _double(json['final_amount']) ?? 0,
      currency: json['currency']?.toString() ?? 'AZN',
      applicable: _bool(json['applicable']) ?? false,
      reason: json['reason']?.toString(),
    );
  }
}

class PromotionsResponse {
  final List<Promotion> data;
  final PromotionPagination? meta;
  final String? message;

  const PromotionsResponse({
    required this.data,
    this.meta,
    this.message,
  });

  factory PromotionsResponse.fromJson(Map<String, dynamic> json) {
    return PromotionsResponse(
      data: _list(json['data'])
          .whereType<Map>()
          .map((item) => Promotion.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      meta: json['meta'] is Map
          ? PromotionPagination.fromJson(_map(json['meta']))
          : null,
      message: json['message']?.toString(),
    );
  }
}

class Promotion {
  final String id;
  final String? listingId;
  final String type;
  final String typeLabel;
  final String? tier;
  final String? tierLabel;

  /// Boost package code / label (`large` | `medium` | `small`). Null for VIP.
  final String? package;
  final String? packageLabel;

  /// Guaranteed-impressions progress for a boost promotion. Null for VIP, where
  /// [durationDays] / [endsAt] / [remainingSeconds] drive the countdown instead.
  final PromotionImpressions? impressions;

  final int durationDays;
  final double amount;

  /// Promo discount / net charged — present only on the pay response
  /// (`discount_amount` / `final_amount`). Null on the pending order, where only
  /// [amount] (base price) is known.
  final double? discountAmount;
  final double? finalAmount;
  final String currency;
  final String status;
  final String statusLabel;
  final String? startsAt;
  final String? endsAt;
  final String? paidAt;
  final int remainingSeconds;
  final String? promoCode;
  final PromotionPayment? payment;
  final String? createdAt;
  final PromotionListingSummary? listing;

  const Promotion({
    required this.id,
    this.listingId,
    required this.type,
    required this.typeLabel,
    this.tier,
    this.tierLabel,
    this.package,
    this.packageLabel,
    this.impressions,
    required this.durationDays,
    required this.amount,
    this.discountAmount,
    this.finalAmount,
    required this.currency,
    required this.status,
    required this.statusLabel,
    this.startsAt,
    this.endsAt,
    this.paidAt,
    required this.remainingSeconds,
    this.promoCode,
    this.payment,
    this.createdAt,
    this.listing,
  });

  /// The amount actually charged — the discounted total when a promo applied,
  /// otherwise the base price. Use this for revenue telemetry.
  double get chargedAmount => finalAmount ?? amount;

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id']?.toString() ?? '',
      listingId: json['listing_id']?.toString(),
      type: json['type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? '',
      tier: json['tier']?.toString(),
      tierLabel: json['tier_label']?.toString(),
      package: json['package']?.toString(),
      packageLabel: json['package_label']?.toString(),
      impressions: json['impressions'] is Map
          ? PromotionImpressions.fromJson(_map(json['impressions']))
          : null,
      durationDays: _int(json['duration_days']) ?? 0,
      amount: _double(json['amount']) ?? 0,
      discountAmount: _double(json['discount_amount']),
      finalAmount: _double(json['final_amount']),
      currency: json['currency']?.toString() ?? 'AZN',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      startsAt: json['starts_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
      paidAt: json['paid_at']?.toString(),
      remainingSeconds: _int(json['remaining_seconds']) ?? 0,
      promoCode: json['promo_code']?.toString(),
      payment: json['payment'] is Map
          ? PromotionPayment.fromJson(_map(json['payment']))
          : null,
      createdAt: json['created_at']?.toString(),
      listing: json['listing'] is Map
          ? PromotionListingSummary.fromJson(_map(json['listing']))
          : null,
    );
  }

  bool get isVip => type == 'vip';

  /// Boost = the guaranteed-impressions product (server `type` == `featured`).
  bool get isBoost => type == 'featured';
  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isPending =>
      status == 'pending_payment' || status == 'pending_activation';
}

/// Guaranteed-impressions progress for a boost promotion. The backend counts an
/// impression each time the listing surfaces in the feed/search or its card is
/// opened (owner's own views excluded); `percent` is server-computed 0–100.
class PromotionImpressions {
  final int target;
  final int delivered;
  final int remaining;
  final int percent;

  const PromotionImpressions({
    required this.target,
    required this.delivered,
    required this.remaining,
    required this.percent,
  });

  factory PromotionImpressions.fromJson(Map<String, dynamic> json) {
    return PromotionImpressions(
      target: _int(json['target']) ?? 0,
      delivered: _int(json['delivered']) ?? 0,
      remaining: _int(json['remaining']) ?? 0,
      percent: (_int(json['percent']) ?? 0).clamp(0, 100),
    );
  }
}

class PromotionPayment {
  final String? provider;
  final String? method;
  final String? reference;
  final String status;
  final String? checkoutUrl;
  final bool isMock;

  const PromotionPayment({
    this.provider,
    this.method,
    this.reference,
    required this.status,
    this.checkoutUrl,
    required this.isMock,
  });

  factory PromotionPayment.fromJson(Map<String, dynamic> json) {
    final provider = json['provider']?.toString();
    return PromotionPayment(
      provider: provider,
      method: json['method']?.toString(),
      reference: json['reference']?.toString(),
      status: json['status']?.toString() ?? 'none',
      checkoutUrl: json['checkout_url']?.toString(),
      isMock: _bool(json['mock']) ?? provider == 'mock',
    );
  }
}

class PromotionListingSummary {
  final String id;
  final String? type;
  final String? cityFrom;
  final String? cityTo;

  const PromotionListingSummary({
    required this.id,
    this.type,
    this.cityFrom,
    this.cityTo,
  });

  factory PromotionListingSummary.fromJson(Map<String, dynamic> json) {
    return PromotionListingSummary(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString(),
      cityFrom: json['city_from']?.toString() ?? json['from_city']?.toString(),
      cityTo: json['city_to']?.toString() ?? json['to_city']?.toString(),
    );
  }
}

class PromotionPagination {
  final int currentPage;
  final int lastPage;
  final int total;

  const PromotionPagination({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PromotionPagination.fromJson(Map<String, dynamic> json) {
    return PromotionPagination(
      currentPage: _int(json['current_page'] ?? json['page']) ?? 1,
      lastPage: _int(json['last_page']) ?? 1,
      total: _int(json['total']) ?? 0,
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

List<dynamic> _list(Object? value) {
  return value is List ? value : const [];
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _double(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool? _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

Map<int, double> _priceMap(Object? value) {
  if (value is! Map) return const {};
  final result = <int, double>{};
  for (final entry in value.entries) {
    final duration = _int(entry.key);
    final price = _double(entry.value);
    if (duration != null && price != null) result[duration] = price;
  }
  return result;
}
