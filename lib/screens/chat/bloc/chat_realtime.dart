import '../../../services/pusher_service.dart';

class ChatRealtimeHandlers {
  const ChatRealtimeHandlers({
    required this.onMessage,
    required this.onTyping,
    required this.onRead,
    required this.onDeleted,
  });

  final PusherMessageCallback onMessage;
  final PusherMessageCallback onTyping;
  final PusherMessageCallback onRead;
  final PusherMessageCallback onDeleted;
}

abstract class ChatRealtime {
  bool get isConnected;

  Future<void> join(
    String token,
    String conversationId,
    ChatRealtimeHandlers handlers,
  );

  Future<void> leave(String conversationId, ChatRealtimeHandlers handlers);
}

class PusherChatRealtime implements ChatRealtime {
  PusherChatRealtime([PusherService? pusher]) : _pusher = pusher ?? PusherService();

  final PusherService _pusher;

  @override
  bool get isConnected => _pusher.isConnected;

  @override
  Future<void> join(
    String token,
    String conversationId,
    ChatRealtimeHandlers handlers,
  ) async {
    await _pusher.initialize(token);
    await _pusher.subscribeToConversation(conversationId, handlers.onMessage);
    await _pusher.subscribeToConversationTyping(
      conversationId,
      handlers.onTyping,
    );
    await _pusher.subscribeToConversationRead(conversationId, handlers.onRead);
    await _pusher.subscribeToConversationDeleted(
      conversationId,
      handlers.onDeleted,
    );
  }

  @override
  Future<void> leave(
    String conversationId,
    ChatRealtimeHandlers handlers,
  ) async {
    await _pusher.unsubscribeFromConversation(
      conversationId,
      handlers.onMessage,
    );
    await _pusher.unsubscribeFromConversationTyping(
      conversationId,
      handlers.onTyping,
    );
    await _pusher.unsubscribeFromConversationRead(
      conversationId,
      handlers.onRead,
    );
    await _pusher.unsubscribeFromConversationDeleted(
      conversationId,
      handlers.onDeleted,
    );
  }
}
