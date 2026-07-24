import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../../../../../services/wawat_content.dart';
import '../../listings/details/listing_details_screen.dart';
import '../../listings/promotion/promotion_screens.dart';
import '../../listings/widgets/listing_card.dart';
import 'delivery_full_list_bloc.dart';

const _brand = Color(0xFF0271EB);
const _ink900Local = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

class DeliveryFullListScreen extends BaseScreen<DeliveryFullListBloc> {
  DeliveryFullListScreen({super.key});

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

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return ThemeAwareScreen(
          isDark: isDark,
          lightBackgroundColor: const Color(0xFFEEF1F6),
          darkBackgroundColor: const Color(0xFF101010),
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
                              child: _EmptyMine(content: _content),
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
                      color: Colors.black.withValues(alpha: 0.35),
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
        builder: (_) => ListingDetailsScreen(listingId: listing.id),
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
      await bloc.pauseListing(listing);
      if (!mounted) return;
      _showSuccess(_t('listing.paused'));
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
      await bloc.resumeListing(listing);
      if (!mounted) return;
      _showSuccess(_t('listing.resumed'));
    } catch (_) {
      if (!mounted) return;
      _showError(_t('common.operation_failed'));
    }
  }

  Future<void> _confirmRepost(Listing listing) async {
    final confirmed = await _confirmAction(
      title: _t('my_listings.repost_confirm_title'),
      message: _t(
        'my_listings.repost_confirm_message',
      ),
      confirmLabel: _t('my_listings.repost'),
    );
    if (!confirmed) return;
    try {
      await bloc.repostListing(listing);
      if (!mounted) return;
      _showSuccess(_t('listing.reposted'));
    } catch (_) {
      if (!mounted) return;
      _showError(_t('common.operation_failed'));
    }
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
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
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
    final titleColor = isDark ? Colors.white : _ink900Local;
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  WawatContent.text(
                    content,
                    'my_listings.subtitle',
                  ),
                  style: const TextStyle(
                    color: _ink400,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
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
              color: isDark ? Colors.white : _ink900Local,
              fontSize: 20,
              fontWeight: FontWeight.w900,
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
                  color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : _ink900Local,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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
    final titleColor = isDark ? Colors.white : _ink900Local;
    final primary = isDanger ? const Color(0xFFEF4444) : _brand;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white70 : _ink500,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
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
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Ləğv et',
                        style: TextStyle(
                          color: isDark ? Colors.white : _ink500,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
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
                          fontWeight: FontWeight.w900,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EBF1),
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

  const _EmptyMine({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: _brand, size: 64),
            const SizedBox(height: 14),
            Text(
              WawatContent.text(content, 'my_listings.empty_title'),
              style: TextStyle(
                color: isDark ? Colors.white : _ink900Local,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              WawatContent.text(
                content,
                'my_listings.empty_subtitle',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : _ink500,
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
