import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import '../response/chat_response.dart';
import '../response/review_submit_result.dart';
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
    File file, {
    String? caption,
  }) async {
    final trimmedCaption = caption?.trim() ?? '';
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path),
      // Optional photo caption (≤1000). Saved as the image message's body.
      if (trimmedCaption.isNotEmpty) 'caption': trimmedCaption,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/conversations/$conversationId/images',
      data: formData,
    );
    return MessageResponse.fromJson(response.data ?? {});
  }

  Future<MessageResponse> editMessage(
    String messageId,
    String body,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/messages/$messageId',
      data: {'body': body},
    );
    return MessageResponse.fromJson(response.data ?? {});
  }

  Future<void> deleteMessage(String messageId) async {
    await _dio.delete<void>('$_baseUrl/messages/$messageId');
  }

  Future<void> markConversationRead(String conversationId) async {
    await _dio.post<void>('$_baseUrl/conversations/$conversationId/read');
  }

  Future<void> sendTyping(
    String conversationId, {
    required bool typing,
  }) async {
    await _dio.post<void>(
      '$_baseUrl/conversations/$conversationId/typing',
      data: {'typing': typing},
    );
  }

  /// Unread badges: total unread conversations + how many ARCHIVED chats have
  /// unread messages (per chat, not per message). `/conversations/unread-count`
  /// → `{ unread_count, archived_unread_count }`.
  Future<({int unread, int archived})> getUnreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/conversations/unread-count',
    );
    final data = response.data?['data'];
    if (data is Map) {
      return (
        unread: _asInt(data['unread_count']),
        archived: _asInt(data['archived_unread_count']),
      );
    }
    return (unread: 0, archived: 0);
  }

  int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
    await _dio.post<void>('$_baseUrl/users/${_moderationId(body)}/block');
  }

  Future<void> unblockUser(Map<String, dynamic> body) async {
    await _dio.delete<void>('$_baseUrl/users/${_moderationId(body)}/block');
  }

  /// Resolve the target user id (public_id/ULID) for block/unblock, refusing
  /// empty or `0` values so we never post to `/users//block` or `/users/0/block`.
  String _moderationId(Map<String, dynamic> body) {
    final raw = (body['user_id'] ?? body['target_user_id'] ?? body['id'])
            ?.toString()
            .trim() ??
        '';
    if (raw.isEmpty || raw == '0') {
      throw ArgumentError('Missing target user id for block/unblock');
    }
    return raw;
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

  Future<ShipmentsPage> getShipments({
    String? filter,
    String? status,
    String? role,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/shipments',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (filter != null) 'filter': filter,
        if (status != null) 'status': status,
        if (role != null) 'role': role,
      },
    );
    return ShipmentsPage.fromJson(response.data ?? {});
  }

  Future<String?> shipmentAction(
    String shipmentId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/shipments/$shipmentId/$action',
      data: body,
      options: Options(headers: {
        'Idempotency-Key': _uuidV4(),
      }),
    );
    return response.data?['message']?.toString();
  }

  Future<ReviewSubmitResult> submitShipmentReview(
    String shipmentId, {
    required int rating,
    String? comment,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/shipments/$shipmentId/review',
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
      options: Options(headers: {'Idempotency-Key': _uuidV4()}),
    );
    return ReviewSubmitResult.fromResponse(response.data);
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final value = hex.join();
    return '${value.substring(0, 8)}-'
        '${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-'
        '${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }
}
