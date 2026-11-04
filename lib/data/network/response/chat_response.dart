import 'package:flutter/material.dart';

import 'package:buking/services/localization_service.dart';

enum ChatMessageDeliveryStatus {
  sending,
  sent,
  failed,
}

class ChatUser {
  final int id;
  final String? publicId;
  final String? username;
  final String fullname;

  final String? avatarFull;

  final String? avatarThumb;
  final bool isVerified;
  final String? lastActiveAt;
  final bool isBlocked;

  final bool? isOnlineRaw;

  const ChatUser({
    required this.id,
    this.publicId,
    this.username,
    required this.fullname,
    this.avatarFull,
    this.avatarThumb,
    this.isVerified = false,
    this.lastActiveAt,
    this.isBlocked = false,
    this.isOnlineRaw,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final name = _string(json['fullname']) ??
        _string(json['name']) ??
        _string(json['username']) ??
        '';
    return ChatUser(
      id: _int(rawId) ?? _int(json['numeric_id']) ?? 0,
      publicId: _string(json['public_id']) ??
          (_int(rawId) == null ? _string(rawId) : null),
      username: _string(json['username']),
      fullname: name,
      avatarFull: _string(json['avatar_url']),
      avatarThumb: _string(json['avatar_thumb_url']),
      isVerified: _bool(json['is_verified']),
      lastActiveAt:
          _string(json['last_active_at']) ?? _string(json['last_seen_at']),
      isBlocked: _bool(json['is_blocked']),
      isOnlineRaw: json['is_online'] == null ? null : _bool(json['is_online']),
    );
  }

  Object get apiId => publicId ?? id;

  bool get hasApiId =>
      (publicId != null && publicId!.trim().isNotEmpty) || id > 0;

  static String _resolveAvatar(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '';
    if (v.startsWith('http')) return v;
    return 'https://api.wawatair.com/storage/$v';
  }

  String get avatarUrl => _resolveAvatar(avatarFull);

  String get avatarThumbUrl {
    final thumb = _resolveAvatar(avatarThumb);
    return thumb.isNotEmpty ? thumb : avatarUrl;
  }

  String get initials {
    final parts = fullname.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  DateTime? get _lastActive =>
      lastActiveAt == null ? null : DateTime.tryParse(lastActiveAt!)?.toLocal();

  bool get isOnline {
    final lastSeen = _lastActive;
    if (lastSeen != null) {
      return DateTime.now().difference(lastSeen).inMinutes < 3;
    }
    return isOnlineRaw ?? false;
  }

  bool get hasPresence => isOnline || _lastActive != null;

  String getLastSeenText(BuildContext context) {
    if (isOnline) return 'onlayn';
    final lastSeen = _lastActive;
    if (lastSeen == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 1) {
      return tr('chat.presence.just_now', 'indicə aktiv idi');
    }
    if (diff.inMinutes < 60) {
      return tr('chat.presence.minutes_ago', '{count} dəq əvvəl aktiv',
          {'count': '${diff.inMinutes}'});
    }

    String two(int v) => v.toString().padLeft(2, '0');
    final time = '${two(lastSeen.hour)}:${two(lastSeen.minute)}';
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);
    final dayGap = today.difference(thatDay).inDays;
    if (dayGap == 0) {
      return tr('chat.presence.today_at', 'bu gün {time}', {'time': time});
    }
    if (dayGap == 1) {
      return tr('chat.presence.yesterday_at', 'dünən {time}', {'time': time});
    }
    return '${two(lastSeen.day)}.${two(lastSeen.month)}.${lastSeen.year}';
  }
}

class ChatImage {
  final String url;
  final String? mimeType;
  final int? size;

  const ChatImage({required this.url, this.mimeType, this.size});

  factory ChatImage.fromJson(Map<String, dynamic> json) {
    return ChatImage(
      url: _string(json['url']) ?? '',
      mimeType: _string(json['mime_type']) ?? _string(json['mime']),
      size: _int(json['size']),
    );
  }
}

class ChatFile {
  final String url;
  final String name;
  final String mime;

  const ChatFile({
    required this.url,
    required this.name,
    required this.mime,
  });

  factory ChatFile.fromJson(Map<String, dynamic> json) {
    final url = _string(json['url']) ?? '';
    return ChatFile(
      url: url,
      name: _string(json['name']) ?? url.split('/').last,
      mime: _string(json['mime']) ?? _string(json['mime_type']) ?? '',
    );
  }

  bool get isImage => mime.startsWith('image/');
  bool get isPdf => mime == 'application/pdf';
}

class DealAction {
  final String key;

  final String label;

  final String style;

  final String endpoint;

  final bool needsInput;

  final bool confirm;

  const DealAction({
    required this.key,
    required this.label,
    required this.endpoint,
    this.style = 'secondary',
    this.needsInput = false,
    this.confirm = false,
  });

  bool get isPrimary => style == 'primary';
  bool get isDanger => style == 'danger';

  factory DealAction.fromJson(Map<String, dynamic> json) {
    return DealAction(
      key: _string(json['key'])?.trim() ?? '',
      label: _string(json['label'])?.trim() ?? '',
      style: _string(json['style'])?.trim() ?? 'secondary',
      endpoint: _string(json['endpoint'])?.trim() ?? '',
      needsInput: _bool(json['needs_input']),
      confirm: _bool(json['confirm']),
    );
  }

  static List<DealAction> listFromJson(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => DealAction.fromJson(_map(item) ?? const {}))
        .where((action) => action.label.isNotEmpty && action.endpoint.isNotEmpty)
        .toList();
  }
}

class ChatCard {
  final String type;
  final String label;

  final bool isInteractive;
  final String? shipmentId;

  final String? shipmentStatus;

  final List<DealAction> actions;
  final Map<String, dynamic> payload;

  const ChatCard({
    required this.type,
    required this.label,
    required this.isInteractive,
    this.shipmentId,
    this.shipmentStatus,
    this.actions = const [],
    required this.payload,
  });

  factory ChatCard.fromJson(Map<String, dynamic> json) {
    return ChatCard(
      type: _string(json['type']) ?? '',
      label: _string(json['label']) ?? '',
      isInteractive: _bool(json['is_interactive']),
      shipmentId: _string(json['shipment_id']),
      shipmentStatus: _string(json['shipment_status']),
      actions: DealAction.listFromJson(json['actions']),
      payload: _map(json['payload']) ?? const {},
    );
  }

  ChatCard withoutActions() {
    if (actions.isEmpty) return this;
    return ChatCard(
      type: type,
      label: label,
      isInteractive: isInteractive,
      shipmentId: shipmentId,
      shipmentStatus: shipmentStatus,
      payload: payload,
    );
  }
}

class ChatReplyRef {
  final String messageId;

  final String authorName;
  final bool authorIsMine;

  final String type;
  final String? body;
  final String? imageUrl;

  const ChatReplyRef({
    required this.messageId,
    required this.authorName,
    required this.authorIsMine,
    required this.type,
    this.body,
    this.imageUrl,
  });

  bool get isImage => type == 'image' && (imageUrl?.isNotEmpty ?? false);

  String get previewText {
    if (type == 'image') return tr('chat.attach.image', 'Şəkil');
    if (type == 'system_card') return body ?? tr('deals.status_deal', 'Sövdələşmə');
    return body ?? '';
  }

  factory ChatReplyRef.fromMessage(
    ChatMessage message, {
    required bool quotedIsMine,
    String? peerName,
  }) {
    final img = message.image?.url ?? message.file?.url;
    final name = quotedIsMine
        ? tr('chat.preview.you', 'Sən')
        : (message.user?.fullname.trim().isNotEmpty ?? false
            ? message.user!.fullname
            : (peerName ?? ''));
    return ChatReplyRef(
      messageId: message.id,
      authorName: name,
      authorIsMine: quotedIsMine,
      type: message.type,
      body: message.type == 'system_card' ? message.card?.label : message.body,
      imageUrl: (img?.isNotEmpty ?? false) ? img : null,
    );
  }

  factory ChatReplyRef.fromJson(Map<String, dynamic> json) {
    final senderJson = _map(json['sender']) ?? _map(json['user']);
    final imageJson = _map(json['image']);
    return ChatReplyRef(
      messageId: _string(json['id']) ?? '',
      authorName: _string(senderJson?['fullname']) ??
          _string(senderJson?['name']) ??
          _string(senderJson?['username']) ??
          '',
      authorIsMine: _bool(json['is_mine']),
      type: _string(json['type']) ?? 'text',
      body: _string(json['body']),
      imageUrl: imageJson == null ? null : _string(imageJson['url']),
    );
  }
}

class ChatMessage {
  final String id;
  final String type;
  final String? body;
  final ChatFile? file;
  final ChatImage? image;
  final ChatUser? user;
  final ChatCard? card;
  final String createdAt;
  final String? editedAt;

  final bool isDeleted;
  final String? deletedAt;
  final bool isMine;
  final bool? isRead;
  final ChatReplyRef? replyTo;

  final String? readAt;
  final ChatMessageDeliveryStatus deliveryStatus;
  final String? localImagePath;

  const ChatMessage({
    required this.id,
    required this.type,
    this.body,
    this.file,
    this.image,
    this.user,
    this.card,
    required this.createdAt,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.isMine = false,
    this.isRead,
    this.replyTo,
    this.readAt,
    this.deliveryStatus = ChatMessageDeliveryStatus.sent,
    this.localImagePath,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final senderJson = _map(json['sender']) ?? _map(json['user']);
    final imageJson = _map(json['image']);
    final fileJson = _map(json['file']);
    final cardJson = _map(json['card']);
    final replyJson = _map(json['reply_to']) ?? _map(json['reply_to_message']);
    return ChatMessage(
      id: _string(json['id']) ?? '${json['id'] ?? ''}',
      type: _string(json['type']) ?? 'text',
      body: _string(json['body']),
      file: fileJson == null ? null : ChatFile.fromJson(fileJson),
      image: imageJson == null ? null : ChatImage.fromJson(imageJson),
      user: senderJson == null ? null : ChatUser.fromJson(senderJson),
      card: cardJson == null ? null : ChatCard.fromJson(cardJson),
      createdAt:
          _string(json['created_at']) ?? DateTime.now().toIso8601String(),
      editedAt: _string(json['edited_at']),
      isDeleted: _bool(json['is_deleted']),
      deletedAt: _string(json['deleted_at']),
      isMine: _bool(json['is_mine']),
      isRead: json.containsKey('is_read') ? _bool(json['is_read']) : null,
      replyTo: replyJson == null ? null : ChatReplyRef.fromJson(replyJson),
      readAt: _string(json['read_at']),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? type,
    String? body,
    ChatFile? file,
    ChatImage? image,
    ChatUser? user,
    ChatCard? card,
    String? createdAt,
    String? editedAt,
    bool? isDeleted,
    String? deletedAt,
    bool? isMine,
    bool? isRead,
    ChatReplyRef? replyTo,
    String? readAt,
    ChatMessageDeliveryStatus? deliveryStatus,
    String? localImagePath,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      body: body ?? this.body,
      file: file ?? this.file,
      image: image ?? this.image,
      user: user ?? this.user,
      card: card ?? this.card,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isMine: isMine ?? this.isMine,
      isRead: isRead ?? this.isRead,
      replyTo: replyTo ?? this.replyTo,
      readAt: readAt ?? this.readAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }

  ChatMessage asDeleted({String? deletedAt}) {
    return ChatMessage(
      id: id,
      type: type,
      createdAt: createdAt,
      isDeleted: true,
      deletedAt: deletedAt ?? this.deletedAt,
      isMine: isMine,
      isRead: isRead,
      readAt: readAt,
    );
  }

  DateTime get createdAtDateTime {
    return DateTime.tryParse(createdAt)?.toLocal() ?? DateTime.now();
  }

  String timeString(BuildContext context) {
    final dateTime = createdAtDateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    if (messageDate == today.subtract(const Duration(days: 1))) {
      return tr('common.yesterday', 'Dünən');
    }
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }
}

class Conversation {
  final String id;
  final ChatUser user;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isArchived;
  final bool isBlocked;
  final bool isBlockedByOther;
  final String? lastMessageAt;

  const Conversation({
    required this.id,
    required this.user,
    this.lastMessage,
    required this.unreadCount,
    required this.isPinned,
    required this.isArchived,
    this.isBlocked = false,
    this.isBlockedByOther = false,
    this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final userJson = _map(json['other_user']) ?? _map(json['user']) ?? {};
    final lastMessageJson = _map(json['last_message']);
    return Conversation(
      id: _string(json['id']) ?? '${json['id'] ?? ''}',
      user: ChatUser.fromJson(userJson),
      lastMessage: lastMessageJson == null
          ? null
          : ChatMessage.fromJson(lastMessageJson),
      unreadCount: _int(json['unread_count']) ?? 0,
      isPinned: _bool(json['is_pinned']),
      isArchived: _bool(json['is_archived']),
      isBlocked: _bool(json['is_blocked']),
      isBlockedByOther: _bool(json['is_blocked_by_other']),
      lastMessageAt: _string(json['last_message_at']),
    );
  }

  bool get lastMessageIsDeleted => lastMessage?.isDeleted == true;

  String lastMessagePreview(BuildContext context) {
    if (lastMessage == null) return '';
    if (lastMessage!.isDeleted) return '';
    if (lastMessage!.type == 'image') return tr('chat.attach.image', 'Şəkil');
    if (lastMessage!.type == 'system_card') {
      return lastMessage!.card?.label ?? tr('deals.proposal', 'Təklif');
    }
    return lastMessage!.body ?? '';
  }

  DateTime? get sortTime {
    final raw = lastMessageAt ?? lastMessage?.createdAt;
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }
}

class ConversationsResponse {
  final List<Conversation> data;
  final MetaData meta;

  const ConversationsResponse({required this.data, required this.meta});

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList();
    return ConversationsResponse(
      data: list,
      meta: MetaData.fromJson(_map(json['meta']) ?? const {}),
    );
  }
}

class MessagesResponse {
  final List<ChatMessage> data;
  final MetaData meta;

  const MessagesResponse({required this.data, required this.meta});

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .toList();
    return MessagesResponse(
      data: list,
      meta: MetaData.fromJson(_map(json['meta']) ?? const {}),
    );
  }
}

class MessageResponse {
  final ChatMessage data;

  const MessageResponse({required this.data});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
        data: ChatMessage.fromJson(_map(json['data']) ?? {}));
  }
}

class ConversationResponse {
  final Conversation? data;
  final MetaData? meta;
  final String? message;

  const ConversationResponse({this.data, this.meta, this.message});

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = _map(json['data']);
    return ConversationResponse(
      data: dataJson == null ? null : Conversation.fromJson(dataJson),
      meta: _map(json['meta']) == null
          ? null
          : MetaData.fromJson(_map(json['meta'])!),
      message: _string(json['message']),
    );
  }
}

class MetaData {
  final int page;
  final int perPage;
  final int total;
  final int lastPage;
  final String? locale;

  final DateTime? peerLastReadAt;

  final Conversation? conversation;

  const MetaData({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.locale,
    this.peerLastReadAt,
    this.conversation,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    final currentPage = _int(json['current_page']) ?? _int(json['page']) ?? 1;
    final perPage = _int(json['per_page']) ?? 20;
    final total = _int(json['total']) ?? 0;
    final peerRaw = _string(json['peer_last_read_at']);
    final convJson = _map(json['conversation']);
    return MetaData(
      page: currentPage,
      perPage: perPage,
      total: total,
      lastPage: _int(json['last_page']) ?? currentPage,
      locale: _string(json['locale']),
      peerLastReadAt: peerRaw == null ? null : DateTime.tryParse(peerRaw),
      conversation: convJson == null ? null : Conversation.fromJson(convJson),
    );
  }
}

class ShipmentResponse {
  final ShipmentData? data;

  const ShipmentResponse({this.data});

  factory ShipmentResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = _map(json['data']);
    return ShipmentResponse(
      data: dataJson == null ? null : ShipmentData.fromJson(dataJson),
    );
  }
}

class ShipmentData {
  final String id;
  final String status;
  final String statusLabel;
  final bool isAwaitingMe;

  final List<String> availableActions;

  final List<DealAction>? actions;
  final String? packageTypeCode;
  final double? weightKg;
  final double? priceTotal;
  final String? note;
  final String? source;
  final String? listingType;
  final String? myRole;
  final String? conversationId;
  final String? cityFrom;
  final String? cityTo;
  final int? cityFromId;
  final int? cityToId;
  final String? travelDate;
  final String? dateFrom;
  final String? dateTo;
  final ShipmentParty? sender;
  final ShipmentParty? carrier;
  final String? cancelReason;
  final String? cancelReasonLabel;
  final String? cancelReasonNote;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String? completedAt;
  final String? autoCompleteAt;
  final String? expiresAt;
  final String? createdAt;

  const ShipmentData({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.isAwaitingMe,
    required this.availableActions,
    this.actions,
    this.packageTypeCode,
    this.weightKg,
    this.priceTotal,
    this.note,
    this.source,
    this.listingType,
    this.myRole,
    this.conversationId,
    this.cityFrom,
    this.cityTo,
    this.cityFromId,
    this.cityToId,
    this.travelDate,
    this.dateFrom,
    this.dateTo,
    this.sender,
    this.carrier,
    this.cancelReason,
    this.cancelReasonLabel,
    this.cancelReasonNote,
    this.pickedUpAt,
    this.deliveredAt,
    this.completedAt,
    this.autoCompleteAt,
    this.expiresAt,
    this.createdAt,
  });

  factory ShipmentData.fromJson(Map<String, dynamic> json) {
    final senderJson = _map(json['sender']);
    final carrierJson = _map(json['carrier']);
    return ShipmentData(
      id: _string(json['id']) ?? '',
      status: _string(json['status']) ?? '',
      statusLabel: _string(json['status_label']) ?? '',
      isAwaitingMe: _bool(json['is_awaiting_me']),
      availableActions:
          (json['available_actions'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(),
      actions: json['actions'] is List
          ? DealAction.listFromJson(json['actions'])
          : null,
      packageTypeCode: _string(json['package_type_code']),
      weightKg: _double(json['weight_kg']),
      priceTotal: _double(json['price_total']),
      note: _string(json['note']),
      source: _string(json['source']),
      listingType: _string(json['listing_type']),
      myRole: _string(json['my_role']),
      conversationId: _string(json['conversation_id']),
      cityFrom: _string(json['city_from']),
      cityTo: _string(json['city_to']),
      cityFromId: _int(json['city_from_id']),
      cityToId: _int(json['city_to_id']),
      travelDate: _string(json['travel_date']),
      dateFrom: _string(json['date_from']),
      dateTo: _string(json['date_to']),
      sender: senderJson == null ? null : ShipmentParty.fromJson(senderJson),
      carrier: carrierJson == null ? null : ShipmentParty.fromJson(carrierJson),
      cancelReason: _string(json['cancel_reason']),
      cancelReasonLabel: _string(json['cancel_reason_label']),
      cancelReasonNote: _string(json['cancel_reason_note']),
      pickedUpAt: _string(json['picked_up_at']),
      deliveredAt: _string(json['delivered_at']),
      completedAt: _string(json['completed_at']),
      autoCompleteAt: _string(json['auto_complete_at']),
      expiresAt: _string(json['expires_at']),
      createdAt: _string(json['created_at']),
    );
  }

  bool get isSender => myRole == 'sender';
  bool get isCarrier => myRole == 'carrier';

  String get route => [cityFrom, cityTo]
      .where((city) => city != null && city.isNotEmpty)
      .join(' → ');
}

class ShipmentParty {
  final String? id;
  final String? username;
  final String fullname;

  final String? avatarFull;
  final String? avatarThumb;
  final bool isVerified;

  const ShipmentParty({
    this.id,
    this.username,
    required this.fullname,
    this.avatarFull,
    this.avatarThumb,
    this.isVerified = false,
  });

  factory ShipmentParty.fromJson(Map<String, dynamic> json) {
    return ShipmentParty(
      id: json['id']?.toString(),
      username: _string(json['username']),
      fullname: _string(json['fullname']) ?? _string(json['full_name']) ?? '',
      avatarFull: _string(json['avatar_url']),
      avatarThumb: _string(json['avatar_thumb_url']),
      isVerified: _bool(json['is_verified']),
    );
  }

  String? get profileId {
    final resolved = (id ?? username ?? '').trim();
    return resolved.isEmpty ? null : resolved;
  }

  String get avatarUrl => ChatUser._resolveAvatar(avatarFull);

  String get avatarThumbUrl {
    final thumb = ChatUser._resolveAvatar(avatarThumb);
    return thumb.isNotEmpty ? thumb : avatarUrl;
  }
}

class ShipmentCounts {
  final int active;
  final int history;
  final int awaitingMe;

  const ShipmentCounts({
    this.active = 0,
    this.history = 0,
    this.awaitingMe = 0,
  });

  factory ShipmentCounts.fromJson(Map<String, dynamic> json) {
    return ShipmentCounts(
      active: _int(json['active']) ?? 0,
      history: _int(json['history']) ?? 0,
      awaitingMe: _int(json['awaiting_me']) ?? 0,
    );
  }
}

class ShipmentsPage {
  final List<ShipmentData> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final ShipmentCounts counts;

  const ShipmentsPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.counts,
  });

  factory ShipmentsPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    final meta = _map(json['meta']) ?? const {};
    return ShipmentsPage(
      data: list is List
          ? list
              .whereType<Map>()
              .map((item) =>
                  ShipmentData.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      currentPage: _int(meta['current_page']) ?? 1,
      lastPage: _int(meta['last_page']) ?? 1,
      total: _int(meta['total']) ?? 0,
      counts: ShipmentCounts.fromJson(_map(meta['counts']) ?? const {}),
    );
  }
}

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  return null;
}

String? _string(dynamic value) => value == null ? null : value.toString();

int? _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _double(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}
