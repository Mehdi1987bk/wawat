import 'package:flutter/material.dart';

import '../../../../data/network/response/offer_models.dart';

class ChatScreen extends StatefulWidget {
  final OfferModel courier;

  const ChatScreen({
    Key? key,
    required this.courier,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          messages.add(
            ChatMessage(
              text: 'Спасибо за сообщение! 👋',
              isMe: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courier.user?.fullname ?? 'Чат'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Text('Нет сообщений'),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 280),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isMe ? Color(0xFF5B5FFF) : Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: message.isMe ? Colors.white : Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
              ),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// ============================================================================
// МОДЕЛЬ ДЛЯ СООБЩЕНИЙ
// ============================================================================

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}