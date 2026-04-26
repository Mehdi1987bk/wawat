import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../response/chat_response.dart';
import '../response/target_user_request.dart';

part 'chat_api.g.dart';

@RestApi(baseUrl: 'https://wawatair.com/api/v1')
abstract class ChatApi {
  factory ChatApi(Dio dio, {String baseUrl}) = _ChatApi;

  // Start chat
  @POST('/chats/start')
  Future<ConversationResponse> startChat(@Body() Map<String, dynamic> body);

  // Get conversations
  @GET('/chats')
  Future<ConversationsResponse> getConversations(
    @Query('per_page') int perPage,
    @Query('page') int page,
  );

  // Get archived conversations
  @GET('/chats/archived')
  Future<ConversationsResponse> getArchivedConversations(
    @Query('per_page') int perPage,
    @Query('page') int page,
  );

  // Get messages
  @GET('/chats/{conversation_id}/messages')
  Future<MessagesResponse> getMessages(
    @Path('conversation_id') int conversationId,
    @Query('per_page') int perPage,
    @Query('page') int page,
  );

  // Send text message only
  @POST('/chats/{conversation_id}/messages')
  Future<MessageResponse> sendTextMessage(
    @Path('conversation_id') int conversationId,
    @Body() Map<String, dynamic> body,
  );

  // Send message with file
  @POST('/chats/{conversation_id}/messages')
  @MultiPart()
  Future<MessageResponse> sendMessageWithFile(
    @Path('conversation_id') int conversationId,
    @Part(name: 'file') File file,
    @Part(name: 'body') String? body,
  );

  // Pin conversation
  @POST('/chats/{conversation_id}/pin')
  Future<PinResponse> pinConversation(
    @Path('conversation_id') int conversationId,
  );

  // Unpin conversation
  @POST('/chats/{conversation_id}/unpin')
  Future<PinResponse> unpinConversation(
    @Path('conversation_id') int conversationId,
  );

  // Archive conversation
  @POST('/chats/{conversation_id}/archive')
  Future<ArchiveResponse> archiveConversation(
    @Path('conversation_id') int conversationId,
  );

  // Unarchive conversation
  @POST('/chats/{conversation_id}/unarchive')
  Future<ArchiveResponse> unarchiveConversation(
    @Path('conversation_id') int conversationId,
  );

  // Delete conversation
  @DELETE('/chats/{conversation_id}')
  Future<DeleteResponse> deleteConversation(
    @Path('conversation_id') int conversationId,
  );

  // Block user
  @POST('/chats/block')
  Future<BlockResponse> blockUser(@Body() Map<String, dynamic> body);

  // Unblock user
  @POST('/chats/unblock')
  Future<BlockResponse> unblockUser(@Body() Map<String, dynamic> body);

  // Unblock user
  @POST('/reviews/request')
  Future<void> sendReviews(@Body() TargetUserRequest request);
}
