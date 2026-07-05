import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../widget/auth_modal_utils.dart';
import '../widget/search_form_page.dart';
import '../../listings/details/listing_details_screen.dart';
import '../../listings/listing_feed_bloc.dart';
import '../../listings/widgets/listing_card.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

class SearchOfferListScreen extends BaseScreen {
  final ListingFilterState filters;
  final bool showBackButton;

  SearchOfferListScreen({
    super.key,
    this.filters = const ListingFilterState(),
    this.showBackButton = true,
  });

  @override
  State<SearchOfferListScreen> createState() => _SearchOfferListScreenState();
}

class _SearchOfferListScreenState
    extends BaseState<SearchOfferListScreen, ListingFeedBloc> {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    bloc.setFilters(widget.filters);
    bloc.refreshList();
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
            child: RefreshIndicator(
              color: _brand,
              onRefresh: bloc.refreshList,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _TopBar(
                      onFilterTap: _showFilters,
                      showBackButton: widget.showBackButton,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SearchFormWidget(bloc: bloc, compact: true),
                  ),
                  SliverToBoxAdapter(
                    child: _ResultsHeader(bloc: bloc),
                  ),
                  StreamBuilder<List<Listing>>(
                    stream: bloc.paginableList,
                    builder: (context, snapshot) {
                      final listings = snapshot.data;
                      if (listings == null) {
                        return const SliverToBoxAdapter(
                            child: _SearchSkeleton());
                      }
                      if (listings.isEmpty) {
                        return SliverToBoxAdapter(
                          child: StreamBuilder(
                            stream: bloc.suggestions,
                            initialData: const [],
                            builder: (context, suggestionSnapshot) {
                              return _SearchEmpty(
                                suggestions:
                                    suggestionSnapshot.data ?? const [],
                              );
                            },
                          ),
                        );
                      }
                      return StreamBuilder<Map<String, String>>(
                        stream: bloc.packageNamesByCode,
                        initialData: const {},
                        builder: (context, packageSnapshot) {
                          final packageNames = packageSnapshot.data ?? const {};
                          return SliverList.builder(
                            itemCount: listings.length + 1,
                            itemBuilder: (context, index) {
                              if (index == listings.length) {
                                final isEnd = bloc.lastPagination != null &&
                                    (bloc.lastPagination!.currentPage ?? 1) >=
                                        bloc.lastPagination!.lastPage;
                                return _EndLabel(isEnd: isEnd);
                              }
                              final listing = listings[index];
                              return ListingCard(
                                listing: listing,
                                packageNamesByCode: packageNames,
                                isCompact: true,
                                onDetailsTap: _openDetails,
                                onFavoriteChanged: _onFavoriteChanged,
                                onOfferTap: _requireAuth,
                                onMessageTap: _requireAuth,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilters() async {
    final nextFilters = await showModalBottomSheet<ListingFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListingFilterSheet(
        bloc: bloc,
        initialFilters: bloc.filters,
      ),
    );

    if (nextFilters == null) return;
    bloc.setFilters(nextFilters);
    await bloc.refreshList();
  }

  void _openDetails(Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailsScreen(listingId: listing.id),
      ),
    );
  }

  Future<void> _onFavoriteChanged(Listing listing, bool nextValue) async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      throw StateError('auth_required');
    }
    await bloc.setFavorite(listing, nextValue);
  }

  void _requireAuth(Listing listing) async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu axın növbəti mərhələdə qoşulacaq.')),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  ListingFeedBloc provideBloc() {
    return ListingFeedBloc(filters: widget.filters);
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onFilterTap;
  final bool showBackButton;

  const _TopBar({
    required this.onFilterTap,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _ink900;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: isDark ? const Color(0xFF101010) : const Color(0xFFEEF1F6),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: showBackButton
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Icon(Icons.arrow_back, color: titleColor),
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Spacer(),
          Text(
            'Axtarış nəticələri',
            style: TextStyle(
              color: titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onFilterTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: _brand50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune, color: _brand, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final ListingFeedBloc bloc;

  const _ResultsHeader({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        children: [
          const Text(
            'Elanlar',
            style: TextStyle(
              color: _ink900,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            bloc.lastPagination?.total == null
                ? ''
                : '${bloc.lastPagination!.total} nəticə',
            style: const TextStyle(
              color: _ink400,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 210,
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

class _SearchEmpty extends StatelessWidget {
  final List suggestions;

  const _SearchEmpty({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 58, 24, 24),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: _brand, size: 58),
          const SizedBox(height: 14),
          const Text(
            'Nəticə tapılmadı',
            style: TextStyle(
              color: _ink900,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Serverdən gələn təklifləri aşağıda göstəririk.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink500,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in suggestions)
            if (item.label != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _brand50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.label!,
                  style: const TextStyle(
                    color: _brand,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _EndLabel extends StatelessWidget {
  final bool isEnd;

  const _EndLabel({required this.isEnd});

  @override
  Widget build(BuildContext context) {
    if (!isEnd) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator(color: _brand)),
      );
    }
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Text(
        'Hamısı yükləndi',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _ink400,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
