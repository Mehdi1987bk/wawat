import 'dart:io';

import 'package:dio/dio.dart';

import '../response/chat_response.dart';
import '../response/target_user_request.dart';

class ChatApi {
  ChatApi(this._dio, {String baseUrl = 'https://api.wawatair.com/api/v1'})
      : _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  Future<ConversationResponse> startChat(Map<String, dynamic> body) async {
    final userId = body['user_id'] ?? body['target_user_id'] ?? body['id'];
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/users/$userId/conversation',
    );
    final result = ConversationResponse.fromJson(response.data ?? {});
    final text = body['body']?.toString().trim();
    if (result.data != null && text != null && text.isNotEmpty) {
      await sendTextMessage(result.data!.id, {'body': text});
    }
    return result;
  }

  Future<ConversationsResponse> getConversations(
    int perPage,
    int page, {
    bool archived = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/conversations',
      queryParameters: {
        'per_page': perPage,
        'page': page,
        if (archived) 'archived': true,
      },
    );
    return ConversationsResponse.fromJson(response.data ?? {});
  }

  Future<ConversationsResponse> getArchivedConversations(
    int perPage,
    int page,
  ) {
    return getConversations(perPage, page, archived: true);
  }

  Future<MessagesResponse> getMessages(
    String conversationId,
    int perPage,
    int page,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/conversations/$conversationId/messages',
      queryParameters: {
        'per_page': perPage,
        'page': page,
      },
    );
    return MessagesResponse.fromJson(response.data ?? {});
  }

  Future<MessageResponse> sendTextMessage(
    String conversationId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/conversations/$conversationId/messages',
      data: body,
    );
    return MessageResponse.fromJson(response.data ?? {});
  }

  Future<MessageResponse> sendMessageWithFile(
    String conversationId,
    File file,
    String? body,
  ) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path),
      if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/conversations/$conversationId/images',
      data: formData,
    );
    return MessageResponse.fromJson(response.data ?? {});
  }

  Future<void> updateConversation(
    String conversationId,
    Map<String, dynamic> body,
  ) async {
    await _dio.patch<void>(
      '$_baseUrl/conversations/$conversationId',
      data: body,
    );
  }

  Future<void> pinConversation(String conversationId) {
    return updateConversation(conversationId, {'is_pinned': true});
  }

  Future<void> unpinConversation(String conversationId) {
    return updateConversation(conversationId, {'is_pinned': false});
  }

  Future<void> archiveConversation(String conversationId) {
    return updateConversation(conversationId, {'is_archived': true});
  }

  Future<void> unarchiveConversation(String conversationId) {
    return updateConversation(conversationId, {'is_archived': false});
  }

  Future<void> deleteConversation(String conversationId) async {
    await _dio.delete<void>('$_baseUrl/conversations/$conversationId');
  }

  Future<void> blockUser(Map<String, dynamic> body) async {
    final userId = body['user_id'] ?? body['target_user_id'] ?? body['id'];
    await _dio.post<void>('$_baseUrl/users/$userId/block');
  }

  Future<void> unblockUser(Map<String, dynamic> body) async {
    final userId = body['user_id'] ?? body['target_user_id'] ?? body['id'];
    await _dio.delete<void>('$_baseUrl/users/$userId/block');
  }

  Future<void> sendReviews(TargetUserRequest request) async {
    await _dio.post<void>('$_baseUrl/reviews/request', data: request.toJson());
  }

  Future<ShipmentResponse> getShipment(String shipmentId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/shipments/$shipmentId',
    );
    return ShipmentResponse.fromJson(response.data ?? {});
  }

  Future<void> shipmentAction(
    String shipmentId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    await _dio.post<void>(
      '$_baseUrl/shipments/$shipmentId/$action',
      data: body,
      options: Options(headers: {
        'Idempotency-Key':
            'chat-${DateTime.now().microsecondsSinceEpoch}-$shipmentId-$action',
      }),
    );
  }
}
