class PromotionRequest {
  final String type;
  final String? tier;
  final int durationDays;
  final String? promoCode;

  const PromotionRequest({
    required this.type,
    this.tier,
    required this.durationDays,
    this.promoCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (tier != null && tier!.isNotEmpty) 'tier': tier,
      'duration_days': durationDays,
      if (promoCode != null && promoCode!.trim().isNotEmpty)
        'promo_code': promoCode!.trim(),
    };
  }
}

class PromotionExtendRequest {
  final int durationDays;

  const PromotionExtendRequest({required this.durationDays});

  Map<String, dynamic> toJson() => {'duration_days': durationDays};
}

class PromotionPayRequest {
  final String method;
  final String? mockOutcome;

  const PromotionPayRequest({
    required this.method,
    this.mockOutcome,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      if (mockOutcome != null && mockOutcome!.trim().isNotEmpty)
        'mock_outcome': mockOutcome!.trim(),
    };
  }
}
