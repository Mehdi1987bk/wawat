import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/notification_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/notification_router.dart';
import '../../../../../services/wawat_content.dart';
import '../search/search_offer_list_screen.dart';
import 'notification_bloc.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink200 = Color(0xFFE2E8F0);
const _screenBg = Colors.white;
const _emerald = Color(0xFF059669);
const _emerald50 = Color(0xFFECFDF5);
const _red = Color(0xFFEF4444);
const _red50 = Color(0xFFFEF2F2);
const _amber = Color(0xFFB67C00);
const _amber50 = Color(0xFFFEF6E7);
const _accent50 = Color(0x4DF2FC2A);

class NotificationScreen extends BaseScreen<NotificationBloc> {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState
    extends BaseState<NotificationScreen, NotificationBloc> {
  final _scrollController = ScrollController();
  Map<String, String> _content = const {};

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    bloc.loadNotifications();
    WawatContent.loadDefault().then((content) {
      if (mounted) setState(() => _content = content);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 420) {
        bloc.loadNotifications(refresh: false);
      }
    });
    bloc.errors.listen(_showError);
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(_content, key, fallback);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget body() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? WawatDark.bg : _screenBg,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                onBack: () => Navigator.of(context).maybePop(),
                onReadAll: bloc.markAllAsRead,
                unreadCount: bloc.unreadCount,
                unreadOnly: bloc.unreadOnly,
                content: _content,
                isDark: isDark,
                onUnreadChanged: bloc.setUnreadOnly,
              ),
              Expanded(
                child: StreamBuilder<bool>(
                  stream: bloc.loading,
                  initialData: false,
                  builder: (context, loadingSnapshot) {
                    return StreamBuilder<List<NotificationItem>>(
                      stream: bloc.notifications,
                      initialData: const [],
                      builder: (context, snapshot) {
                        final isLoading = loadingSnapshot.data == true;
                        final items = snapshot.data ?? const [];
                        if (isLoading && items.isEmpty) {
                          return _SkeletonList(isDark: isDark);
                        }
                        if (items.isEmpty) {
                          return _EmptyState(
                            content: _content,
                            isDark: isDark,
                            onExplore: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SearchOfferListScreen(),
                              ),
                            ),
                          );
                        }
                        return RefreshIndicator(
                          color: _brand,
                          onRefresh: bloc.loadNotifications,
                          child: ListView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: _groupedItems(items)
                                .expand((entry) => [
                                      _DateHeader(entry.key, isDark: isDark),
                                      ...entry.value.map(
                                        (item) => _buildItem(item, isDark),
                                      ),
                                    ])
                                .toList(),
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

  Widget _buildItem(NotificationItem item, bool isDark) {
    return Dismissible(
      key: ValueKey(item.id),
      background: _SwipeAction(
        color: _brand,
        icon: PhosphorIconsBold.check,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeAction(
        color: _red,
        icon: PhosphorIconsBold.trash,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await bloc.markAsRead(item.id);
          return false;
        }
        await bloc.delete(item.id);
        return true;
      },
      child: _NotificationTile(
        item: item,
        onTap: () => _openNotification(item),
        onLongPress: () => _showActions(item),
        onAction: (action) => _handleInlineAction(item, action),
        content: _content,
        isDark: isDark,
      ),
    );
  }

  Future<void> _openNotification(NotificationItem item) async {
    // Mark read + refresh the unread badge, then route by the unified target
    // (same router the push path uses). Navigation is driven strictly by
    // target — never by type or raw data.
    if (item.isUnread) await bloc.markAsRead(item.id);
    if (!mounted) return;
    openNotification(item.target.type, item.target.id, item.target.params);
  }

  Future<void> _showActions(NotificationItem item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showAppBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : null,
      builder: (_) => _ActionsSheet(
        item: item,
        content: _content,
        isDark: isDark,
        onRead: () {
          Navigator.pop(context);
          bloc.markAsRead(item.id);
        },
        onOpen: () {
          Navigator.pop(context);
          _openNotification(item);
        },
        onMute: () {
          Navigator.pop(context);
          _showMessage(_t(
            'notifications.mute_hint',
          ));
        },
        onDelete: () {
          Navigator.pop(context);
          bloc.delete(item.id);
        },
      ),
    );
  }

  void _handleInlineAction(NotificationItem item, _InlineAction action) {
    bloc.markAsRead(item.id);
    switch (action) {
      case _InlineAction.accept:
        _showMessage(_t('notifications.request_accepted'));
        break;
      case _InlineAction.decline:
        _showMessage(_t('notifications.request_declined'));
        break;
      case _InlineAction.view:
      case _InlineAction.complete:
        _openNotification(item);
        break;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _showError(String message) => _showMessage(message);

  List<MapEntry<String, List<NotificationItem>>> _groupedItems(
    List<NotificationItem> items,
  ) {
    final groups = <String, List<NotificationItem>>{};
    for (final item in items) {
      groups.putIfAbsent(_groupLabel(item.createdAt), () => []).add(item);
    }
    return groups.entries.toList();
  }

  @override
  NotificationBloc provideBloc() => NotificationBloc();
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onReadAll;
  final Stream<int> unreadCount;
  final Stream<bool> unreadOnly;
  final Map<String, String> content;
  final bool isDark;
  final ValueChanged<bool> onUnreadChanged;

  const _Header({
    required this.onBack,
    required this.onReadAll,
    required this.unreadCount,
    required this.unreadOnly,
    required this.content,
    required this.isDark,
    required this.onUnreadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? WawatDark.divider : _ink900.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onBack,
                  child: Icon(
                    PhosphorIconsBold.arrowLeft,
                    color: isDark ? WawatDark.icon : _ink700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    WawatContent.text(content, 'notifications.title'),
                    style: TextStyle(
                      color: isDark ? WawatDark.textPrimary : _ink900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onReadAll,
                  child: Row(
                    children: [
                      Icon(PhosphorIconsBold.checks,
                          color: isDark ? cBrandText(true) : _brand, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        WawatContent.text(content, 'notifications.read_all'),
                        style: TextStyle(
                          color: isDark ? cBrandText(true) : _brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: StreamBuilder<bool>(
              stream: unreadOnly,
              initialData: false,
              builder: (context, snapshot) {
                final selectedUnread = snapshot.data == true;
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? WawatDark.surfaceAlt
                        : _ink900.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _SegmentButton(
                        label:
                            WawatContent.text(content, 'notifications.tab_all'),
                        selected: !selectedUnread,
                        isDark: isDark,
                        onTap: () => onUnreadChanged(false),
                      ),
                      StreamBuilder<int>(
                        stream: unreadCount,
                        initialData: 0,
                        builder: (context, countSnapshot) {
                          return _SegmentButton(
                            label: WawatContent.text(
                              content,
                              'notifications.tab_unread',
                            ),
                            count: countSnapshot.data ?? 0,
                            selected: selectedUnread,
                            isDark: isDark,
                            onTap: () => onUnreadChanged(true),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    this.count,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? WawatDark.elevated : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected && !isDark
                ? [
                    BoxShadow(
                      color: _ink900.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? (isDark ? cBrandText(true) : _brand)
                      : (isDark ? WawatDark.textSecondary : _ink500),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if ((count ?? 0) > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _brand,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DateHeader(this.label, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? WawatDark.textMuted : _ink400,
          fontSize: 11,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<_InlineAction> onAction;
  final Map<String, String> content;
  final bool isDark;

  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.onAction,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _notificationVisual(item.type, isDark);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: item.isUnread
              ? (isDark
                  ? WawatDark.brand.withValues(alpha: 0.08)
                  : _brand.withValues(alpha: 0.045))
              : (isDark ? WawatDark.surface : Colors.white),
          border: Border(
            bottom: BorderSide(
              color:
                  isDark ? WawatDark.divider : _ink900.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: meta.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(meta.icon, color: meta.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: isDark ? WawatDark.textPrimary : _ink900,
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: isDark ? WawatDark.brandTextStrong : _brand,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.body != null && item.body!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.body!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? WawatDark.textSecondary : _ink500,
                        fontSize: 12.5,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _relativeTime(item.createdAt),
                    style: TextStyle(
                      color: isDark ? WawatDark.textMuted : _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.isInteractive) ...[
                    const SizedBox(height: 10),
                    _InlineActions(
                      type: item.type,
                      onAction: onAction,
                      content: content,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineActions extends StatelessWidget {
  final String type;
  final ValueChanged<_InlineAction> onAction;
  final Map<String, String> content;
  final bool isDark;

  const _InlineActions({
    required this.type,
    required this.onAction,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final actions = switch (type) {
      'proposal_countered' => [
          (
            WawatContent.text(content, 'notifications.action.accept'),
            _InlineAction.accept,
            true
          ),
          (
            WawatContent.text(content, 'notifications.action.view'),
            _InlineAction.view,
            false
          ),
        ],
      'shipment_delivered' => [
          (
            WawatContent.text(content, 'notifications.action.confirm'),
            _InlineAction.complete,
            true
          ),
          (
            WawatContent.text(content, 'notifications.action.view'),
            _InlineAction.view,
            false
          ),
        ],
      _ => [
          (
            WawatContent.text(content, 'notifications.action.accept'),
            _InlineAction.accept,
            true
          ),
          (
            WawatContent.text(content, 'notifications.action.decline'),
            _InlineAction.decline,
            false
          ),
          (
            WawatContent.text(content, 'notifications.action.view'),
            _InlineAction.view,
            false
          ),
        ],
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          GestureDetector(
            onTap: () => onAction(action.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: action.$3
                    ? _brand
                    : (isDark
                        ? WawatDark.surfaceAlt
                        : _ink900.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                action.$1,
                style: TextStyle(
                  color: action.$3
                      ? Colors.white
                      : (isDark ? WawatDark.textSecondary : _ink600),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SwipeAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const _SwipeAction({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _ActionsSheet extends StatelessWidget {
  final NotificationItem item;
  final Map<String, String> content;
  final bool isDark;
  final VoidCallback onRead;
  final VoidCallback onOpen;
  final VoidCallback onMute;
  final VoidCallback onDelete;

  const _ActionsSheet({
    required this.item,
    required this.content,
    required this.isDark,
    required this.onRead,
    required this.onOpen,
    required this.onMute,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _notificationVisual(item.type, isDark);
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isDark ? WawatDark.grab : _ink200,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: meta.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(meta.icon, color: meta.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? WawatDark.textPrimary : _ink900,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.body != null)
                      Text(
                        item.body!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? WawatDark.textSecondary : _ink500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SheetAction(
            icon: PhosphorIconsRegular.checkCircle,
            label: WawatContent.text(
              content,
              'notifications.sheet.mark_read',
            ),
            isDark: isDark,
            onTap: onRead,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.arrowSquareOut,
            label: WawatContent.text(content, 'notifications.sheet.open'),
            isDark: isDark,
            onTap: onOpen,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.bellSlash,
            label: WawatContent.text(
              content,
              'notifications.sheet.mute_type',
            ),
            isDark: isDark,
            onTap: onMute,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.trash,
            label: WawatContent.text(content, 'notifications.sheet.delete'),
            danger: true,
            isDark: isDark,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    this.danger = false,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: danger ? _red : (isDark ? WawatDark.icon : _ink500),
              size: 21,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color:
                    danger ? _red : (isDark ? WawatDark.textPrimary : _ink800),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onExplore;
  final Map<String, String> content;
  final bool isDark;

  const _EmptyState({
    required this.onExplore,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.brandSoft : _brand50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                PhosphorIconsRegular.bell,
                color: isDark ? cBrandText(true) : _brand,
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              WawatContent.text(
                content,
                'notifications.empty_title',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? WawatDark.textPrimary : _ink900,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              WawatContent.text(
                content,
                'notifications.empty_subtitle',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink500,
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: onExplore,
              child: Container(
                width: 210,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.brandSoft : _brand50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIconsRegular.magnifyingGlass,
                        color: isDark ? cBrandText(true) : _brand, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      WawatContent.text(
                        content,
                        'notifications.empty_action',
                      ),
                      style: TextStyle(
                        color: isDark ? cBrandText(true) : _brand,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  final bool isDark;

  const _SkeletonList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Skeleton(width: 40, height: 40, radius: 12, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Skeleton(width: 180, height: 14, radius: 4, isDark: isDark),
                  const SizedBox(height: 8),
                  _Skeleton(
                      width: double.infinity,
                      height: 12,
                      radius: 4,
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _Skeleton(width: 68, height: 10, radius: 4, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final bool isDark;

  const _Skeleton({
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
        color: isDark ? WawatDark.skeletonBase : const Color(0xFFE7EBF1),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

enum _InlineAction { accept, decline, view, complete }

class _NotificationVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const _NotificationVisual(this.icon, this.color, this.background);
}

_NotificationVisual _notificationVisual(String type, [bool isDark = false]) {
  // Тёмный режим: пастельные подложки → графит (акцент — мягкая синяя),
  // акцентные цвета иконок остаются яркими и читаемыми на #1E1E1E.
  final Color brandFg = isDark ? WawatDark.brandText : _brand;
  final Color brandBg = isDark ? WawatDark.brandChip : _brand50;
  final Color emeraldFg = isDark ? WawatDark.success : _emerald;
  final Color emeraldBg = isDark ? WawatDark.successBg : _emerald50;
  final Color redFg = isDark ? WawatDark.dangerText : _red;
  final Color redBg = isDark ? WawatDark.dangerSoftBg : _red50;
  final Color amberFg = isDark ? WawatDark.warning : _amber;
  final Color amberBg = isDark ? WawatDark.warningBg : _amber50;
  final Color neutralFg = isDark ? WawatDark.textSecondary : _ink500;
  final Color neutralBg =
      isDark ? WawatDark.surfaceAlt : const Color(0x0D0F172A);
  final Color accentBg = isDark ? WawatDark.goldSoftBg : _accent50;
  return switch (type) {
    'proposal_received' =>
      _NotificationVisual(PhosphorIconsFill.handshake, brandFg, brandBg),
    'proposal_countered' =>
      _NotificationVisual(PhosphorIconsFill.arrowsClockwise, brandFg, brandBg),
    'proposal_accepted' ||
    'shipment_auto_completed' ||
    'listing_approved' =>
      _NotificationVisual(PhosphorIconsFill.checkCircle, emeraldFg, emeraldBg),
    'proposal_declined' ||
    'listing_rejected' ||
    'verification_rejected' =>
      _NotificationVisual(PhosphorIconsFill.xCircle, redFg, redBg),
    'shipment_picked_up' =>
      _NotificationVisual(PhosphorIconsFill.package, brandFg, brandBg),
    'shipment_delivered' =>
      _NotificationVisual(PhosphorIconsFill.shoppingBag, brandFg, brandBg),
    'shipment_completed' ||
    'account_verified' =>
      _NotificationVisual(PhosphorIconsFill.sealCheck, emeraldFg, emeraldBg),
    'shipment_disputed' =>
      _NotificationVisual(PhosphorIconsFill.warningOctagon, redFg, redBg),
    'shipment_cancelled' ||
    'account_suspended' =>
      _NotificationVisual(PhosphorIconsFill.prohibit, redFg, redBg),
    'shipment_expired' || 'listing_expired' => _NotificationVisual(
        PhosphorIconsFill.clockCountdown, neutralFg, neutralBg),
    'dispute_resolved' =>
      _NotificationVisual(PhosphorIconsFill.scales, emeraldFg, emeraldBg),
    'counterparty_account_issue' =>
      _NotificationVisual(PhosphorIconsFill.warningCircle, amberFg, amberBg),
    'proposal_expiring' ||
    'verification_processing' =>
      _NotificationVisual(PhosphorIconsFill.hourglass, amberFg, amberBg),
    'listing_expiring' =>
      _NotificationVisual(PhosphorIconsFill.hourglassMedium, amberFg, amberBg),
    'delivery_confirm_reminder' =>
      _NotificationVisual(PhosphorIconsFill.bellRinging, amberFg, amberBg),
    'trip_reminder' =>
      _NotificationVisual(PhosphorIconsFill.airplaneTakeoff, brandFg, brandBg),
    'matching_listing' =>
      _NotificationVisual(PhosphorIconsFill.sparkle, brandFg, brandBg),
    'new_message' =>
      _NotificationVisual(PhosphorIconsFill.chatCircle, brandFg, brandBg),
    'message_awaiting_reply' =>
      _NotificationVisual(PhosphorIconsFill.chatsCircle, amberFg, amberBg),
    'review_received' ||
    'review_reminder' =>
      _NotificationVisual(PhosphorIconsFill.star, amberFg, amberBg),
    'review_prompt' =>
      _NotificationVisual(PhosphorIconsFill.star, brandFg, brandBg),
    'review_request' =>
      _NotificationVisual(PhosphorIconsFill.starHalf, brandFg, brandBg),
    'new_follower' =>
      _NotificationVisual(PhosphorIconsFill.userPlus, brandFg, brandBg),
    'followed_user_listing' =>
      _NotificationVisual(PhosphorIconsFill.bell, brandFg, brandBg),
    'saved_search_match' =>
      _NotificationVisual(PhosphorIconsFill.bookmarkSimple, brandFg, brandBg),
    'system_announcement' =>
      _NotificationVisual(PhosphorIconsFill.megaphone, brandFg, brandBg),
    'milestone_reached' =>
      _NotificationVisual(PhosphorIconsFill.trophy, amberFg, accentBg),
    'inactive_winback' ||
    'welcome' =>
      _NotificationVisual(PhosphorIconsFill.handWaving, brandFg, brandBg),
    'account_warning' =>
      _NotificationVisual(PhosphorIconsFill.warning, amberFg, amberBg),
    'content_removed' =>
      _NotificationVisual(PhosphorIconsFill.trash, redFg, redBg),
    'report_received_ack' =>
      _NotificationVisual(PhosphorIconsFill.shieldCheck, brandFg, brandBg),
    'new_device_login' =>
      _NotificationVisual(PhosphorIconsFill.deviceMobile, amberFg, amberBg),
    'password_changed' =>
      _NotificationVisual(PhosphorIconsFill.lockKey, brandFg, brandBg),
    'email_changed' =>
      _NotificationVisual(PhosphorIconsFill.envelopeSimple, brandFg, brandBg),
    'app_update_required' =>
      _NotificationVisual(PhosphorIconsFill.downloadSimple, brandFg, brandBg),
    _ => _NotificationVisual(PhosphorIconsFill.bell, brandFg, brandBg),
  };
}

String _groupLabel(String createdAt) {
  final date = DateTime.tryParse(createdAt)?.toLocal();
  if (date == null) return 'Köhnə';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final itemDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(itemDay).inDays;
  if (diff == 0) return 'Bu gün';
  if (diff == 1) return 'Dünən';
  if (diff < 7) return 'Bu həftə';
  return 'Köhnə';
}

String _relativeTime(String createdAt) {
  final date = DateTime.tryParse(createdAt)?.toLocal();
  if (date == null) return createdAt;
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'indi';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dəqiqə əvvəl';
  if (diff.inHours < 24) return '${diff.inHours} saat əvvəl';
  if (diff.inDays == 1) return 'Dünən';
  if (diff.inDays < 7) return '${diff.inDays} gün əvvəl';
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
