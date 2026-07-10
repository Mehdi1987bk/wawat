import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/notification_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../services/wawat_content.dart';
import '../../listings/details/listing_details_screen.dart';
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
    WawatContent.load().then((content) {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _screenBg,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                onBack: () => Navigator.of(context).maybePop(),
                onReadAll: bloc.markAllAsRead,
                unreadCount: bloc.unreadCount,
                unreadOnly: bloc.unreadOnly,
                content: _content,
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
                          return const _SkeletonList();
                        }
                        if (items.isEmpty) {
                          return _EmptyState(
                            content: _content,
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
                                      _DateHeader(entry.key),
                                      ...entry.value.map(_buildItem),
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

  Widget _buildItem(NotificationItem item) {
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
      ),
    );
  }

  Future<void> _openNotification(NotificationItem item) async {
    if (item.isUnread) await bloc.markAsRead(item.id);
    if (!mounted) return;
    final listingId = item.data.listingId;
    if (listingId != null && listingId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListingDetailsScreen(listingId: listingId),
        ),
      );
      return;
    }
    _showMessage(_t('notifications.opened'));
  }

  Future<void> _showActions(NotificationItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActionsSheet(
        item: item,
        content: _content,
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
  final ValueChanged<bool> onUnreadChanged;

  const _Header({
    required this.onBack,
    required this.onReadAll,
    required this.unreadCount,
    required this.unreadOnly,
    required this.content,
    required this.onUnreadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _ink900.withValues(alpha: 0.06)),
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
                  child: const Icon(
                    PhosphorIconsBold.arrowLeft,
                    color: _ink700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    WawatContent.text(content, 'notifications.title'),
                    style: const TextStyle(
                      color: _ink900,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onReadAll,
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsBold.checks,
                          color: _brand, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        WawatContent.text(content, 'notifications.read_all'),
                        style: const TextStyle(
                          color: _brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
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
                    color: _ink900.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _SegmentButton(
                        label:
                            WawatContent.text(content, 'notifications.tab_all'),
                        selected: !selectedUnread,
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
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    this.count,
    required this.selected,
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
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
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
                  color: selected ? _brand : _ink500,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w800,
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

  const _DateHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: _ink400,
          fontSize: 11,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w900,
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

  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.onAction,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _notificationVisual(item.type);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: item.isUnread ? _brand.withValues(alpha: 0.045) : Colors.white,
          border: Border(
            bottom: BorderSide(color: _ink900.withValues(alpha: 0.05)),
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
                          style: const TextStyle(
                            color: _ink900,
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (item.isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: _brand,
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
                      style: const TextStyle(
                        color: _ink500,
                        fontSize: 12.5,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _relativeTime(item.createdAt),
                    style: const TextStyle(
                      color: _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.isInteractive) ...[
                    const SizedBox(height: 10),
                    _InlineActions(
                      type: item.type,
                      onAction: onAction,
                      content: content,
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

  const _InlineActions({
    required this.type,
    required this.onAction,
    required this.content,
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
                color: action.$3 ? _brand : _ink900.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                action.$1,
                style: TextStyle(
                  color: action.$3 ? Colors.white : _ink600,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
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
  final VoidCallback onRead;
  final VoidCallback onOpen;
  final VoidCallback onMute;
  final VoidCallback onDelete;

  const _ActionsSheet({
    required this.item,
    required this.content,
    required this.onRead,
    required this.onOpen,
    required this.onMute,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _notificationVisual(item.type);
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: _ink200,
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
                      style: const TextStyle(
                        color: _ink900,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.body != null)
                      Text(
                        item.body!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
            onTap: onRead,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.arrowSquareOut,
            label: WawatContent.text(content, 'notifications.sheet.open'),
            onTap: onOpen,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.bellSlash,
            label: WawatContent.text(
              content,
              'notifications.sheet.mute_type',
            ),
            onTap: onMute,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.trash,
            label: WawatContent.text(content, 'notifications.sheet.delete'),
            danger: true,
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
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    this.danger = false,
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
            Icon(icon, color: danger ? _red : _ink500, size: 21),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: danger ? _red : _ink800,
                fontSize: 14,
                fontWeight: FontWeight.w900,
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

  const _EmptyState({required this.onExplore, required this.content});

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
                color: _brand50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                PhosphorIconsRegular.bell,
                color: _brand,
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
              style: const TextStyle(
                color: _ink900,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              WawatContent.text(
                content,
                'notifications.empty_subtitle',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink500,
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
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
                  color: _brand50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsRegular.magnifyingGlass,
                        color: _brand, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      WawatContent.text(
                        content,
                        'notifications.empty_action',
                      ),
                      style: const TextStyle(
                        color: _brand,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const _Skeleton(width: 40, height: 40, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Skeleton(width: 180, height: 14, radius: 4),
                  SizedBox(height: 8),
                  _Skeleton(width: double.infinity, height: 12, radius: 4),
                  SizedBox(height: 8),
                  _Skeleton(width: 68, height: 10, radius: 4),
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

  const _Skeleton({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EBF1),
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

_NotificationVisual _notificationVisual(String type) {
  return switch (type) {
    'proposal_received' =>
      const _NotificationVisual(PhosphorIconsFill.handshake, _brand, _brand50),
    'proposal_countered' => const _NotificationVisual(
        PhosphorIconsFill.arrowsClockwise, _brand, _brand50),
    'proposal_accepted' ||
    'shipment_auto_completed' ||
    'listing_approved' =>
      const _NotificationVisual(
          PhosphorIconsFill.checkCircle, _emerald, _emerald50),
    'proposal_declined' ||
    'listing_rejected' ||
    'verification_rejected' =>
      const _NotificationVisual(PhosphorIconsFill.xCircle, _red, _red50),
    'shipment_picked_up' =>
      const _NotificationVisual(PhosphorIconsFill.package, _brand, _brand50),
    'shipment_delivered' => const _NotificationVisual(
        PhosphorIconsFill.shoppingBag, _brand, _brand50),
    'shipment_completed' || 'account_verified' => const _NotificationVisual(
        PhosphorIconsFill.sealCheck, _emerald, _emerald50),
    'shipment_disputed' =>
      const _NotificationVisual(PhosphorIconsFill.warningOctagon, _red, _red50),
    'shipment_cancelled' ||
    'account_suspended' =>
      const _NotificationVisual(PhosphorIconsFill.prohibit, _red, _red50),
    'shipment_expired' || 'listing_expired' => const _NotificationVisual(
        PhosphorIconsFill.clockCountdown, _ink500, Color(0x0D0F172A)),
    'dispute_resolved' =>
      const _NotificationVisual(PhosphorIconsFill.scales, _emerald, _emerald50),
    'counterparty_account_issue' => const _NotificationVisual(
        PhosphorIconsFill.warningCircle, _amber, _amber50),
    'proposal_expiring' ||
    'verification_processing' =>
      const _NotificationVisual(PhosphorIconsFill.hourglass, _amber, _amber50),
    'listing_expiring' => const _NotificationVisual(
        PhosphorIconsFill.hourglassMedium, _amber, _amber50),
    'delivery_confirm_reminder' => const _NotificationVisual(
        PhosphorIconsFill.bellRinging, _amber, _amber50),
    'trip_reminder' => const _NotificationVisual(
        PhosphorIconsFill.airplaneTakeoff, _brand, _brand50),
    'matching_listing' =>
      const _NotificationVisual(PhosphorIconsFill.sparkle, _brand, _brand50),
    'new_message' =>
      const _NotificationVisual(PhosphorIconsFill.chatCircle, _brand, _brand50),
    'message_awaiting_reply' => const _NotificationVisual(
        PhosphorIconsFill.chatsCircle, _amber, _amber50),
    'review_received' ||
    'review_reminder' =>
      const _NotificationVisual(PhosphorIconsFill.star, _amber, _amber50),
    'review_prompt' =>
      const _NotificationVisual(PhosphorIconsFill.star, _brand, _brand50),
    'review_request' =>
      const _NotificationVisual(PhosphorIconsFill.starHalf, _brand, _brand50),
    'new_follower' =>
      const _NotificationVisual(PhosphorIconsFill.userPlus, _brand, _brand50),
    'followed_user_listing' =>
      const _NotificationVisual(PhosphorIconsFill.bell, _brand, _brand50),
    'saved_search_match' => const _NotificationVisual(
        PhosphorIconsFill.bookmarkSimple, _brand, _brand50),
    'system_announcement' =>
      const _NotificationVisual(PhosphorIconsFill.megaphone, _brand, _brand50),
    'milestone_reached' =>
      const _NotificationVisual(PhosphorIconsFill.trophy, _amber, _accent50),
    'inactive_winback' ||
    'welcome' =>
      const _NotificationVisual(PhosphorIconsFill.handWaving, _brand, _brand50),
    'account_warning' =>
      const _NotificationVisual(PhosphorIconsFill.warning, _amber, _amber50),
    'content_removed' =>
      const _NotificationVisual(PhosphorIconsFill.trash, _red, _red50),
    'report_received_ack' => const _NotificationVisual(
        PhosphorIconsFill.shieldCheck, _brand, _brand50),
    'new_device_login' => const _NotificationVisual(
        PhosphorIconsFill.deviceMobile, _amber, _amber50),
    'password_changed' =>
      const _NotificationVisual(PhosphorIconsFill.lockKey, _brand, _brand50),
    'email_changed' => const _NotificationVisual(
        PhosphorIconsFill.envelopeSimple, _brand, _brand50),
    'app_update_required' => const _NotificationVisual(
        PhosphorIconsFill.downloadSimple, _brand, _brand50),
    _ => const _NotificationVisual(PhosphorIconsFill.bell, _brand, _brand50),
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
