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
  final List<PromotionTierPricing> tiers;

  const PromotionBoostPricing({
    required this.type,
    required this.label,
    required this.tiers,
  });

  factory PromotionBoostPricing.fromJson(Map<String, dynamic> json) {
    return PromotionBoostPricing(
      type: json['type']?.toString() ?? 'featured',
      label: json['label']?.toString() ?? 'Önə çıxarılan',
      tiers: _list(json['tiers'])
          .whereType<Map>()
          .map((item) =>
              PromotionTierPricing.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class PromotionTierPricing {
  final String tier;
  final String label;
  final int positionLimit;
  final Map<int, double> prices;

  const PromotionTierPricing({
    required this.tier,
    required this.label,
    required this.positionLimit,
    required this.prices,
  });

  factory PromotionTierPricing.fromJson(Map<String, dynamic> json) {
    return PromotionTierPricing(
      tier: json['tier']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      positionLimit: _int(json['position_limit']) ?? 0,
      prices: _priceMap(json['prices']),
    );
  }
}

class PromotionResponse {
  final Promotion data;
  final String? message;

  const PromotionResponse({required this.data, this.message});

  factory PromotionResponse.fromJson(Map<String, dynamic> json) {
    return PromotionResponse(
      data: Promotion.fromJson(_map(json['data'])),
      message: json['message']?.toString(),
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
  final int durationDays;
  final double amount;
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
    required this.durationDays,
    required this.amount,
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

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id']?.toString() ?? '',
      listingId: json['listing_id']?.toString(),
      type: json['type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? '',
      tier: json['tier']?.toString(),
      tierLabel: json['tier_label']?.toString(),
      durationDays: _int(json['duration_days']) ?? 0,
      amount: _double(json['amount']) ?? 0,
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
  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isPending =>
      status == 'pending_payment' || status == 'pending_activation';
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
