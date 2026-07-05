import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../../listings/details/listing_details_screen.dart';
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

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    bloc.loadPackageTypes();
    bloc.load();
    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_scrollController.position.extentAfter <=
          MediaQuery.of(context).size.height) {
        bloc.load();
      }
    });
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
                      SliverToBoxAdapter(child: _Header(isDark: isDark)),
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
                            return const SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyMine(),
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
                                onDetailsTap: _openDetails,
                                onPauseTap: (item) => bloc.pauseListing(item),
                                onResumeTap: (item) => bloc.resumeListing(item),
                                onRepostTap: (item) => bloc.repostListing(item),
                                onDeleteTap: _confirmDelete,
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

  void _openDetails(Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailsScreen(listingId: listing.id),
      ),
    );
  }

  Future<void> _confirmDelete(Listing listing) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DeleteReasonSheet(),
    );
    if (reason == null) return;
    await bloc.deleteListing(listing, reasonCode: reason);
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

  const _Header({required this.isDark});

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
                  'Mənim elanlarım',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Status, baxış və idarəetmə',
                  style: TextStyle(
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
  const _DeleteReasonSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasons = const {
      'plans_changed': 'Planlarım dəyişdi',
      'found_another': 'Başqa variant tapdım',
      'no_longer_needed': 'Artıq lazım deyil',
      'created_by_mistake': 'Səhvən yaratdım',
      'other': 'Digər',
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
            'Silinmə səbəbi',
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
  const _EmptyMine();

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
              'Hələ elan yoxdur',
              style: TextStyle(
                color: isDark ? Colors.white : _ink900Local,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni səfər və ya göndəriş elanı yaratmaq üçün ortadakı + tabına keç.',
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
