class NotificationResponse {
  final List<NotificationItem> data;
  final NotificationMeta? meta;

  const NotificationResponse({
    required this.data,
    this.meta,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data: (json['data'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => NotificationItem.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      meta: json['meta'] is Map
          ? NotificationMeta.fromJson(
              Map<String, dynamic>.from(json['meta'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
        if (meta != null) 'meta': meta!.toJson(),
      };
}

class NotificationMeta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  const NotificationMeta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      currentPage: _intValue(json['current_page']),
      lastPage: _intValue(json['last_page']),
      perPage: _intValue(json['per_page']),
      total: _intValue(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (currentPage != null) 'current_page': currentPage,
        if (lastPage != null) 'last_page': lastPage,
        if (perPage != null) 'per_page': perPage,
        if (total != null) 'total': total,
      };
}

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String? body;
  final bool isInteractive;
  final NotificationData data;

  /// Unified navigation object — the single source of truth for where a tap
  /// on this notification should go (same shape as the push payload). Drive
  /// navigation from [target], never from [type] or [data].
  final NotificationTarget target;
  final String? readAt;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.isInteractive,
    required this.data,
    this.target = const NotificationTarget(),
    this.readAt,
    required this.createdAt,
  });

  bool get isUnread => readAt == null || readAt!.isEmpty;

  NotificationItem copyWith({
    String? readAt,
    bool clearReadAt = false,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      isInteractive: isInteractive,
      data: data,
      target: target,
      readAt: clearReadAt ? null : readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      isInteractive: json['is_interactive'] == true ||
          json['is_interactive']?.toString() == 'true',
      data: json['data'] is Map
          ? NotificationData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : const NotificationData(),
      target: json['target'] is Map
          ? NotificationTarget.fromJson(
              Map<String, dynamic>.from(json['target'] as Map),
            )
          : const NotificationTarget(),
      readAt: json['read_at']?.toString() ??
          (json['is_read'] == true ? DateTime.now().toIso8601String() : null),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'is_interactive': isInteractive,
        'data': data.toJson(),
        'target': target.toJson(),
        'read_at': readAt,
        'created_at': createdAt,
      };
}

/// Unified navigation descriptor present on every notification (in-app + push).
/// [type] is one of the 14 target kinds; [id] is a public_id/username or null
/// (null ⇒ open a screen, not an entity); [params] holds secondary navigation
/// (e.g. conversation_id, saved_search_id).
class NotificationTarget {
  final String type;
  final String? id;
  final Map<String, dynamic> params;

  const NotificationTarget({
    this.type = 'none',
    this.id,
    this.params = const {},
  });

  factory NotificationTarget.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    return NotificationTarget(
      type: json['type']?.toString() ?? 'none',
      id: (id == null || id.isEmpty) ? null : id,
      params: json['params'] is Map
          ? Map<String, dynamic>.from(json['params'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (id != null) 'id': id,
        if (params.isNotEmpty) 'params': params,
      };
}

class NotificationData {
  final String? shipmentId;
  final String? conversationId;
  final String? listingId;
  final String? reviewId;
  final String? userId;
  final String? followerId;
  final String? savedSearchId;
  final Map<String, dynamic> raw;

  const NotificationData({
    this.shipmentId,
    this.conversationId,
    this.listingId,
    this.reviewId,
    this.userId,
    this.followerId,
    this.savedSearchId,
    this.raw = const {},
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      shipmentId: json['shipment_id']?.toString(),
      conversationId: json['conversation_id']?.toString(),
      listingId: json['listing_id']?.toString(),
      reviewId: json['review_id']?.toString(),
      userId: json['user_id']?.toString(),
      followerId: json['follower_id']?.toString(),
      savedSearchId: json['saved_search_id']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw.isNotEmpty
      ? raw
      : {
          if (shipmentId != null) 'shipment_id': shipmentId,
          if (conversationId != null) 'conversation_id': conversationId,
          if (listingId != null) 'listing_id': listingId,
          if (reviewId != null) 'review_id': reviewId,
          if (userId != null) 'user_id': userId,
          if (followerId != null) 'follower_id': followerId,
          if (savedSearchId != null) 'saved_search_id': savedSearchId,
        };
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
