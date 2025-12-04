import 'package:flutter/material.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../bloc/chat_list_bloc.dart';
import '../widgets/conversation_item.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends BaseScreen {
    ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends BaseState<ChatListScreen, ChatListBloc> {
  final ScrollController _scrollController = ScrollController();
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    bloc.loadConversations();

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
    super.dispose();
  }

  @override
  Widget body() {
    return Scaffold(
      backgroundColor: WawatColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Сообщения',
          style: WawatTextStyles.h2,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showArchived ? Icons.inbox : Icons.archive,
              color: WawatColors.primary,
            ),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
              if (_showArchived) {
                bloc.loadArchivedConversations();
              } else {
                bloc.loadConversations();
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(WawatDimensions.spacingMd),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск сообщений...',
                hintStyle: WawatTextStyles.placeholder,
                prefixIcon:
                Icon(Icons.search, color: WawatColors.textSecondary),
                filled: true,
                fillColor: WawatColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(WawatDimensions.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: WawatDimensions.spacingMd,
                  vertical: WawatDimensions.spacingSm,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: bloc.conversationsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: WawatColors.primary,
              ),
            );
          }

          final conversations = snapshot.data!;

          if (conversations.isEmpty) {
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
                    _showArchived ? 'Нет архивных чатов' : 'Нет сообщений',
                    style: WawatTextStyles.body.copyWith(
                      color: WawatColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedConversations = [...conversations];
          sortedConversations.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return 0;
          });

          return RefreshIndicator(
            onRefresh: () async {
              if (_showArchived) {
                await bloc.loadArchivedConversations();
              } else {
                await bloc.loadConversations();
              }
            },
            color: WawatColors.primary,
            child: ListView.builder(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: sortedConversations.length + 1,
              itemBuilder: (context, index) {
                if (index == sortedConversations.length) {
                  return StreamBuilder<bool>(
                    stream: bloc.isLoadingMoreStream,
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return Padding(
                          padding: EdgeInsets.all(WawatDimensions.spacingMd),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: WawatColors.primary,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  );
                }

                final conversation = sortedConversations[index];

                return GestureDetector(
                  onLongPress: () {
                    _showConversationMenu(conversation);
                  },
                  child: ConversationItem(
                    conversation: conversation,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatConversationScreen(
                            conversation: conversation,
                          ),
                        ),
                      ).then((_) {
                        bloc.loadConversations();
                      });
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showConversationMenu(Conversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WawatDimensions.radiusLarge),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: WawatDimensions.spacingSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: WawatDimensions.spacingMd),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: WawatDimensions.spacingMd,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: WawatColors.primary.withOpacity(0.1),
                    child: Text(
                      conversation.user.fullname[0].toUpperCase(),
                      style: WawatTextStyles.h3.copyWith(
                        color: WawatColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: WawatDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.user.fullname,
                          style: WawatTextStyles.bodyBold,
                        ),
                        Text(
                          'Действия с чатом',
                          style: WawatTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: WawatDimensions.spacingLg),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WawatColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  conversation.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  color: WawatColors.info,
                  size: 20,
                ),
              ),
              title: Text(
                conversation.isPinned ? 'Открепить' : 'Закрепить',
                style: WawatTextStyles.body,
              ),
              onTap: () {
                Navigator.pop(context);
                bloc.togglePin(conversation.id);
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WawatColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  conversation.isArchived ? Icons.unarchive : Icons.archive,
                  color: WawatColors.warning,
                  size: 20,
                ),
              ),
              title: Text(
                conversation.isArchived ? 'Разархивировать' : 'Архивировать',
                style: WawatTextStyles.body,
              ),
              onTap: () {
                Navigator.pop(context);
                bloc.toggleArchive(conversation.id);
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WawatColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: WawatColors.error,
                  size: 20,
                ),
              ),
              title: Text(
                'Удалить чат',
                style: WawatTextStyles.body.copyWith(
                  color: WawatColors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(conversation);
              },
            ),
            SizedBox(height: WawatDimensions.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить чат?', style: WawatTextStyles.h3),
        content: Text(
          'Вы уверены, что хотите удалить переписку с ${conversation.user.fullname}?',
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
              bloc.deleteConversation(conversation.id);
            },
            child: Text(
              'Удалить',
              style: WawatTextStyles.bodyBold
                  .copyWith(color: WawatColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ChatListBloc provideBloc() {
    return ChatListBloc();
  }
}
