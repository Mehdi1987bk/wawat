/// Models for the "Statusum" (tier/level) page. Fully data-driven from
/// `GET /me/tier-status` — nothing is computed client-side. Hand-written
/// tolerant parsing (no codegen). All `label`s arrive already localized.

Map<String, dynamic>? _map(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

List<Map<String, dynamic>> _mapList(Object? v) => v is List
    ? v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
    : const [];

String? _string(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int _int(Object? v, [int fb = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fb;
}

/// Numeric value or null. Booleans (e.g. verification `required:true`) → null.
double? _numOrNull(Object? v) {
  if (v is bool) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '');
}

bool _bool(Object? v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().trim().toLowerCase();
  return s == 'true' || s == '1';
}

class TierStatusResponse {
  final TierStatus data;

  const TierStatusResponse({required this.data});

  factory TierStatusResponse.fromJson(Map<String, dynamic> json) =>
      TierStatusResponse(
        data: TierStatus.fromJson(_map(json['data']) ?? const {}),
      );
}

class TierStatus {
  final TierRef currentTier;
  final TierMetrics metrics;
  final TierRef? nextTier;
  final List<TierRequirement> nextTierRequirements;
  final TierRef? demotedFrom;
  final List<TierLadderItem> allTiers;

  const TierStatus({
    required this.currentTier,
    required this.metrics,
    this.nextTier,
    this.nextTierRequirements = const [],
    this.demotedFrom,
    this.allTiers = const [],
  });

  factory TierStatus.fromJson(Map<String, dynamic> json) {
    final next = _map(json['next_tier']);
    final demoted = _map(json['demoted_from']);
    return TierStatus(
      currentTier: TierRef.fromJson(_map(json['current_tier']) ?? const {}),
      metrics: TierMetrics.fromJson(_map(json['metrics']) ?? const {}),
      nextTier: next == null ? null : TierRef.fromJson(next),
      nextTierRequirements: _mapList(json['next_tier_requirements'])
          .map(TierRequirement.fromJson)
          .toList(growable: false),
      demotedFrom: demoted == null ? null : TierRef.fromJson(demoted),
      allTiers: _mapList(json['all_tiers'])
          .map(TierLadderItem.fromJson)
          .toList(growable: false),
    );
  }

  /// Already at Platin — no next level.
  bool get isMax => nextTier == null;

  /// Level went down (rating dropped).
  bool get isDemoted => demotedFrom != null;

  /// Every requirement met → next delivery / recompute will promote.
  bool get isReadyForPromotion =>
      nextTierRequirements.isNotEmpty &&
      nextTierRequirements.every((r) => r.met);
}

class TierRef {
  final String key; // new|standard|bronze|silver|gold|platinum
  final String label; // localized
  final int? index;

  const TierRef({required this.key, required this.label, this.index});

  factory TierRef.fromJson(Map<String, dynamic> json) => TierRef(
        key: _string(json['key']) ?? '',
        label: _string(json['label']) ?? '',
        index: json['index'] == null ? null : _int(json['index']),
      );
}

class TierMetrics {
  final int completedDeliveries;
  final double? ratingAvg; // null when ratingCount == 0
  final int ratingCount;

  const TierMetrics({
    this.completedDeliveries = 0,
    this.ratingAvg,
    this.ratingCount = 0,
  });

  factory TierMetrics.fromJson(Map<String, dynamic> json) => TierMetrics(
        completedDeliveries: _int(json['completed_deliveries']),
        ratingAvg:
            json['rating_avg'] == null ? null : _numOrNull(json['rating_avg']),
        ratingCount: _int(json['rating_count']),
      );

  bool get hasRating => ratingCount > 0 && ratingAvg != null;
}

class TierRequirement {
  final String type; // deliveries | rating | verification
  final double? requiredNum; // null for verification
  final double? currentNum; // null for verification (or no rating yet)
  final bool met;

  const TierRequirement({
    required this.type,
    this.requiredNum,
    this.currentNum,
    required this.met,
  });

  factory TierRequirement.fromJson(Map<String, dynamic> json) =>
      TierRequirement(
        type: _string(json['type']) ?? '',
        requiredNum: _numOrNull(json['required']),
        currentNum: _numOrNull(json['current']),
        met: _bool(json['met']),
      );

  bool get isDeliveries => type == 'deliveries';
  bool get isRating => type == 'rating';
  bool get isVerification => type == 'verification';

  /// How much is still missing (numeric requirements only).
  double? get remaining {
    if (requiredNum == null || currentNum == null) return null;
    final diff = requiredNum! - currentNum!;
    return diff > 0 ? diff : 0;
  }

  /// 0..1 progress for the bar (numeric requirements only).
  double get progress {
    if (met) return 1;
    if (requiredNum == null || requiredNum == 0 || currentNum == null) return 0;
    final p = currentNum! / requiredNum!;
    return p.clamp(0, 1).toDouble();
  }
}

class TierLadderItem {
  final String key;
  final String label;
  final int minDeliveries;
  final int? maxDeliveries; // null → open-ended ("18+")
  final double minRating;
  final bool requiresVerification;

  const TierLadderItem({
    required this.key,
    required this.label,
    this.minDeliveries = 0,
    this.maxDeliveries,
    this.minRating = 0,
    this.requiresVerification = false,
  });

  factory TierLadderItem.fromJson(Map<String, dynamic> json) => TierLadderItem(
        key: _string(json['key']) ?? '',
        label: _string(json['label']) ?? '',
        minDeliveries: _int(json['min_deliveries']),
        maxDeliveries: json['max_deliveries'] == null
            ? null
            : _int(json['max_deliveries']),
        minRating: _numOrNull(json['min_rating']) ?? 0,
        requiresVerification: _bool(json['requires_verification']),
      );
}
