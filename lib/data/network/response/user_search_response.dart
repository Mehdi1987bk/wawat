/// A single row of `GET /users/search`. Ids are string public_ids.
class UserSearchItem {
  final String id;
  final String fullName;
  final String? username;
  final String? avatarThumbUrl;
  final bool isVerified;
  final String? tier; // "gold"/... | null → no chip
  final bool isOnline;
  final double? ratingAvg;
  final int ratingCount;
  final int completedShipments;

  const UserSearchItem({
    required this.id,
    required this.fullName,
    this.username,
    this.avatarThumbUrl,
    this.isVerified = false,
    this.tier,
    this.isOnline = false,
    this.ratingAvg,
    this.ratingCount = 0,
    this.completedShipments = 0,
  });

  /// No ratings yet → the card shows "new user" instead of stars.
  bool get isNewUser => ratingCount <= 0;

  factory UserSearchItem.fromJson(Map<String, dynamic> json) {
    final trust = json['trust'] is Map
        ? Map<String, dynamic>.from(json['trust'] as Map)
        : const <String, dynamic>{};

    String? s(Object? v) {
      final t = v?.toString().trim() ?? '';
      return t.isEmpty ? null : t;
    }

    double? d(Object? v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int i(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return UserSearchItem(
      id: s(json['id']) ?? s(json['public_id']) ?? '',
      fullName: s(json['full_name']) ?? s(json['fullname']) ?? s(json['name']) ?? '',
      username: s(json['username']),
      avatarThumbUrl: s(json['avatar_thumb_url']) ?? s(json['avatar_url']),
      isVerified: json['is_verified'] == true,
      tier: s(json['tier']),
      isOnline: json['is_online'] == true,
      ratingAvg: d(trust['rating_avg'] ?? json['rating_avg']),
      ratingCount: i(trust['rating_count'] ?? json['rating_count']),
      completedShipments: i(trust['completed_shipments_count'] ??
          json['completed_shipments_count']),
    );
  }

  /// Compact JSON for the local "recent searches" cache.
  Map<String, dynamic> toRecentJson() => {
        'id': id,
        'full_name': fullName,
        if (username != null) 'username': username,
        if (avatarThumbUrl != null) 'avatar_thumb_url': avatarThumbUrl,
        'is_verified': isVerified,
        if (tier != null) 'tier': tier,
      };
}

/// One page of user-search results plus the pagination meta.
class UserSearchPage {
  final List<UserSearchItem> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const UserSearchPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory UserSearchPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : const <String, dynamic>{};

    int i(Object? v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    final items = data is List
        ? data
            .whereType<Map>()
            .map((e) => UserSearchItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <UserSearchItem>[];

    return UserSearchPage(
      items: items,
      currentPage: i(meta['current_page'], 1),
      lastPage: i(meta['last_page'], 1),
      total: i(meta['total'], items.length),
    );
  }
}
