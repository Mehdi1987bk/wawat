import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../bloc/chat_conversation_bloc.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatConversationScreen extends BaseScreen {
  final Conversation conversation;

  ChatConversationScreen({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}
class _ChatConversationScreenState
    extends BaseState<ChatConversationScreen, ChatConversationBloc> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    bloc.initChat(widget.conversation.id);
    bloc.loadMessages();

    // Автоскролл к последнему сообщению
    bloc.messagesStream.listen((messages) {
      if (messages.isNotEmpty && _scrollController.hasClients) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    // Загрузка старых сообщений при скролле вверх
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 200) {
        bloc.loadMore();
      }
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget body() {
    return Scaffold(
      backgroundColor: WawatColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: bloc.messagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: WawatColors.primary,
                    ),
                  );
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: WawatColors.textSecondary,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),
                        Text(
                          'Начните переписку',
                          style: WawatTextStyles.body.copyWith(
                            color: WawatColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false, // ИЗМЕНЕНО: Убрали reverse
                  padding: EdgeInsets.all(WawatDimensions.spacingMd),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMyMessage = bloc.isMyMessage(message);

                    return MessageBubble(
                      message: message,
                      isMyMessage: isMyMessage,
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedFile != null) _buildFilePreview(),
          ChatInput(
            controller: _messageController,
            onSend: () {
              final text = _messageController.text.trim();
              if (text.isNotEmpty || _selectedFile != null) {
                bloc.sendMessage(text, _selectedFile);
                _messageController.clear();
                setState(() {
                  _selectedFile = null;
                });
              }
            },
            onAttachImage: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                setState(() {
                  _selectedFile = File(pickedFile.path);
                });
              }
            },
            onAttachFile: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null) {
                setState(() {
                  _selectedFile = File(result.files.single.path!);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: WawatColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: WawatColors.primary.withOpacity(0.1),
                backgroundImage: widget.conversation.user.avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(
                        widget.conversation.user.avatarUrl)
                    : null,
                child: widget.conversation.user.avatarUrl.isEmpty
                    ? Text(
                        widget.conversation.user.fullname[0].toUpperCase(),
                        style: WawatTextStyles.bodyBold.copyWith(
                          color: WawatColors.primary,
                        ),
                      )
                    : null,
              ),
              if (widget.conversation.user.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: WawatColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: WawatDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.conversation.user.fullname,
                        style: WawatTextStyles.bodyBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.conversation.user.isVerified) ...[
                      SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: WawatColors.info,
                      ),
                    ],
                  ],
                ),
                Text(
                  widget.conversation.user.getLastSeenText(),
                  style: WawatTextStyles.caption.copyWith(
                    color: widget.conversation.user.isOnline
                        ? WawatColors.success
                        : WawatColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: WawatColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
          ),
          onSelected: (value) {
            switch (value) {
              case 'block':
                _showBlockDialog();
                break;
              case 'delete':
                _showDeleteDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: WawatColors.error),
                  SizedBox(width: WawatDimensions.spacingSm),
                  Text('Заблокировать', style: WawatTextStyles.body),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: WawatColors.error),
                  SizedBox(width: WawatDimensions.spacingSm),
                  Text('Удалить чат', style: WawatTextStyles.body),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    return Container(
      padding: EdgeInsets.all(WawatDimensions.spacingSm),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: WawatColors.inputBackground,
              borderRadius: BorderRadius.circular(WawatDimensions.radiusSmall),
            ),
            child: _selectedFile!.path.toLowerCase().endsWith('.jpg') ||
                    _selectedFile!.path.toLowerCase().endsWith('.png') ||
                    _selectedFile!.path.toLowerCase().endsWith('.jpeg')
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(WawatDimensions.radiusSmall),
                    child: Image.file(
                      _selectedFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.insert_drive_file, color: WawatColors.primary),
          ),
          SizedBox(width: WawatDimensions.spacingSm),
          Expanded(
            child: Text(
              _selectedFile!.path.split('/').last,
              style: WawatTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: WawatColors.textSecondary),
            onPressed: () {
              setState(() {
                _selectedFile = null;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Заблокировать пользователя?', style: WawatTextStyles.h3),
        content: Text(
          'Вы уверены, что хотите заблокировать ${widget.conversation.user.fullname}?',
          style: WawatTextStyles.body,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: WawatTextStyles.bodyBold),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.blockUser(widget.conversation.user.id);
            },
            child: Text(
              'Заблокировать',
              style:
                  WawatTextStyles.bodyBold.copyWith(color: WawatColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить чат?', style: WawatTextStyles.h3),
        content: Text(
          'Вы уверены, что хотите удалить переписку с ${widget.conversation.user.fullname}?',
          style: WawatTextStyles.body,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: WawatTextStyles.bodyBold),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.deleteConversation();
              Navigator.pop(context);
            },
            child: Text(
              'Удалить',
              style:
                  WawatTextStyles.bodyBold.copyWith(color: WawatColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ChatConversationBloc provideBloc() {
    return ChatConversationBloc();
  }
}
