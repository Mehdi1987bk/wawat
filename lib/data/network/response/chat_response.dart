import 'package:buking/data/network/response/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../generated/l10n.dart';

part 'chat_response.g.dart';

// ============================================================================
// Chat User Model
// ============================================================================
@JsonSerializable()
class ChatUser {
  final int id;
  final String fullname;
  final String? avatar;
  @JsonKey(name: 'is_verified', defaultValue: false)
  final bool isVerified;
  @JsonKey(name: 'last_seen_at')
  final String? lastSeenAt;
  @JsonKey(name: 'is_blocked', defaultValue: false)
  final bool? isBlocked;

  ChatUser({
    required this.id,
    required this.fullname,
    this.avatar,
    this.isVerified = false,
    this.lastSeenAt,
    this.isBlocked = false,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChatUserToJson(this);

  String get avatarUrl {
    if (avatar == null || avatar!.isEmpty) return '';
    if (avatar!.startsWith('http')) return avatar!;
    return 'http://62.84.176.158/storage/$avatar';
  }

  bool get isOnline {
    if (lastSeenAt == null) return false;
    try {
      final lastSeen = DateTime.parse(lastSeenAt!);
      final now = DateTime.now();
      return now.difference(lastSeen).inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  String getLastSeenText(BuildContext context) {
    if (isOnline) return S.of(context).fdbdfbweg4g323g;
    if (lastSeenAt == null) return S.of(context).bfdgbebteb443;

    try {
      final lastSeen = DateTime.parse(lastSeenAt!);
      final now = DateTime.now();
      final difference = now.difference(lastSeen);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ' + S.of(context).bfdebr3b3b33;
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ' + S.of(context).bfdeberb3brtbfds;
      } else {
        return '${difference.inDays} ' + S.of(context).bebe233btsdvs;
      }
    } catch (e) {
      return S.of(context).bef43g4g343fbsd;
    }
  }
}

// ============================================================================
// Chat File Model
// ============================================================================
@JsonSerializable()
class ChatFile {
  final String url;
  final String name;
  final String mime;

  ChatFile({
    required this.url,
    required this.name,
    required this.mime,
  });

  factory ChatFile.fromJson(Map<String, dynamic> json) =>
      _$ChatFileFromJson(json);

  Map<String, dynamic> toJson() => _$ChatFileToJson(this);

  bool get isImage => mime.startsWith('image/');
  bool get isPdf => mime == 'application/pdf';
}

// ============================================================================
// Chat Message Model
// ============================================================================
@JsonSerializable()
class ChatMessage {
  final int id;
  final String type;
  final String? body;
  final ChatFile? file;
  final ChatUser? user;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'is_read')
  final bool? isRead;

  ChatMessage({
    required this.id,
    required this.type,
    this.isRead,
    this.body,
    this.file,
    this.user,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  /// Getter для преобразования createdAt в DateTime с локальным временем
  DateTime get createdAtDateTime {
    try {
      return DateTime.parse(createdAt).toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Метод для форматирования времени в UI
  String timeString(BuildContext context) {
    try {
      final dateTime = createdAtDateTime;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        // Сегодня - показываем время
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        // Вчера - показываем локализованный текст
        return S.of(context).bfvdg34g43g34;
      } else {
        // Другие дни - показываем дату
        return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

// ============================================================================
// Conversation Model
// ============================================================================
@JsonSerializable()
class Conversation {
  final int id;
  final ChatUser user;
  @JsonKey(name: 'last_message')
  final ChatMessage? lastMessage;
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  @JsonKey(name: 'is_archived')
  final bool isArchived;

  Conversation({
    required this.id,
    required this.user,
    this.lastMessage,
    required this.unreadCount,
    required this.isPinned,
    required this.isArchived,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  String lastMessagePreview(BuildContext context) {
    if (lastMessage == null) return '';
    if (lastMessage!.type == 'image') return '📷 ' + S.of(context).bfdbfbrewgq34;
    if (lastMessage!.type == 'file') return '📎 ' + S.of(context).bfdb3brwqgevds432;
    return lastMessage!.body ?? '';
  }
}

// ============================================================================
// API Response Wrappers
// ============================================================================
@JsonSerializable()
class ConversationsResponse {
  final List<Conversation> data;
  final MetaData meta;

  ConversationsResponse({
    required this.data,
    required this.meta,
  });

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationsResponseToJson(this);
}

@JsonSerializable()
class MessagesResponse {
  final List<ChatMessage> data;
  final MetaData meta;

  MessagesResponse({
    required this.data,
    required this.meta,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$MessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesResponseToJson(this);
}

@JsonSerializable()
class MessageResponse {
  final ChatMessage data;

  MessageResponse({required this.data});

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

@JsonSerializable()
class MetaData {
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  @JsonKey(name: 'last_page')
  final int lastPage;
  final String? locale;

  MetaData({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.locale,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) =>
      _$MetaDataFromJson(json);

  Map<String, dynamic> toJson() => _$MetaDataToJson(this);
}

// ============================================================================
// Simple Action Responses
// ============================================================================
@JsonSerializable()
class PinResponse {
  final PinData data;

  PinResponse({required this.data});

  factory PinResponse.fromJson(Map<String, dynamic> json) =>
      _$PinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PinResponseToJson(this);

  bool get isPinned => data.isPinned;
}

@JsonSerializable()
class PinData {
  @JsonKey(name: 'is_pinned')
  final bool isPinned;

  PinData({required this.isPinned});

  factory PinData.fromJson(Map<String, dynamic> json) =>
      _$PinDataFromJson(json);

  Map<String, dynamic> toJson() => _$PinDataToJson(this);
}

@JsonSerializable()
class ArchiveResponse {
  final ArchiveData data;

  ArchiveResponse({required this.data});

  factory ArchiveResponse.fromJson(Map<String, dynamic> json) =>
      _$ArchiveResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArchiveResponseToJson(this);

  bool get isArchived => data.isArchived;
}

@JsonSerializable()
class ArchiveData {
  @JsonKey(name: 'is_archived')
  final bool isArchived;

  ArchiveData({required this.isArchived});

  factory ArchiveData.fromJson(Map<String, dynamic> json) =>
      _$ArchiveDataFromJson(json);

  Map<String, dynamic> toJson() => _$ArchiveDataToJson(this);
}

@JsonSerializable()
class DeleteResponse {
  final String? message;

  DeleteResponse({this.message});

  factory DeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteResponseToJson(this);
}

@JsonSerializable()
class BlockResponse {
  final BlockData data;

  BlockResponse({required this.data});

  factory BlockResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BlockResponseToJson(this);

  int? get blockedUserId => data.blockedUserId;

  int? get unblockedUserId => data.unblockedUserId;
}

@JsonSerializable()
class BlockData {
  @JsonKey(name: 'blocked_user_id')
  final int? blockedUserId;
  @JsonKey(name: 'unblocked_user_id')
  final int? unblockedUserId;

  BlockData({this.blockedUserId, this.unblockedUserId});

  factory BlockData.fromJson(Map<String, dynamic> json) =>
      _$BlockDataFromJson(json);

  Map<String, dynamic> toJson() => _$BlockDataToJson(this);
}

@JsonSerializable()
class ConversationResponse {
  final ConversationData? data;
  final Meta? meta;
  final String? message;

  ConversationResponse({
    this.data,
    this.meta,
    this.message,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

@JsonSerializable()
class ConversationData {
  final int? id;
  final User? user;
  @JsonKey(name: 'is_pinned')
  final bool? isPinned;
  @JsonKey(name: 'is_archived')
  final bool? isArchived;

  ConversationData({
    this.id,
    this.user,
    this.isPinned,
    this.isArchived,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) =>
      _$ConversationDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDataToJson(this);
}

@JsonSerializable()
class Meta {
  final String? locale;

  Meta({
    this.locale,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}