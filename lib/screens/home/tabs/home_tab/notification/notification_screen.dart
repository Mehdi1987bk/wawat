import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/notification_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/notification_router.dart';
import '../../../../../services/notification_socket_service.dart';
import '../../../../../services/notification_visual.dart';
import 'package:buking/services/localization_service.dart';
import '../../../../../services/wawat_content.dart';
import '../../profile_tab/tier/tier_status_screen.dart';
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
const _red = Color(0xFFEF4444);

class NotificationScreen extends BaseScreen<NotificationBloc> {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState
    extends BaseState<NotificationScreen, NotificationBloc>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  Map<String, String> _content = const {};
  StreamSubscription<void>? _notifChangedSub;

  /// Notifications whose inline accept/decline is mid-flight — their buttons
  /// dim, ignore taps (no double-submit), and show a spinner.
  final Set<String> _actingItemIds = {};

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    // A deal accepted/declined/confirmed elsewhere arrives as a general
    // notification → refresh the live is_interactive flag IN PLACE so the inline
    // buttons hide, without truncating the paginated list or jumping the scroll.
    _notifChangedSub =
        NotificationSocketService.instance.onNotificationsChanged.listen((_) {
      if (mounted) bloc.refreshInteractiveFlags();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning to the app refreshes is_interactive in place (non-destructive),
    // so resolved deals hide their buttons without collapsing the loaded list.
    if (state == AppLifecycleState.resumed && mounted) {
      bloc.refreshInteractiveFlags();
    }
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(_content, key, fallback);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifChangedSub?.cancel();
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
        busy: _actingItemIds.contains(item.id),
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
    // Level-up / milestone notifications carry no entity target — they open the
    // Statusum (tier) page.
    const tierTypes = {
      'milestone_reached',
      'new_level',
      'tier_upgraded',
      'level_up',
    };
    if (tierTypes.contains(item.type) ||
        {'tier', 'status', 'level'}.contains(item.target.type)) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const TierStatusScreen()));
      return;
    }
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
    switch (action) {
      case _InlineAction.accept:
        _runInlineDealAction(item, 'accept');
        break;
      case _InlineAction.decline:
        _runInlineDealAction(item, 'decline');
        break;
      case _InlineAction.view:
      case _InlineAction.complete:
        // Confirm-receipt is irreversible and counter/other flows need the full
        // deal UI (confirmation dialog, extra fields) — route to the deal screen
        // where those live, rather than firing a bare one-tap action.
        _openNotification(item);
        break;
    }
  }

  /// Runs the real proposal accept/decline for an inline button: the same
  /// `shipmentAction` the chat deal card uses (no body needed). The button shows
  /// a spinner while in flight; on success the item is resolved server-side so
  /// its now-false is_interactive hides the buttons. If the notification has no
  /// shipment id we open the deal screen instead of failing.
  Future<void> _runInlineDealAction(
    NotificationItem item,
    String action,
  ) async {
    if (_actingItemIds.contains(item.id)) return;
    setState(() => _actingItemIds.add(item.id));
    try {
      final message = await bloc.runInlineShipmentAction(item, action);
      if (!mounted) return;
      _showMessage(message ??
          _t(action == 'accept'
              ? 'notifications.request_accepted'
              : 'notifications.request_declined'));
    } on MissingShipmentException {
      if (mounted) _openNotification(item);
    } catch (_) {
      if (mounted) {
        _showMessage(
          _t('common.something_went_wrong',
              'Xəta baş verdi. Yenidən cəhd edin.'),
        );
      }
    } finally {
      if (mounted) setState(() => _actingItemIds.remove(item.id));
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
  final bool busy;
  final Map<String, String> content;
  final bool isDark;

  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.onAction,
    required this.busy,
    required this.content,
    required this.isDark,
  });

  /// Human types (with an actor) show the actor's avatar; system types show the
  /// rounded type-icon chip. Falls back to the icon if the image fails.
  Widget _leadingVisual(NotificationVisual meta) {
    final iconChip = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: meta.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(meta.icon, color: meta.color, size: 20),
    );
    final avatar = item.actor?.avatarThumbUrl;
    if (avatar == null || avatar.isEmpty) return iconChip;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: avatar,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (_, __) => iconChip,
        errorWidget: (_, __, ___) => iconChip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = notificationVisual(item.type, isDark);
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
            _leadingVisual(meta),
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
                      busy: busy,
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
  final bool busy;
  final Map<String, String> content;
  final bool isDark;

  const _InlineActions({
    required this.type,
    required this.onAction,
    required this.busy,
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
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final action in actions)
          Opacity(
            opacity: busy ? 0.45 : 1,
            child: GestureDetector(
              // Disable taps while an action is in flight — no double-submit.
              onTap: busy ? null : () => onAction(action.$2),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          ),
        if (busy)
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
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
    final meta = notificationVisual(item.type, isDark);
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

String _groupLabel(String createdAt) {
  final date = DateTime.tryParse(createdAt)?.toLocal();
  if (date == null) return tr('notification.group_old', 'Köhnə');
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final itemDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(itemDay).inDays;
  if (diff == 0) return tr('common.today', 'Bu gün');
  if (diff == 1) return tr('common.yesterday', 'Dünən');
  if (diff < 7) return tr('notification.group_this_week', 'Bu həftə');
  return tr('notification.group_old', 'Köhnə');
}

String _relativeTime(String createdAt) {
  final date = DateTime.tryParse(createdAt)?.toLocal();
  if (date == null) return createdAt;
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return tr('notification.time_now', 'indi');
  if (diff.inMinutes < 60) {
    return tr('notification.time_minutes_ago', '{count} dəqiqə əvvəl',
        {'count': '${diff.inMinutes}'});
  }
  if (diff.inHours < 24) {
    return tr('notification.time_hours_ago', '{count} saat əvvəl',
        {'count': '${diff.inHours}'});
  }
  if (diff.inDays == 1) return tr('common.yesterday', 'Dünən');
  if (diff.inDays < 7) {
    return tr('notification.time_days_ago', '{count} gün əvvəl',
        {'count': '${diff.inDays}'});
  }
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
