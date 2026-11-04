class PromotionRequest {
  final String type;

  final String? package;

  final int? durationDays;
  final String? promoCode;

  const PromotionRequest({
    required this.type,
    this.package,
    this.durationDays,
    this.promoCode,
  });

  const PromotionRequest.boost({
    required String package,
    String? promoCode,
  }) : this(type: 'featured', package: package, promoCode: promoCode);

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
  final int? durationDays;

  const PromotionExtendRequest({this.durationDays});

  Map<String, dynamic> toJson() => {
        if (durationDays != null) 'duration_days': durationDays,
      };
}
