import 'package:json_annotation/json_annotation.dart';

part 'chat_response.g.dart';

// ============================================================================
// Chat User Model
// ============================================================================
@JsonSerializable()
class ChatUser {
  final int id;
  final String fullname;
  final String? avatar;
  @JsonKey(name: 'is_verified', defaultValue: false) // ИЗМЕНЕНО: Добавили defaultValue
  final bool isVerified;
  @JsonKey(name: 'last_seen_at')
  final String? lastSeenAt;

  ChatUser({
    required this.id,
    required this.fullname,
    this.avatar,
    this.isVerified = false, // ИЗМЕНЕНО: Добавили дефолтное значение
    this.lastSeenAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);

  String get avatarUrl {
    if (avatar == null || avatar!.isEmpty) return '';
    if (avatar!.startsWith('http')) return avatar!;
    return 'https://wawat.tahirguliyev.com/storage/$avatar';
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

  String getLastSeenText() {
    if (isOnline) return 'онлайн';
    if (lastSeenAt == null) return 'не в сети';

    try {
      final lastSeen = DateTime.parse(lastSeenAt!);
      final now = DateTime.now();
      final difference = now.difference(lastSeen);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} минут назад';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} часов назад';
      } else {
        return '${difference.inDays} дней назад';
      }
    } catch (e) {
      return 'не в сети';
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
  final int size;
  final String mime;

  ChatFile({
    required this.url,
    required this.name,
    required this.size,
    required this.mime,
  });

  factory ChatFile.fromJson(Map<String, dynamic> json) =>
      _$ChatFileFromJson(json);
  Map<String, dynamic> toJson() => _$ChatFileToJson(this);

  String get sizeString {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage => mime.startsWith('image/');
}

// ============================================================================
// Chat Message Model
// ============================================================================
@JsonSerializable()
class ChatMessage {
  final int id;
  final String type; // text, image, file
  final String? body;
  final ChatFile? file;
  final ChatUser? user; // ИЗМЕНЕНО: Сделали опциональным
  @JsonKey(name: 'created_at')
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.type,
    this.body,
    this.file,
    this.user, // ИЗМЕНЕНО: Убрали required
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  DateTime get createdAtDateTime {
    try {
      return DateTime.parse(createdAt);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get timeString {
    try {
      final dateTime = createdAtDateTime;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (messageDate == today.subtract(Duration(days: 1))) {
        return 'Вчера';
      } else {
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

  String get lastMessagePreview {
    if (lastMessage == null) return '';
    if (lastMessage!.type == 'image') return '📷 Фото';
    if (lastMessage!.type == 'file') return '📎 Файл';
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
class ConversationResponse {
  final Conversation data;

  ConversationResponse({required this.data});

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

@JsonSerializable()
class MetaData {
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  @JsonKey(name: 'last_page')
  final int lastPage;
  final String? locale; // ДОБАВЛЕНО: Новое поле

  MetaData({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.locale, // ДОБАВЛЕНО
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
  @JsonKey(name: 'is_pinned')
  final bool isPinned;

  PinResponse({required this.isPinned});

  factory PinResponse.fromJson(Map<String, dynamic> json) =>
      _$PinResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PinResponseToJson(this);
}

@JsonSerializable()
class ArchiveResponse {
  @JsonKey(name: 'is_archived')
  final bool isArchived;

  ArchiveResponse({required this.isArchived});

  factory ArchiveResponse.fromJson(Map<String, dynamic> json) =>
      _$ArchiveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ArchiveResponseToJson(this);
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
  @JsonKey(name: 'blocked_user_id')
  final int? blockedUserId;
  @JsonKey(name: 'unblocked_user_id')
  final int? unblockedUserId;

  BlockResponse({this.blockedUserId, this.unblockedUserId});

  factory BlockResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BlockResponseToJson(this);
}
