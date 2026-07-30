import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../home/scrollable_tab.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/wawat_content.dart';
import '../../home/tabs/profile_tab/unread_chat_bloc.dart';
import '../bloc/chat_list_bloc.dart';
import '../widgets/conversation_item.dart';
import 'chat_conversation_screen.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

class ChatListScreen extends BaseScreen {
  ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => ChatListScreenState();
}

class ChatListScreenState extends BaseState<ChatListScreen, ChatListBloc>
    with ScrollableTab {
  final ScrollController _scrollController = ScrollController();

  @override
  void scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  bool _showArchived = false;
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, String> _content = const {};
  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<Object>? _actionErrorSubscription;

  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    bloc.init();
    bloc.loadConversations();
    WawatContent.loadDefault().then((content) {
      if (mounted) setState(() => _content = content);
    });
    // Surface block/unblock failures (422, missing id, network) to the user.
    _actionErrorSubscription = bloc.actionErrorsStream.listen((error) {
      if (mounted) showTopSnackbar(_extractError(error), false, context);
    });
    _scrollController.addListener(_onScroll);
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        bloc.reconnectRealtime();
        bloc.refreshCurrent();
        sl.get<UnreadChatBloc>().fetchUnreadCount();
      },
    );
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(_content, key, fallback);
  }

  Future<void> refreshFromTabFocus() async {
    await bloc.reconnectRealtime();
    await bloc.refreshCurrent();
    await sl.get<UnreadChatBloc>().fetchUnreadCount();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      bloc.loadMore();
    }
  }

  @override
  void dispose() {
    _actionErrorSubscription?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _lifecycleListener?.dispose();
    super.dispose();
  }

  /// Pull a human message out of a Dio/validation error, mirroring the
  /// conversation screen's extractor.
  String _extractError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
    }
    return _t('common.error', 'Xəta baş verdi. Yenidən cəhd edin.');
  }

  void _toggleSearch() {
    setState(() {
      _searchActive = !_searchActive;
      if (!_searchActive) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  /// Client-side filter over the loaded conversations by name / username.
  List<Conversation> _applySearch(List<Conversation> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;
    return source.where((c) {
      final name = c.user.fullname.toLowerCase();
      final username = (c.user.username ?? '').toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();
  }

  @override
  Widget body() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? WawatDark.bg : Colors.white,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? WawatDark.bg : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                searchActive: _searchActive,
                searchController: _searchController,
                onSearchToggle: _toggleSearch,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                showArchived: _showArchived,
                content: _content,
                isDark: isDark,
                onTabChanged: (archived) {
                  if (_showArchived == archived) return;
                  setState(() => _showArchived = archived);
                  archived
                      ? bloc.loadArchivedConversations()
                      : bloc.loadConversations();
                },
              ),
              Expanded(
                child: StreamBuilder<bool>(
                  stream: bloc.isLoadingStream,
                  initialData: true,
                  builder: (context, loadingSnapshot) {
                    return StreamBuilder<List<Conversation>>(
                      stream: bloc.conversationsStream,
                      initialData: const [],
                      builder: (context, snapshot) {
                        final conversations = List<Conversation>.from(
                          snapshot.data ?? const <Conversation>[],
                        );
                        conversations.sort(_sortConversations);
                        final visible = _applySearch(conversations);

                        if (loadingSnapshot.data == true &&
                            conversations.isEmpty) {
                          return _ChatSkeleton(isDark: isDark);
                        }

                        if (visible.isEmpty) {
                          if (_searchQuery.trim().isNotEmpty) {
                            return Center(
                              child: Text(
                                WawatContent.text(_content, 'chat.search.empty',
                                    'Heç nə tapılmadı'),
                                style: TextStyle(
                                  color: isDark
                                      ? WawatDark.textSecondary
                                      : _ink500,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return _EmptyState(
                            showArchived: _showArchived,
                            content: _content,
                            isDark: isDark,
                          );
                        }

                        return RefreshIndicator(
                          color: _brand,
                          onRefresh: () => _showArchived
                              ? bloc.loadArchivedConversations()
                              : bloc.loadConversations(),
                          child: ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 96),
                            itemCount: visible.length + 1,
                            separatorBuilder: (_, index) =>
                                index >= visible.length - 1
                                    ? const SizedBox.shrink()
                                    : Divider(
                                        height: 1,
                                        indent: 20,
                                        color: isDark
                                            ? WawatDark.divider
                                            : _ink900.withValues(alpha: 0.04),
                                      ),
                            itemBuilder: (context, index) {
                              if (index == visible.length) {
                                return StreamBuilder<bool>(
                                  stream: bloc.isLoadingMoreStream,
                                  initialData: false,
                                  builder: (context, snapshot) {
                                    if (snapshot.data != true) {
                                      return const SizedBox(height: 12);
                                    }
                                    return const Padding(
                                      padding: EdgeInsets.all(18),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _brand,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }

                              final conversation = visible[index];
                              return ConversationItem(
                                conversation: conversation,
                                onTap: () => _openConversation(conversation),
                                onTapMenu: () => _showConversationMenu(
                                  conversation,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _sortConversations(Conversation a, Conversation b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    final aTime = a.sortTime;
    final bTime = b.sortTime;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  }

  Future<void> _openConversation(Conversation conversation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(conversation: conversation),
      ),
    );
    if (_showArchived) {
      await bloc.loadArchivedConversations();
    } else {
      await bloc.loadConversations();
    }
    sl.get<UnreadChatBloc>().fetchUnreadCount();
  }

  void _showConversationMenu(Conversation conversation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showAppBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? WawatDark.surface : Colors.white,
      barrierColor: isDark ? WawatDark.scrim : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? WawatDark.grab : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isDark ? WawatDark.brandSoft : _brand50,
                      child: Text(
                        conversation.user.initials,
                        style: TextStyle(
                          color: isDark ? WawatDark.brandText : _brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.user.fullname,
                            style: TextStyle(
                              color: isDark ? WawatDark.textPrimary : _ink900,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _t('chat.action.profile'),
                            style: TextStyle(
                              color: isDark ? WawatDark.textMuted : _ink400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: PhosphorIconsRegular.pushPin,
                  label: conversation.isPinned
                      ? _t('chat.action.unpin')
                      : _t('chat.action.pin'),
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.togglePin(conversation.id);
                  },
                ),
                _MenuTile(
                  icon: PhosphorIconsRegular.archive,
                  label: conversation.isArchived
                      ? _t('chat.action.unarchive')
                      : _t('chat.action.archive'),
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.toggleArchive(conversation.id);
                  },
                ),
                _MenuTile(
                  icon: PhosphorIconsRegular.prohibit,
                  label: conversation.isBlocked
                      ? _t('chat.action.unblock')
                      : _t('chat.action.block'),
                  danger: true,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    if (!conversation.user.hasApiId) {
                      showTopSnackbar(
                        _t('chat.profile.unavailable',
                            'İstifadəçi məlumatı tapılmadı.'),
                        false,
                        context,
                      );
                      return;
                    }
                    conversation.isBlocked
                        ? bloc.unblockUser(conversation.user.apiId)
                        : bloc.blockUser(conversation.user.apiId);
                  },
                ),
                _MenuTile(
                  icon: PhosphorIconsRegular.trash,
                  label: _t('chat.action.delete'),
                  danger: true,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.deleteConversation(conversation.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  ChatListBloc provideBloc() => ChatListBloc();
}

class _Header extends StatelessWidget {
  final bool searchActive;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final bool showArchived;
  final Map<String, String> content;
  final bool isDark;
  final ValueChanged<bool> onTabChanged;

  const _Header({
    required this.searchActive,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.showArchived,
    required this.content,
    required this.isDark,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Row(
            children: [
              if (searchActive) ...[
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? WawatDark.surfaceAlt
                          : _ink900.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIconsRegular.magnifyingGlass,
                            color: isDark ? WawatDark.icon : _ink500, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            onChanged: onSearchChanged,
                            style: TextStyle(
                              color: isDark ? WawatDark.textPrimary : _ink900,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: WawatContent.text(
                                  content, 'chat.search.hint', 'Axtar...'),
                              hintStyle: TextStyle(
                                color: isDark ? WawatDark.textMuted : _ink400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSearchToggle,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? WawatDark.surfaceAlt
                          : _ink900.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIconsBold.x,
                        color: isDark ? WawatDark.icon : _ink900, size: 20),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    WawatContent.text(content, 'chat.list.title'),
                    style: TextStyle(
                      color: isDark ? WawatDark.textPrimary : _ink900,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSearchToggle,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? WawatDark.surfaceAlt
                          : _ink900.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIconsRegular.magnifyingGlass,
                        color: isDark ? WawatDark.icon : _ink900, size: 20),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            children: [
              _TabChip(
                label: WawatContent.text(content, 'chat.tab.all'),
                selected: !showArchived,
                isDark: isDark,
                onTap: () => onTabChanged(false),
              ),
              const SizedBox(width: 8),
              _TabChip(
                label: WawatContent.text(content, 'chat.tab.archive'),
                selected: showArchived,
                isDark: isDark,
                onTap: () => onTabChanged(true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? _brand
              : isDark
                  ? WawatDark.surfaceAlt
                  : _ink900.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : isDark
                    ? WawatDark.textSecondary
                    : _ink500,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool showArchived;
  final Map<String, String> content;
  final bool isDark;

  const _EmptyState({
    required this.showArchived,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.brandSoft : _brand50,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                showArchived
                    ? PhosphorIconsRegular.archive
                    : PhosphorIconsRegular.chatsCircle,
                color: isDark ? WawatDark.brandText : _brand,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              showArchived
                  ? WawatContent.text(
                      content,
                      'chat.empty_archive_title',
                    )
                  : WawatContent.text(
                      content,
                      'chat.empty_title',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? WawatDark.textPrimary : _ink900,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              showArchived
                  ? WawatContent.text(
                      content,
                      'chat.empty_archive_subtitle',
                    )
                  : WawatContent.text(
                      content,
                      'chat.empty_subtitle',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink500,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatSkeleton extends StatelessWidget {
  final bool isDark;

  const _ChatSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _SkeletonBox(width: 48, height: 48, radius: 24, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(
                      width: 140, height: 14, radius: 8, isDark: isDark),
                  const SizedBox(height: 10),
                  _SkeletonBox(
                      width: 220, height: 12, radius: 8, isDark: isDark),
                ],
              ),
            ),
            _SkeletonBox(width: 34, height: 12, radius: 8, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final bool isDark;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? WawatDark.skeletonBase : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool isDark;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? const Color(0xFFEF4444)
        : (isDark ? WawatDark.textPrimary : _ink900);
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: danger ? color : (isDark ? WawatDark.icon : _ink500),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
