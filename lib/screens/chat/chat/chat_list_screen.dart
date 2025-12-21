import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_aware_screen.dart';
import '../../../services/theme_manager.dart';
import '../../home/tabs/home_tab/home_tab_screen.dart';
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
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    bloc.init();
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
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;


    return ThemeAwareScreen(
          isDark: isDark,
          child: SafeArea(
            child: Scaffold(
              backgroundColor:
                  isDark ? const Color(0xFF121212) : Colors.white,
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: WawatDimensions.spacingMd,
                            vertical: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showArchived = !_showArchived;
                                });
                                if (_showArchived) {
                                  bloc.loadArchivedConversations();
                                } else {
                                  bloc.loadConversations();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF5B7FFF),
                                      Color(0xFFAB5FE8)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF5B7FFF)
                                          .withOpacity(isDark ? 0.3 : 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _showArchived
                                              ? Icons.inbox
                                              : Icons.archive,
                                          color: Color(0xFF5B7FFF),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _showArchived ? 'Входящие' : 'Архив',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Список чатов
                        Expanded(
                          child: StreamBuilder<List<Conversation>>(
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
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 64,
                                          color: isDark
                                              ? const Color(0xFF6B7280)
                                              : WawatColors.textSecondary,
                                        ),
                                        SizedBox(
                                            height:
                                                WawatDimensions.spacingMd),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          style:
                                              WawatTextStyles.body.copyWith(
                                            color: isDark
                                                ? const Color(0xFFB0B0B0)
                                                : WawatColors.textSecondary,
                                          ),
                                          child: Text('Нет чатов'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final sortedConversations = [...conversations];
                              sortedConversations.sort((a, b) {
                                if (a.isPinned && !b.isPinned) return -1;
                                if (!a.isPinned && b.isPinned) return 1;

                                if (a.lastMessage == null &&
                                    b.lastMessage == null) return 0;
                                if (a.lastMessage == null) return 1;
                                if (b.lastMessage == null) return -1;

                                final aTime =
                                    DateTime.parse(a.lastMessage!.createdAt);
                                final bTime =
                                    DateTime.parse(b.lastMessage!.createdAt);
                                return bTime.compareTo(aTime);
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
                                backgroundColor: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: sortedConversations.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          sortedConversations.length) {
                                        return StreamBuilder<bool>(
                                          stream: bloc.isLoadingMoreStream,
                                          builder: (context, snapshot) {
                                            if (snapshot.data == true) {
                                              return Padding(
                                                padding: EdgeInsets.all(
                                                    WawatDimensions
                                                        .spacingMd),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color:
                                                        WawatColors.primary,
                                                  ),
                                                ),
                                              );
                                            }
                                            return SizedBox.shrink();
                                          },
                                        );
                                      }

                                      final conversation =
                                          sortedConversations[index];

                                      return ConversationItem(
                                          conversation: conversation,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatConversationScreen(
                                                  conversation: conversation,
                                                ),
                                              ),
                                            ).then((_) {
                                              bloc.loadConversations();
                                            });
                                          },
                                          onTapMenu: () =>
                                              _showConversationMenu(
                                                  conversation, isDark));
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  BuildHeader(context, isDark),
                ],
              ),
            ),
          ),
        );
      }



  void _showConversationMenu(Conversation conversation, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                color: isDark ? const Color(0xFF6B7280) : Colors.grey[300],
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
                          style: WawatTextStyles.bodyBold.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'Действия с чатом',
                          style: WawatTextStyles.caption.copyWith(
                            color: isDark ? const Color(0xFFB0B0B0) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: WawatDimensions.spacingLg,
              color: isDark ? const Color(0xFF2A2A2A) : null,
            ),
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
                style: WawatTextStyles.body.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
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
                style: WawatTextStyles.body.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
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
                  color: (conversation.user.isBlocked ?? false)
                      ? WawatColors.success.withOpacity(0.1)
                      : WawatColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                 ( conversation.user.isBlocked ?? false)? Icons.check_circle : Icons.block,
                  color: (conversation.user.isBlocked ?? false)
                      ? WawatColors.success
                      : WawatColors.error,
                  size: 20,
                ),
              ),
              title: Text(
            (    conversation.user.isBlocked ?? false)? 'Разблокировать' : 'Заблокировать',
                style: WawatTextStyles.body.copyWith(
                  color: (conversation.user.isBlocked ?? false)
                      ? (isDark ? Colors.white : Colors.black)
                      : WawatColors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (conversation.user.isBlocked ?? false) {
                  _showUnblockDialog(conversation, isDark);
                } else {
                  _showBlockDialog(conversation, isDark);
                }
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
                _showDeleteDialog(conversation, isDark);
              },
            ),
            SizedBox(height: WawatDimensions.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Conversation conversation, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Удалить чат?',
          style: WawatTextStyles.h3.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите удалить переписку с ${conversation.user.fullname}?',
          style: WawatTextStyles.body.copyWith(
            color: isDark ? const Color(0xFFB0B0B0) : Colors.black,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: WawatTextStyles.bodyBold.copyWith(
                color: isDark ? const Color(0xFF6366F1) : null,
              ),
            ),
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

  void _showBlockDialog(Conversation conversation, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Заблокировать пользователя?',
          style: WawatTextStyles.h3.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите заблокировать ${conversation.user.fullname}?',
          style: WawatTextStyles.body.copyWith(
            color: isDark ? const Color(0xFFB0B0B0) : Colors.black,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: WawatTextStyles.bodyBold.copyWith(
                color: isDark ? const Color(0xFF6366F1) : WawatColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.blockUser(conversation.user.id);
            },
            child: Text(
              'Заблокировать',
              style: WawatTextStyles.bodyBold.copyWith(color: WawatColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(Conversation conversation, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Разблокировать пользователя?',
          style: WawatTextStyles.h3.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите разблокировать ${conversation.user.fullname}?',
          style: WawatTextStyles.body.copyWith(
            color: isDark ? const Color(0xFFB0B0B0) : Colors.black,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: WawatTextStyles.bodyBold.copyWith(
                color: isDark ? const Color(0xFF6366F1) : WawatColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.unblockUser(conversation.user.id);
            },
            child: Text(
              'Разблокировать',
              style: WawatTextStyles.bodyBold.copyWith(color: WawatColors.success),
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
