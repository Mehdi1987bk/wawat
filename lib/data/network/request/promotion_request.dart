class PromotionRequest {
  final String type;

  /// Boost package code (`large` | `medium` | `small`). Sent ONLY for boost.
  final String? package;

  /// VIP duration in days. Sent ONLY for VIP — boost has no days, and sending
  /// `duration_days` (or `tier`) for boost makes the server reject with 422.
  final int? durationDays;
  final String? promoCode;

  const PromotionRequest({
    required this.type,
    this.package,
    this.durationDays,
    this.promoCode,
  });

  /// Boost order: `{type: featured, package}` — never `tier`/`duration_days`.
  const PromotionRequest.boost({
    required String package,
    String? promoCode,
  }) : this(type: 'featured', package: package, promoCode: promoCode);

  /// VIP order: `{type: vip, duration_days}` — never `package`.
  const PromotionRequest.vip({
    required int durationDays,
    String? promoCode,
  }) : this(type: 'vip', durationDays: durationDays, promoCode: promoCode);

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (package != null && package!.isNotEmpty) 'package': package,
      if (durationDays != null) 'duration_days': durationDays,
      if (promoCode != null && promoCode!.trim().isNotEmpty)
        'promo_code': promoCode!.trim(),
    };
  }
}

class PromotionExtendRequest {
  /// VIP: adds days. Boost: leave null → empty body `{}`, which re-buys the same
  /// package with a fresh guarantee (sending `duration_days` for boost 422s).
  final int? durationDays;

  const PromotionExtendRequest({this.durationDays});

  Map<String, dynamic> toJson() => {
        if (durationDays != null) 'duration_days': durationDays,
      };
}

class PromotionPayRequest {
  final String method;
  final String? mockOutcome;

  /// Promo code applied to this order — either the raw code the user typed or a
  /// wallet promo id (the backend accepts both). Server re-validates and charges
  /// the discounted amount; sent only when non-empty.
  final String? promoCode;

  const PromotionPayRequest({
    required this.method,
    this.mockOutcome,
    this.promoCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      if (mockOutcome != null && mockOutcome!.trim().isNotEmpty)
        'mock_outcome': mockOutcome!.trim(),
      if (promoCode != null && promoCode!.trim().isNotEmpty)
        'promo_code': promoCode!.trim(),
    };
  }
}
