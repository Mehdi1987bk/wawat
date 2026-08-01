import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/my_listings_result.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../../../../../services/wawat_content.dart';
import '../../create_post/create_post_screen.dart';
import '../../listings/details/listing_details_screen.dart';
import '../../listings/promotion/promotion_screens.dart';
import '../../listings/widgets/listing_card.dart';
import 'delivery_full_list_bloc.dart';

const _brand = Color(0xFF0271EB);
const _ink900Local = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

class DeliveryFullListScreen extends BaseScreen<DeliveryFullListBloc> {
  final bool detailsReturnToHome;

  DeliveryFullListScreen({
    super.key,
    this.detailsReturnToHome = false,
  });

  @override
  State<DeliveryFullListScreen> createState() => _DeliveryFullListScreenState();
}

class _DeliveryFullListScreenState
    extends BaseState<DeliveryFullListScreen, DeliveryFullListBloc> {
  final ScrollController _scrollController = ScrollController();
  Map<String, String> _content = const {};

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    bloc.loadPackageTypes();
    bloc.load();
    WawatContent.loadDefault().then((content) {
      if (mounted) setState(() => _content = content);
    });
    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_scrollController.position.extentAfter <=
          MediaQuery.of(context).size.height) {
        bloc.load();
      }
    });
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(_content, key, fallback);
  }

  Future<void> _onFilterSelected(String key) async {
    final ok = await bloc.setFilter(key);
    if (!ok && mounted) {
      _showError(
          _t('common.operation_failed', 'Xəta baş verdi. Yenidən cəhd et.'));
    }
  }

  /// Label of the active filter when it is a specific (non-`all`) one — used to
  /// tailor the empty state ("no listings under <filter>"). Null for `all`.
  String? _activeFilterLabel() {
    final key = bloc.activeFilterKey;
    if (key == 'all') return null;
    for (final f in bloc.currentFilters) {
      if (f.key == key) return f.label;
    }
    return null;
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return ThemeAwareScreen(
          isDark: isDark,
          lightBackgroundColor: const Color(0xFFEEF1F6),
          darkBackgroundColor: WawatDark.bg,
          child: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  color: _brand,
                  onRefresh: bloc.loadList,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(isDark: isDark, content: _content),
                      ),
                      SliverToBoxAdapter(
                        child: StreamBuilder<List<ListingFilterOption>>(
                          stream: bloc.filters,
                          builder: (context, filtersSnap) {
                            final filters = filtersSnap.data ?? const [];
                            if (filters.isEmpty) return const SizedBox.shrink();
                            return StreamBuilder<String>(
                              stream: bloc.activeFilter,
                              initialData: bloc.activeFilterKey,
                              builder: (context, activeSnap) {
                                return _FilterDropdown(
                                  isDark: isDark,
                                  content: _content,
                                  filters: filters,
                                  activeKey: activeSnap.data ?? 'all',
                                  onSelect: _onFilterSelected,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      StreamBuilder<List<Listing>>(
                        stream: bloc.paginableList,
                        builder: (context, snapshot) {
                          final listings = snapshot.data;
                          if (listings == null) {
                            return const SliverToBoxAdapter(
                              child: _MyListingsSkeleton(),
                            );
                          }
                          if (listings.isEmpty) {
                            return SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyMine(
                                content: _content,
                                filterLabel: _activeFilterLabel(),
                              ),
                            );
                          }
                          return SliverList.builder(
                            itemCount: listings.length + 1,
                            itemBuilder: (context, index) {
                              if (index == listings.length) {
                                return const SizedBox(height: 32);
                              }
                              final listing = listings[index];
                              return ListingCard(
                                listing: listing,
                                packageNamesByCode: bloc.packageNamesByCode,
                                isOwner: true,
                                isCompact: true,
                                onDetailsTap: (item) => _openDetails(item),
                                onPauseTap: _confirmPause,
                                onResumeTap: _confirmResume,
                                onRepostTap: _confirmRepost,
                                onDeleteTap: _confirmDelete,
                                onVipTap: (item) => _openPromotion(item, 'vip'),
                                onBoostTap: (item) => _openPromotion(
                                  item,
                                  'featured',
                                  forceNew: (item.promotion?.type ??
                                          item.promotionType) ==
                                      'featured',
                                ),
                                onPromotionExtendTap: (item) => _openPromotion(
                                  item,
                                  item.promotion?.type ??
                                      item.promotionType ??
                                      'vip',
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: bloc.isUpdating,
                  initialData: false,
                  builder: (context, snapshot) {
                    if (snapshot.data != true) return const SizedBox.shrink();
                    return Container(
                      color: isDark
                          ? WawatDark.scrim
                          : Colors.black.withValues(alpha: 0.35),
                      child: const Center(
                        child: CircularProgressIndicator(color: _brand),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDetails(Listing listing) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailsScreen(
          listingId: listing.id,
          returnToHomeOnBack: widget.detailsReturnToHome,
        ),
      ),
    );
    if (!mounted) return;
    await bloc.loadList();
  }

  Future<void> _openPromotion(
    Listing listing,
    String type, {
    bool forceNew = false,
  }) async {
    await openPromotionFlow(
      context,
      listing: listing,
      type: type,
      forceNew: forceNew,
    );
    if (!mounted) return;
    await bloc.loadList();
  }

  Future<void> _confirmPause(Listing listing) async {
    final confirmed = await _confirmAction(
      title: _t('my_listings.pause_confirm_title'),
      message: _t(
        'my_listings.pause_confirm_message',
      ),
      confirmLabel: _t('common.pause'),
    );
    if (!confirmed) return;
    try {
      final message = await bloc.pauseListing(listing);
      if (!mounted) return;
      _showSuccess(message ?? _t('listing.paused'));
    } catch (_) {
      if (!mounted) return;
      _showError(_t('common.operation_failed'));
    }
  }

  Future<void> _confirmResume(Listing listing) async {
    final confirmed = await _confirmAction(
      title: _t('my_listings.resume_confirm_title'),
      message: _t(
        'my_listings.resume_confirm_message',
      ),
      confirmLabel: _t('my_listings.resume'),
    );
    if (!confirmed) return;
    try {
      // Resume may return to moderation (not active) — show the backend's
      // localized message; loadList() already refreshes the shown status.
      final message = await bloc.resumeListing(listing);
      if (!mounted) return;
      _showSuccess(message ?? _t('listing.resumed'));
    } catch (_) {
      if (!mounted) return;
      _showError(_t('common.operation_failed'));
    }
  }

  Future<void> _confirmRepost(Listing listing) async {
    // Don't fire /repost with the old (past) date — it 422s. Open the publish
    // form pre-filled from this listing (minus the date); it submits POST
    // /listings/{id}/repost with the new future date, creating a fresh listing
    // in moderation, and surfaces any 4xx `message` (past date, quota limit).
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CreatePostScreen(repostListing: listing),
      ),
    );
  }

  Future<void> _confirmDelete(Listing listing) async {
    final confirmed = await _confirmAction(
      title: _t('my_listings.delete_confirm_title'),
      message: _t(
        'my_listings.delete_confirm_message',
      ),
      confirmLabel: _t('common.delete'),
      isDanger: true,
    );
    if (!confirmed) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reason = await showAppBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : null,
      builder: (_) => _DeleteReasonSheet(content: _content),
    );
    if (reason == null) return;
    try {
      await bloc.deleteListing(listing, reasonCode: reason);
      if (!mounted) return;
      _showSuccess(_t('listing.deleted'));
    } catch (_) {
      if (!mounted) return;
      _showError(_t('common.operation_failed'));
    }
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmActionDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDanger: isDanger,
      ),
    );
    return result == true;
  }

  void _showSuccess(String message) {
    _showToast(message, const Color(0xFF10B981), Icons.check_circle);
  }

  void _showError(String message) {
    _showToast(message, const Color(0xFFEF4444), Icons.error);
  }

  void _showToast(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  DeliveryFullListBloc provideBloc() {
    return DeliveryFullListBloc();
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  final Map<String, String> content;

  const _Header({required this.isDark, required this.content});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? cText(isDark) : _ink900Local;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.arrow_back, color: titleColor),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WawatContent.text(
                    content,
                    'my_listings.title',
                  ),
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  WawatContent.text(
                    content,
                    'my_listings.subtitle',
                  ),
                  style: TextStyle(
                    color: isDark ? cMuted(isDark) : _ink400,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Data-driven filter trigger. Fully rendered from `meta.filters`: the active
/// option's label + count and a chevron; tapping opens the picker sheet.
class _FilterDropdown extends StatelessWidget {
  final bool isDark;
  final Map<String, String> content;
  final List<ListingFilterOption> filters;
  final String activeKey;
  final ValueChanged<String> onSelect;

  const _FilterDropdown({
    required this.isDark,
    required this.content,
    required this.filters,
    required this.activeKey,
    required this.onSelect,
  });

  ListingFilterOption get _active => filters.firstWhere(
        (f) => f.key == activeKey,
        orElse: () => filters.first,
      );

  Future<void> _open(BuildContext context) async {
    final selected = await showAppBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        content: content,
        filters: filters,
        activeKey: activeKey,
      ),
    );
    if (selected != null) onSelect(selected);
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    final brandFg = isDark ? cBrandText(isDark) : _brand;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? cCard(isDark) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? WawatDark.border : _brand.withValues(alpha: 0.16),
          ),
          boxShadow: cCardShadow(
            isDark,
            const [
              BoxShadow(
                color: Color(0x14017BFE),
                blurRadius: 18,
                offset: Offset(0, 8),
                spreadRadius: -8,
              ),
            ],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Brand icon chip — gives the control visual weight.
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cBrandSoft(isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(PhosphorIconsFill.funnelSimple,
                        size: 20, color: brandFg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WawatContent.text(
                                  content, 'my_listings.filter_title', 'Filtr')
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? cMuted(isDark) : _ink400,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                active.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? cText(isDark) : _ink900Local,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            _CountBadge(count: active.count, isDark: isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Caret chip — clear "opens a dropdown" affordance.
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cBrandSoft(isDark),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIconsBold.caretDown,
                        size: 15, color: brandFg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet picker listing every option from `meta.filters` — label +
/// count badge, the active one highlighted. Returns the chosen key.
class _FilterSheet extends StatelessWidget {
  final Map<String, String> content;
  final List<ListingFilterOption> filters;
  final String activeKey;

  const _FilterSheet({
    required this.content,
    required this.filters,
    required this.activeKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cCard(isDark) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Reserve the OS navigation-bar inset (the sheet helper doesn't).
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.grab : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            WawatContent.text(content, 'my_listings.filter_title', 'Filtr'),
            style: TextStyle(
              color: isDark ? cText(isDark) : _ink900Local,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final option in filters)
            _FilterRow(
              option: option,
              selected: option.key == activeKey,
              isDark: isDark,
              onTap: () => Navigator.pop(context, option.key),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final ListingFilterOption option;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterRow({
    required this.option,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brandFg = isDark ? cBrandText(isDark) : _brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? cBrandSoft(isDark)
              : (isDark ? cFill(isDark) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: cBrandFill.withValues(alpha: 0.9), width: 1.4)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? brandFg
                      : (isDark ? cText(isDark) : _ink900Local),
                  fontSize: 14.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _CountBadge(count: option.count, isDark: isDark, strong: selected),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(PhosphorIconsFill.checkCircle, size: 18, color: brandFg),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small brand-tinted count pill (e.g. the «(2)» after a filter label).
class _CountBadge extends StatelessWidget {
  final int count;
  final bool isDark;
  final bool strong;

  const _CountBadge({
    required this.count,
    required this.isDark,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: strong
            ? cBrandFill
            : (isDark ? WawatDark.brandChip : const Color(0xFFEAF3FE)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: strong ? Colors.white : (isDark ? cBrandText(isDark) : _brand),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DeleteReasonSheet extends StatelessWidget {
  final Map<String, String> content;

  const _DeleteReasonSheet({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasons = {
      'plans_changed': WawatContent.text(
          content, 'enum.listing_delete_reason.plans_changed'),
      'found_another': WawatContent.text(
          content, 'enum.listing_delete_reason.found_another'),
      'no_longer_needed': WawatContent.text(
          content, 'enum.listing_delete_reason.no_longer_needed'),
      'created_by_mistake': WawatContent.text(
          content, 'enum.listing_delete_reason.created_by_mistake'),
      'other': WawatContent.text(content, 'enum.listing_delete_reason.other'),
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cCard(isDark) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Reserve the OS navigation-bar inset so the last reason clears the
      // gesture/back bar (showAppBottomSheet doesn't apply bottom safe-area).
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 26 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.grab : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            WawatContent.text(
              content,
              'my_listings.delete_reason_title',
            ),
            style: TextStyle(
              color: isDark ? cText(isDark) : _ink900Local,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...reasons.entries.map(
            (entry) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.pop(context, entry.key),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? cFill(isDark) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isDark ? cText(isDark) : _ink900Local,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;

  const _ConfirmActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? cText(isDark) : _ink900Local;
    final primary = isDanger
        ? (isDark ? WawatDark.danger : const Color(0xFFEF4444))
        : _brand;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? cCard(isDark) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: isDark ? cText2(isDark) : _ink500,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? cFill(isDark) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Ləğv et',
                        style: TextStyle(
                          color: isDark ? cMuted(isDark) : _ink500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyListingsSkeleton extends StatelessWidget {
  const _MyListingsSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? WawatDark.skeletonBase : const Color(0xFFE7EBF1),
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMine extends StatelessWidget {
  final Map<String, String> content;

  /// When a specific (non-`all`) filter is active but yields nothing, this is
  /// its label — the copy then reads "no listings under <filter>" instead of
  /// the first-time "create your first listing" prompt.
  final String? filterLabel;

  const _EmptyMine({required this.content, this.filterLabel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = filterLabel != null;
    final title = filtered
        ? WawatContent.text(
            content, 'my_listings.filter_empty_title', 'Elan yoxdur')
        : WawatContent.text(content, 'my_listings.empty_title');
    final subtitle = filtered
        ? WawatContent.text(
            content,
            'my_listings.filter_empty_subtitle',
            'Bu filter üzrə elan tapılmadı.',
          )
        : WawatContent.text(content, 'my_listings.empty_subtitle');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered
                  ? PhosphorIconsRegular.funnelSimple
                  : Icons.inbox_outlined,
              color: isDark ? cBrandText(isDark) : _brand,
              size: 64,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? cText(isDark) : _ink900Local,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? cText2(isDark) : _ink500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
