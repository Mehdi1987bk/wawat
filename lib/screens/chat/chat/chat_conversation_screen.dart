import 'dart:io';
import 'package:buking/data/network/response/chat_response.dart';
import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/bloc/error_dispatcher.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:buking/presentation/resourses/wawat_dimensions.dart';
import 'package:buking/presentation/resourses/wawat_text_styles.dart';
import 'package:buking/services/theme_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../home/tabs/home_tab/courier_screen/courier_screen.dart';
import '../../home/tabs/profile_tab/settings/experience_tab/experience_tab_screen.dart';
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
    extends BaseState<ChatConversationScreen, ChatConversationBloc>
    with ErrorDispatcher {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    bloc.initChat(widget.conversation.id);
    bloc.loadMessages();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor:
            isDark ? const Color(0xFF121212) : WawatColors.backgroundLight,
            appBar: _buildAppBar(isDark),
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
                                color: isDark
                                    ? const Color(0xFF6B7280)
                                    : WawatColors.textSecondary,
                              ),
                              SizedBox(height: WawatDimensions.spacingMd),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: WawatTextStyles.body.copyWith(
                                  color: isDark
                                      ? const Color(0xFFB0B0B0)
                                      : WawatColors.textSecondary,
                                ),
                                child:   Text(S.of(context).vgfbgf4),
                              ),
                            ],
                          ),
                        );
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: isDark
                            ? const Color(0xFF121212)
                            : WawatColors.backgroundLight,
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
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
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedFile != null) _buildFilePreview(isDark),
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
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : WawatColors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: () =>
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return CourierDetailsScreen(
                    courierId: widget.conversation.user.id,
                  );
                },
              ),
            ),
        child: Row(
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
                          color:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: WawatTextStyles.bodyBold.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          child: Text(
                            widget.conversation.user.fullname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (widget.conversation.user.isVerified == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "asset/prof_3.png",
                                width: 16,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: WawatTextStyles.caption.copyWith(
                      color: widget.conversation.user.isOnline
                          ? WawatColors.success
                          : (isDark
                          ? const Color(0xFF9CA3AF)
                          : WawatColors.textSecondary),
                    ),
                    child: Text(
                      widget.conversation.user.getLastSeenText(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
         IconButton(
          onPressed: () => _showSendRequestFromRewiew(isDark),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700),
                  const Color(0xFFFFA500),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(WawatDimensions.spacingSm),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : WawatColors.inputBackground,
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
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: WawatTextStyles.body.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
              child: Text(
                _selectedFile!
                    .path
                    .split('/')
                    .last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color:
              isDark ? const Color(0xFF9CA3AF) : WawatColors.textSecondary,
            ),
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


  void _showSendRequestFromRewiew(bool isDark) {
    final screenContext = context;  

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: WawatTextStyles.h3.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
          child:   Text(S.of(context).bgfbgfb4),
        ),
        content: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: WawatTextStyles.body.copyWith(
            color: isDark ? const Color(0xFFB0B0B0) : Colors.black,
          ),
          child: Text(
            S.of(context).bgfbfgb4+' ${widget.conversation.user.fullname} ' + S.of(context).bfgbgbgy6,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              S.of(context).bgbgfgb43,
              style: WawatTextStyles.bodyBold.copyWith(
                color: isDark ? const Color(0xFF6366F1) : WawatColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Закрываем диалог
              final success = await bloc.sendReviews(widget.conversation.user.id);
              if (success && mounted) {
                showIOSStyleMessage(screenContext, S.of(context).bgfbfg3);  
              }
            },
            child: Text(
              S.of(context).cdsdssde3,
              style: WawatTextStyles.bodyBold.copyWith(color: WawatColors.success),
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
