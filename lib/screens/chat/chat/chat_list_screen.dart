import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

                return Slidable(
                  key: Key(conversation.id.toString()),
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          bloc.togglePin(conversation.id);
                        },
                        backgroundColor: WawatColors.info,
                        foregroundColor: Colors.white,
                        icon: conversation.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        label:
                            conversation.isPinned ? 'Открепить' : 'Закрепить',
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          bloc.toggleArchive(conversation.id);
                        },
                        backgroundColor: WawatColors.warning,
                        foregroundColor: Colors.white,
                        icon: conversation.isArchived
                            ? Icons.unarchive
                            : Icons.archive,
                        label: conversation.isArchived
                            ? 'Разархивировать'
                            : 'Архивировать',
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          _showDeleteDialog(conversation);
                        },
                        backgroundColor: WawatColors.error,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Удалить',
                      ),
                    ],
                  ),
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
              style:
                  WawatTextStyles.bodyBold.copyWith(color: WawatColors.error),
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
