// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatUser _$ChatUserFromJson(Map<String, dynamic> json) => ChatUser(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      avatar: json['avatar'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      lastSeenAt: json['last_seen_at'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
    );

Map<String, dynamic> _$ChatUserToJson(ChatUser instance) => <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'avatar': instance.avatar,
      'is_verified': instance.isVerified,
      'last_seen_at': instance.lastSeenAt,
      'is_blocked': instance.isBlocked,
    };

ChatFile _$ChatFileFromJson(Map<String, dynamic> json) => ChatFile(
      url: json['url'] as String,
      name: json['name'] as String,
      mime: json['mime'] as String,
    );

Map<String, dynamic> _$ChatFileToJson(ChatFile instance) => <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'mime': instance.mime,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as int,
      type: json['type'] as String,
      isRead: json['is_read'] as bool?,
      body: json['body'] as String?,
      file: json['file'] == null
          ? null
          : ChatFile.fromJson(json['file'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : ChatUser.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'body': instance.body,
      'file': instance.file,
      'user': instance.user,
      'created_at': instance.createdAt,
      'is_read': instance.isRead,
    };

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      id: json['id'] as int,
      user: ChatUser.fromJson(json['user'] as Map<String, dynamic>),
      lastMessage: json['last_message'] == null
          ? null
          : ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>),
      unreadCount: json['unread_count'] as int,
      isPinned: json['is_pinned'] as bool,
      isArchived: json['is_archived'] as bool,
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'last_message': instance.lastMessage,
      'unread_count': instance.unreadCount,
      'is_pinned': instance.isPinned,
      'is_archived': instance.isArchived,
    };

ConversationsResponse _$ConversationsResponseFromJson(
        Map<String, dynamic> json) =>
    ConversationsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: MetaData.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConversationsResponseToJson(
        ConversationsResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

MessagesResponse _$MessagesResponseFromJson(Map<String, dynamic> json) =>
    MessagesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: MetaData.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessagesResponseToJson(MessagesResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      data: ChatMessage.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

MetaData _$MetaDataFromJson(Map<String, dynamic> json) => MetaData(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$MetaDataToJson(MetaData instance) => <String, dynamic>{
      'page': instance.page,
      'per_page': instance.perPage,
      'total': instance.total,
      'last_page': instance.lastPage,
      'locale': instance.locale,
    };

PinResponse _$PinResponseFromJson(Map<String, dynamic> json) => PinResponse(
      data: PinData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PinResponseToJson(PinResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

PinData _$PinDataFromJson(Map<String, dynamic> json) => PinData(
      isPinned: json['is_pinned'] as bool,
    );

Map<String, dynamic> _$PinDataToJson(PinData instance) => <String, dynamic>{
      'is_pinned': instance.isPinned,
    };

ArchiveResponse _$ArchiveResponseFromJson(Map<String, dynamic> json) =>
    ArchiveResponse(
      data: ArchiveData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArchiveResponseToJson(ArchiveResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

ArchiveData _$ArchiveDataFromJson(Map<String, dynamic> json) => ArchiveData(
      isArchived: json['is_archived'] as bool,
    );

Map<String, dynamic> _$ArchiveDataToJson(ArchiveData instance) =>
    <String, dynamic>{
      'is_archived': instance.isArchived,
    };

DeleteResponse _$DeleteResponseFromJson(Map<String, dynamic> json) =>
    DeleteResponse(
      message: json['message'] as String?,
    );

Map<String, dynamic> _$DeleteResponseToJson(DeleteResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

BlockResponse _$BlockResponseFromJson(Map<String, dynamic> json) =>
    BlockResponse(
      data: BlockData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BlockResponseToJson(BlockResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

BlockData _$BlockDataFromJson(Map<String, dynamic> json) => BlockData(
      blockedUserId: json['blocked_user_id'] as int?,
      unblockedUserId: json['unblocked_user_id'] as int?,
    );

Map<String, dynamic> _$BlockDataToJson(BlockData instance) => <String, dynamic>{
      'blocked_user_id': instance.blockedUserId,
      'unblocked_user_id': instance.unblockedUserId,
    };

ConversationResponse _$ConversationResponseFromJson(
        Map<String, dynamic> json) =>
    ConversationResponse(
      data: json['data'] == null
          ? null
          : ConversationData.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ConversationResponseToJson(
        ConversationResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
      'message': instance.message,
    };

ConversationData _$ConversationDataFromJson(Map<String, dynamic> json) =>
    ConversationData(
      id: json['id'] as int?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      isPinned: json['is_pinned'] as bool?,
      isArchived: json['is_archived'] as bool?,
    );

Map<String, dynamic> _$ConversationDataToJson(ConversationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'is_pinned': instance.isPinned,
      'is_archived': instance.isArchived,
    };

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
      'locale': instance.locale,
    };
