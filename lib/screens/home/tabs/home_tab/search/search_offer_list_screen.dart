import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/city.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../data/network/response/saved_search_response.dart';
import '../../../../../domain/entities/pagination.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../../../../../services/wawat_content.dart';
import '../../listings/details/listing_details_screen.dart';
import '../../listings/listing_feed_bloc.dart';
import '../../listings/widgets/listing_card.dart';
import '../widget/auth_modal_utils.dart';
import '../widget/search_form_page.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
const _screenBg = Color(0xFFEEF1F6);

String _contentText(Map<String, String> content, String key,
    [String? fallback]) {
  return WawatContent.text(content, key, fallback);
}

class SearchOfferListScreen extends BaseScreen<ListingFeedBloc> {
  final ListingFilterState filters;
  final bool showBackButton;
  final bool openResultsInNewPage;
  final bool openSavedOnStart;

  SearchOfferListScreen({
    super.key,
    this.filters = const ListingFilterState(),
    this.showBackButton = true,
    this.openResultsInNewPage = false,
    this.openSavedOnStart = false,
  });

  @override
  State<SearchOfferListScreen> createState() => _SearchOfferListScreenState();
}

class _SearchOfferListScreenState
    extends BaseState<SearchOfferListScreen, ListingFeedBloc> {
  final ScrollController _scrollController = ScrollController();
  bool _showResults = false;
  bool _currentSearchSaved = false;
  bool _advancedOpen = false;
  // True while editing the route from an existing results view — so the
  // back button returns to those results instead of leaving the screen.
  bool _editingFromResults = false;

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    _showResults = widget.filters.hasFilters;
    bloc.setFilters(widget.filters);
    bloc.loadRecentSearches();
    bloc.loadPackageTypes();
    bloc.loadListingContent();
    if (_showResults) {
      bloc.refreshList();
    }
    if (widget.openSavedOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSavedSearches();
      });
    }
    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_showResults &&
          _scrollController.position.extentAfter <=
              MediaQuery.of(context).size.height) {
        bloc.load();
      }
    });
  }

  @override
  Widget body() {
    return PopScope(
      canPop: !(_editingFromResults && !_showResults),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _editingFromResults && !_showResults) {
          setState(() {
            _showResults = true;
            _editingFromResults = false;
          });
        }
      },
      child: Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
        return ThemeAwareScreen(
          isDark: isDark,
          lightBackgroundColor: _showResults ? _screenBg : Colors.white,
          darkBackgroundColor: const Color(0xFF101010),
          child: SafeArea(
            child: StreamBuilder<Map<String, String>>(
              stream: bloc.listingContent,
              initialData: const {},
              builder: (context, snapshot) {
                final content = snapshot.data ?? const {};
                return _showResults
                    ? _buildResults(content)
                    : _buildEntry(content);
              },
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _buildEntry(Map<String, String> content) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _EntryTopBar(
            content: content,
            showBackButton: widget.showBackButton,
            onBack: _backFromEntry,
            onSavedTap: _openSavedSearches,
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _advancedOpen
                ? const SizedBox(width: double.infinity)
                : _SearchHero(content: content),
          ),
        ),
        SliverToBoxAdapter(
          child: SearchFormWidget(
            bloc: bloc,
            onSearch: _applySearch,
            showAdvancedToggle: true,
            advancedOpen: _advancedOpen,
            onAdvancedToggle: (open) => setState(() => _advancedOpen = open),
          ),
        ),
        if (_advancedOpen)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                _contentText(content, 'search.applied_hint',
                    'Filtrlər tətbiq olunur · «Ətraflı»-ya yenidən basıb yığmaq olar'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ink400,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
            child: _RecentSearchesBlock(bloc: bloc, content: content)),
        SliverToBoxAdapter(
            child: _TrendingRoutesBlock(bloc: bloc, content: content)),
        const SliverToBoxAdapter(child: SizedBox(height: 84)),
      ],
    );
  }

  Widget _buildResults(Map<String, String> content) {
    return RefreshIndicator(
      color: _brand,
      onRefresh: bloc.refreshList,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ResultsTopBar(
              content: content,
              filters: bloc.filters,
              showBackButton: widget.showBackButton,
              onBack: _backFromResults,
              onEditRoute: _openEditRoute,
            ),
          ),
          SliverToBoxAdapter(
            child: _ActiveFiltersRow(
              content: content,
              filters: bloc.filters,
              packageNames: bloc.packageNamesByCode.valueOrNull ?? const {},
              onRemove: _removeFilter,
              onClear: _clearFilters,
            ),
          ),
          SliverToBoxAdapter(
            child: _SearchSaveActions(
              content: content,
              isSaved: _currentSearchSaved,
              onSaveTap: _showSaveSearchSheet,
              onSavedSearchesTap: _openSavedSearches,
            ),
          ),
          SliverToBoxAdapter(
            child: _ResultsMetaBar(
              content: content,
              total: bloc.lastPagination?.total,
              sort: bloc.filters.sort,
              activeFilterCount: bloc.filters.activeFilterCount,
              onSortTap: _showSortSheet,
              onFilterTap: _showFilters,
            ),
          ),
          StreamBuilder<List<Listing>>(
            stream: bloc.paginableList,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NetworkError(
                      content: content, onRetry: bloc.refreshList),
                );
              }
              final listings = snapshot.data;
              if (listings == null) {
                return const SliverToBoxAdapter(child: _SearchSkeleton());
              }
              if (listings.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: StreamBuilder<List<PaginationSuggestion>>(
                    stream: bloc.suggestions,
                    initialData: const [],
                    builder: (context, suggestionSnapshot) {
                      return _SearchEmpty(
                        content: content,
                        suggestions: suggestionSnapshot.data ?? const [],
                        onSuggestionTap: _handleSuggestion,
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
                        return _EndLabel(content: content, isEnd: isEnd);
                      }
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        packageNamesByCode: packageNames,
                        isCompact: true,
                        onDetailsTap: _openDetails,
                        onFavoriteChanged: _onFavoriteChanged,
                        onOfferTap: (listing) => showListingProposalFlow(
                          context,
                          listing: listing,
                          packageNamesByCode: packageNames,
                          content: content,
                        ),
                        onMessageTap: (listing) => openListingChat(
                          context,
                          listing: listing,
                          content: content,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Future<void> _applySearch(ListingFilterState filters) async {
    if (widget.openResultsInNewPage) {
      await bloc.saveRecentSearch(filters);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SearchOfferListScreen(filters: filters),
        ),
      );
      return;
    }
    bloc.setFilters(filters);
    setState(() {
      _showResults = true;
      _currentSearchSaved = false;
    });
    await bloc.saveRecentSearch(filters);
    await bloc.refreshList();
  }

  void _backFromResults() {
    if (widget.showBackButton) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _showResults = false);
    }
  }

  void _openEditRoute() {
    setState(() {
      _showResults = false;
      _editingFromResults = true;
    });
  }

  // Back from the route-edit view: return to the results we came from instead
  // of leaving the screen. Only leaves when we opened straight into the form.
  void _backFromEntry() {
    if (_editingFromResults) {
      setState(() {
        _showResults = true;
        _editingFromResults = false;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _showFilters() async {
    final nextFilters = await Navigator.of(context).push<ListingFilterState>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _SearchFilterScreen(
          content: bloc.listingContent.valueOrNull ?? const {},
          bloc: bloc,
          initialFilters: bloc.filters,
        ),
      ),
    );
    if (nextFilters == null) return;
    bloc.setFilters(nextFilters);
    await bloc.refreshList();
    if (mounted) setState(() => _currentSearchSaved = false);
  }

  Future<void> _showSortSheet() async {
    final sort = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        content: bloc.listingContent.valueOrNull ?? const {},
        selected: bloc.filters.sort,
      ),
    );
    if (sort == null) return;
    bloc.setFilters(bloc.filters.copyWith(sort: sort));
    await bloc.refreshList();
    if (mounted) setState(() => _currentSearchSaved = false);
  }

  Future<void> _openSavedSearches() async {
    if (!await _ensureAuth()) return;
    if (!mounted) return;
    final filters = await Navigator.of(context).push<ListingFilterState>(
      MaterialPageRoute(
        builder: (_) => _SavedSearchesScreen(
          bloc: bloc,
          content: bloc.listingContent.valueOrNull ?? const {},
        ),
      ),
    );
    if (filters != null) {
      await _applySearch(filters);
    }
  }

  Future<void> _showSaveSearchSheet() async {
    if (!await _ensureAuth()) return;
    if (!mounted) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaveSearchSheet(
        content: bloc.listingContent.valueOrNull ?? const {},
        filters: bloc.filters,
        onSave: (name, notify) async {
          final searchName = (name ?? '').trim().isNotEmpty
              ? name!.trim()
              : _defaultSavedSearchName(
                  bloc.listingContent.valueOrNull ?? const {},
                  bloc.filters,
                  bloc.packageNamesByCode.valueOrNull ?? const {},
                );
          final response = await bloc.createSavedSearch(
            name: searchName,
            notify: notify,
            filters: bloc.filters,
          );
          return response.message ??
              _contentText(bloc.listingContent.valueOrNull ?? const {},
                  'search.saved_created');
        },
      ),
    );
    if (saved == true && mounted) {
      setState(() => _currentSearchSaved = true);
      _showSuccess(_contentText(
          bloc.listingContent.valueOrNull ?? const {}, 'search.saved_success'));
    }
  }

  void _handleSuggestion(PaginationSuggestion suggestion) {
    switch (suggestion.action) {
      case 'create_alert':
        _showSaveSearchSheet();
        break;
      case 'broaden':
        _clearFilters();
        break;
      case 'post_opposite':
        _showSuccess(_contentText(bloc.listingContent.valueOrNull ?? const {},
            'search.post_opposite_soon'));
        break;
    }
  }

  void _removeFilter(String key) {
    var filters = bloc.filters;
    if (key == 'type') filters = filters.copyWith(clearType: true);
    if (key == 'verified') filters = filters.copyWith(verifiedOnly: false);
    if (key == 'following') filters = filters.copyWith(following: false);
    if (key.startsWith('package:')) {
      final code = key.substring('package:'.length);
      filters = filters.copyWith(
        packageTypes:
            filters.packageTypes.where((item) => item != code).toList(),
      );
    }
    if (key == 'price') {
      filters = filters.copyWith(clearPriceMin: true, clearPriceMax: true);
    }
    if (key == 'weight') {
      filters = filters.copyWith(clearWeightMin: true, clearWeightMax: true);
    }
    if (key == 'date') {
      filters = filters.copyWith(clearDateFrom: true, clearDateTo: true);
    }
    if (key == 'rating') filters = filters.copyWith(clearRatingMin: true);
    if (key == 'tier') filters = filters.copyWith(clearTierMin: true);
    bloc.setFilters(filters);
    bloc.refreshList();
    setState(() => _currentSearchSaved = false);
  }

  void _clearFilters() {
    bloc.setFilters(bloc.filters.routeOnly());
    bloc.refreshList();
    setState(() => _currentSearchSaved = false);
  }

  void _openDetails(Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailsScreen(listingId: listing.id),
      ),
    );
  }

  Future<void> _onFavoriteChanged(Listing listing, bool nextValue) async {
    if (!await _ensureAuth()) {
      throw StateError('auth_required');
    }
    await bloc.setFavorite(listing, nextValue);
  }

  Future<bool> _ensureAuth() async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!mounted) return false;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      return false;
    }
    return true;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(PhosphorIconsFill.checkCircle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
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

class _SearchHero extends StatelessWidget {
  final Map<String, String> content;

  const _SearchHero({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 4),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14263F) : _brand50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(PhosphorIconsFill.airplaneTilt,
                color: _brand, size: 27),
          ),
          const SizedBox(height: 12),
          Text(
            _contentText(content, 'search.hero_title', 'Marşrutu axtar'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : _ink900,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _contentText(content, 'search.hero_subtitle',
                'Haradan hara göndərmək istəyirsən?'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink400,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTopBar extends StatelessWidget {
  final Map<String, String> content;
  final bool showBackButton;
  final VoidCallback onBack;
  final VoidCallback onSavedTap;

  const _EntryTopBar({
    required this.content,
    required this.showBackButton,
    required this.onBack,
    required this.onSavedTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _ink900;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101010) : Colors.white,
        border: Border(
          bottom: BorderSide(color: _ink900.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: showBackButton
                ? GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onBack,
                    child: Icon(PhosphorIconsBold.arrowLeft, color: titleColor),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              _contentText(content, 'search.title'),
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onSavedTap,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(PhosphorIconsRegular.bookmarkSimple, color: _ink500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsTopBar extends StatelessWidget {
  final Map<String, String> content;
  final ListingFilterState filters;
  final bool showBackButton;
  final VoidCallback onBack;
  final VoidCallback onEditRoute;

  const _ResultsTopBar({
    required this.content,
    required this.filters,
    required this.showBackButton,
    required this.onBack,
    required this.onEditRoute,
  });

  @override
  Widget build(BuildContext context) {
    final route = _routeLabel(content, filters);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _ink900.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(PhosphorIconsBold.arrowLeft, color: _ink700),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onEditRoute,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _ink900.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            route,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink800,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          PhosphorIconsRegular.pencilSimple,
                          color: _ink400,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentSearchesBlock extends StatelessWidget {
  final ListingFeedBloc bloc;
  final Map<String, String> content;

  const _RecentSearchesBlock({required this.bloc, required this.content});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ListingFilterState>>(
      stream: bloc.recentSearches,
      initialData: const [],
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return _SearchIntroEmpty(content: content);
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    _contentText(content, 'search.recent_title'),
                    style: const TextStyle(
                      color: _ink900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: bloc.clearRecentSearches,
                    child: Text(
                      _contentText(content, 'common.clear'),
                      style: const TextStyle(
                        color: _brand,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final item in items.take(3))
                GestureDetector(
                  onTap: () {
                    final state = context
                        .findAncestorStateOfType<_SearchOfferListScreenState>();
                    state?._applySearch(item);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _ink900.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            PhosphorIconsRegular.clockCounterClockwise,
                            color: _ink400,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _routeLabel(content, item),
                            style: const TextStyle(
                              color: _ink800,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          PhosphorIconsRegular.arrowUpLeft,
                          color: _ink300,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchIntroEmpty extends StatelessWidget {
  final Map<String, String> content;

  const _SearchIntroEmpty({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _brand50,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              PhosphorIconsRegular.magnifyingGlass,
              color: _brand,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _contentText(content, 'search.intro_title'),
            style: const TextStyle(
              color: _ink900,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _contentText(
              content,
              'search.intro_subtitle',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink500,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingRoutesBlock extends StatelessWidget {
  final ListingFeedBloc bloc;
  final Map<String, String> content;

  const _TrendingRoutesBlock({required this.bloc, required this.content});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: bloc.getTrendingRoutes(),
      builder: (context, snapshot) {
        final routes = _parseTrendingRoutes(snapshot.data?.data);
        if (routes.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _contentText(content, 'home.popular_routes'),
                style: const TextStyle(
                  color: _ink900,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 16),
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return GestureDetector(
                      onTap: () {
                        final state = context.findAncestorStateOfType<
                            _SearchOfferListScreenState>();
                        state?._applySearch(
                          ListingFilterState(
                            cityFrom: route.from,
                            cityTo: route.to,
                          ),
                        );
                      },
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _ink900.withValues(alpha: 0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _ink900.withValues(alpha: 0.08),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${route.from.name} → ${route.to.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ink900,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _contentText(
                                content,
                                'search.route_total_template',
                              ).replaceAll('{count}', '${route.total}'),
                              style: const TextStyle(
                                color: _ink400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _contentText(content, 'search.button'),
                              style: const TextStyle(
                                color: _brand,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: routes.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveFiltersRow extends StatelessWidget {
  final Map<String, String> content;
  final ListingFilterState filters;
  final Map<String, String> packageNames;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  const _ActiveFiltersRow({
    required this.content,
    required this.filters,
    required this.packageNames,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final chips = _activeChips(content, filters, packageNames);
    if (chips.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final chip in chips) ...[
              _FilterChipView(
                label: chip.label,
                onTap: () => onRemove(chip.key),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: onClear,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  _contentText(content, 'common.clear'),
                  style: const TextStyle(
                    color: _ink400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipView extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChipView({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _brand50,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: _brand.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _brand,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(PhosphorIconsBold.x, color: _brand, size: 11),
          ],
        ),
      ),
    );
  }
}

class _ResultsMetaBar extends StatelessWidget {
  final Map<String, String> content;
  final int? total;
  final String sort;
  final int activeFilterCount;
  final VoidCallback onSortTap;
  final VoidCallback onFilterTap;

  const _ResultsMetaBar({
    required this.content,
    required this.total,
    required this.sort,
    required this.activeFilterCount,
    required this.onSortTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _ink900.withValues(alpha: 0.07);
    final labelColor = isDark ? Colors.white : _ink700;
    final iconColor = isDark ? const Color(0xFFCBD5E1) : _ink600;
    final hasFilters = activeFilterCount > 0;
    final countText = total == null
        ? ''
        : _contentText(content, 'search.results_count_template')
            .replaceAll('{count}', '$total');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (countText.isNotEmpty) ...[
            Text(
              countText,
              style: TextStyle(
                color: isDark ? const Color(0xFF9CA3AF) : _ink500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _MetaTile(
                  onTap: onSortTap,
                  background: surface,
                  borderColor: border,
                  shadow: !isDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.arrowsDownUp,
                          color: iconColor, size: 16),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          _sortLabel(content, sort),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _MetaTile(
                  onTap: onFilterTap,
                  background: hasFilters
                      ? (isDark ? const Color(0xFF14263F) : _brand50)
                      : surface,
                  borderColor: hasFilters ? _brand.withValues(alpha: 0.35) : border,
                  shadow: !isDark && !hasFilters,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsRegular.slidersHorizontal,
                          color: _brand, size: 17),
                      const SizedBox(width: 7),
                      Text(
                        _contentText(content, 'search.filter', 'Filtrlə'),
                        style: TextStyle(
                          color: hasFilters ? _brand : labelColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasFilters) ...[
                        const SizedBox(width: 6),
                        Container(
                          constraints: const BoxConstraints(minWidth: 16),
                          height: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _brand,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              height: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final VoidCallback onTap;
  final Color background;
  final Color borderColor;
  final bool shadow;
  final Widget child;

  const _MetaTile({
    required this.onTap,
    required this.background,
    required this.borderColor,
    required this.child,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: _ink900.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

class _SearchSaveActions extends StatelessWidget {
  final Map<String, String> content;
  final bool isSaved;
  final VoidCallback onSaveTap;
  final VoidCallback onSavedSearchesTap;

  const _SearchSaveActions({
    required this.content,
    required this.isSaved,
    required this.onSaveTap,
    required this.onSavedSearchesTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _SearchSaveActionButton(
              icon: isSaved
                  ? PhosphorIconsFill.checkCircle
                  : PhosphorIconsRegular.bookmarkSimple,
              label: _contentText(
                content,
                isSaved ? 'search.saved_state' : 'search.save_current',
              ),
              foreground: _brand,
              background: isDark
                  ? _brand.withValues(alpha: 0.15)
                  : const Color(0xFFEAF3FE),
              border: _brand.withValues(alpha: 0.20),
              onTap: isSaved ? onSavedSearchesTap : onSaveTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SearchSaveActionButton(
              icon: PhosphorIconsRegular.bookmarksSimple,
              label: _contentText(content, 'search.saved_short'),
              foreground: isDark ? Colors.white : _ink700,
              background: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : _ink900.withValues(alpha: 0.07),
              onTap: onSavedSearchesTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSaveActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;
  final VoidCallback onTap;

  const _SearchSaveActionButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
          (_) => Container(
            height: 210,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE7EBF1),
                  Color(0xFFF4F6F9),
                  Color(0xFFE7EBF1)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  final Map<String, String> content;
  final List<PaginationSuggestion> suggestions;
  final ValueChanged<PaginationSuggestion> onSuggestionTap;

  const _SearchEmpty({
    required this.content,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = suggestions.isEmpty
        ? [
            PaginationSuggestion(
              action: 'create_alert',
              label: _contentText(
                content,
                'search.suggestion_create_alert',
              ),
            ),
            PaginationSuggestion(
              action: 'post_opposite',
              label: _contentText(
                content,
                'search.suggestion_post_opposite',
              ),
            ),
            PaginationSuggestion(
              action: 'broaden',
              label: _contentText(
                content,
                'search.suggestion_broaden',
              ),
            ),
          ]
        : suggestions;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _brand50,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              PhosphorIconsRegular.magnifyingGlass,
              color: _brand,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _contentText(content, 'search.empty_title'),
            style: const TextStyle(
              color: _ink900,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _contentText(
              content,
              'search.empty_subtitle',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: _ink500, fontSize: 14),
          ),
          const SizedBox(height: 18),
          for (final item in items)
            GestureDetector(
              onTap: () => onSuggestionTap(item),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _brand50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.label ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkError extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onRetry;

  const _NetworkError({required this.content, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              PhosphorIconsRegular.wifiSlash,
              color: Color(0xFFEF4444),
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _contentText(content, 'search.network_error_title'),
            style: const TextStyle(
              color: _ink900,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _contentText(content, 'search.network_error_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: _ink500),
          ),
          const SizedBox(height: 18),
          _PrimaryAction(
              label: _contentText(content, 'common.retry'), onTap: onRetry),
        ],
      ),
    );
  }
}

class _EndLabel extends StatelessWidget {
  final Map<String, String> content;
  final bool isEnd;

  const _EndLabel({required this.content, required this.isEnd});

  @override
  Widget build(BuildContext context) {
    if (!isEnd) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator(color: _brand)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                const BoxDecoration(color: _brand50, shape: BoxShape.circle),
            child: const Icon(PhosphorIconsBold.check, color: _brand),
          ),
          const SizedBox(height: 8),
          Text(
            _contentText(content, 'search.end_title'),
            style: const TextStyle(
              color: _ink700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _contentText(content, 'search.end_subtitle'),
            style: const TextStyle(color: _ink400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final Map<String, String> content;
  final String selected;

  const _SortSheet({required this.content, required this.selected});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SortItem('relevance', _contentText(content, 'sort.relevance'),
          PhosphorIconsRegular.sparkle),
      _SortItem('date_desc', _contentText(content, 'sort.date_desc'),
          PhosphorIconsRegular.clock),
      _SortItem('date_asc', _contentText(content, 'sort.date_asc'),
          PhosphorIconsRegular.clockCounterClockwise),
      _SortItem('price_asc', _contentText(content, 'sort.price_asc'),
          PhosphorIconsRegular.arrowDown),
      _SortItem('price_desc', _contentText(content, 'sort.price_desc'),
          PhosphorIconsRegular.arrowUp),
      _SortItem('weight_desc', _contentText(content, 'sort.weight_desc'),
          PhosphorIconsRegular.scales),
      _SortItem('rating_desc', _contentText(content, 'sort.rating_desc'),
          PhosphorIconsRegular.star),
    ];
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Grabber(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _contentText(content, 'search.sort_title'),
              style: const TextStyle(
                color: _ink900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            GestureDetector(
              onTap: () => Navigator.pop(context, item.value),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: _ink900.withValues(alpha: 0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color: selected == item.value ? _brand : _ink500,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: selected == item.value ? _brand : _ink800,
                          fontSize: 15,
                          fontWeight: selected == item.value
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (selected == item.value)
                      const Icon(PhosphorIconsFill.checkCircle, color: _brand),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SortItem {
  final String value;
  final String label;
  final IconData icon;

  const _SortItem(this.value, this.label, this.icon);
}

class _SearchFilterScreen extends StatefulWidget {
  final Map<String, String> content;
  final ListingFeedBloc bloc;
  final ListingFilterState initialFilters;

  const _SearchFilterScreen({
    required this.content,
    required this.bloc,
    required this.initialFilters,
  });

  @override
  State<_SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<_SearchFilterScreen> {
  late ListingFilterState _filters;
  List<PackageType> _packages = const [];
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();
  final _weightMin = TextEditingController();
  final _weightMax = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceMin.text = _filters.priceMin?.toString() ?? '';
    _priceMax.text = _filters.priceMax?.toString() ?? '';
    _weightMin.text = _filters.weightMin?.toString() ?? '';
    _weightMax.text = _filters.weightMax?.toString() ?? '';
    widget.bloc.loadPackageTypes().then((value) {
      if (mounted) setState(() => _packages = value.data);
    });
  }

  @override
  void dispose() {
    _priceMin.dispose();
    _priceMax.dispose();
    _weightMin.dispose();
    _weightMax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _ink900.withValues(alpha: 0.06)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(PhosphorIconsBold.x, color: _ink700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _contentText(widget.content, 'search.filters_title'),
                      style: const TextStyle(
                        color: _ink900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _reset,
                    child: Text(
                      _contentText(widget.content, 'common.reset'),
                      style: const TextStyle(
                        color: _brand,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterTitle(
                        _contentText(widget.content, 'search.filter_type')),
                    _Segmented(
                      content: widget.content,
                      value: _filters.type,
                      onChanged: (value) => setState(
                        () => _filters = _filters.copyWith(
                          type: value,
                          clearType: value == null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FilterTitle(_contentText(
                        widget.content, 'search.filter_package_type')),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final package in _packages)
                          _Pill(
                            label: package.name,
                            icon: _packageIcon(package.code),
                            selected:
                                _filters.packageTypes.contains(package.code),
                            onTap: () {
                              final next = [..._filters.packageTypes];
                              next.contains(package.code)
                                  ? next.remove(package.code)
                                  : next.add(package.code);
                              setState(
                                () => _filters = _filters.copyWith(
                                  packageTypes: next,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _FilterTitle(
                        _contentText(widget.content, 'search.filter_price')),
                    Row(
                      children: [
                        Expanded(
                            child: _SmallInput(
                                controller: _priceMin,
                                hint: _contentText(
                                    widget.content, 'common.min'))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _SmallInput(
                                controller: _priceMax,
                                hint: _contentText(
                                    widget.content, 'common.max'))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _FilterTitle(
                        _contentText(widget.content, 'search.filter_weight')),
                    Row(
                      children: [
                        Expanded(
                            child: _SmallInput(
                                controller: _weightMin,
                                hint: _contentText(
                                    widget.content, 'common.min'))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _SmallInput(
                                controller: _weightMax,
                                hint: _contentText(
                                    widget.content, 'common.max'))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _FilterTitle(
                        _contentText(widget.content, 'search.filter_date')),
                    Row(
                      children: [
                        Expanded(
                          child: _DateFilterBox(
                            label: _contentText(
                                widget.content, 'search.date_from'),
                            value: _filters.dateFrom,
                            onTap: () => _pickDate(isFrom: true),
                            onClear: () => setState(
                              () => _filters =
                                  _filters.copyWith(clearDateFrom: true),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateFilterBox(
                            label:
                                _contentText(widget.content, 'search.date_to'),
                            value: _filters.dateTo,
                            onTap: () => _pickDate(isFrom: false),
                            onClear: () => setState(
                              () => _filters =
                                  _filters.copyWith(clearDateTo: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _FilterTitle(
                        _contentText(widget.content, 'search.filter_rating')),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          label:
                              _contentText(widget.content, 'search.filter_any'),
                          selected: _filters.ratingMin == null,
                          onTap: () => setState(
                            () => _filters =
                                _filters.copyWith(clearRatingMin: true),
                          ),
                        ),
                        _Pill(
                          label: '4.5+',
                          icon: PhosphorIconsFill.star,
                          selected: _filters.ratingMin == 4.5,
                          onTap: () => setState(
                            () => _filters = _filters.copyWith(ratingMin: 4.5),
                          ),
                        ),
                        _Pill(
                          label: '4.8+',
                          icon: PhosphorIconsFill.star,
                          selected: _filters.ratingMin == 4.8,
                          onTap: () => setState(
                            () => _filters = _filters.copyWith(ratingMin: 4.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _FilterTitle(
                        _contentText(widget.content, 'search.filter_tier')),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _tier(_contentText(widget.content, 'search.filter_any'),
                            null),
                        _tier(_contentText(widget.content, 'tier.bronze_plus'),
                            'bronze'),
                        _tier(_contentText(widget.content, 'tier.silver_plus'),
                            'silver'),
                        _tier(_contentText(widget.content, 'tier.gold_plus'),
                            'gold'),
                        _tier(_contentText(widget.content, 'tier.platinum'),
                            'platinum'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SwitchRow(
                      label:
                          _contentText(widget.content, 'search.verified_only'),
                      icon: PhosphorIconsFill.sealCheck,
                      value: _filters.verifiedOnly,
                      onChanged: (value) => setState(
                        () => _filters = _filters.copyWith(verifiedOnly: value),
                      ),
                    ),
                    _SwitchRow(
                      label:
                          _contentText(widget.content, 'search.following_only'),
                      icon: PhosphorIconsRegular.userCheck,
                      value: _filters.following,
                      onChanged: (value) => setState(
                        () => _filters = _filters.copyWith(following: value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: _ink900.withValues(alpha: 0.06)),
            ),
          ),
          child: _PrimaryAction(
            label: _contentText(widget.content, 'search.show_results'),
            onTap: () {
              Navigator.pop(
                context,
                _filters.copyWith(
                  priceMin: _parse(_priceMin.text),
                  priceMax: _parse(_priceMax.text),
                  weightMin: _parse(_weightMin.text),
                  weightMax: _parse(_weightMax.text),
                  clearPriceMin: _priceMin.text.trim().isEmpty,
                  clearPriceMax: _priceMax.text.trim().isEmpty,
                  clearWeightMin: _weightMin.text.trim().isEmpty,
                  clearWeightMax: _weightMax.text.trim().isEmpty,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tier(String label, String? value) {
    return _Pill(
      label: label,
      selected: _filters.tierMin == value,
      onTap: () => setState(
        () => _filters = _filters.copyWith(
          tierMin: value,
          clearTierMin: value == null,
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _filters = widget.initialFilters.routeOnly().copyWith(
            clearDateFrom: true,
            clearDateTo: true,
          );
      _priceMin.clear();
      _priceMax.clear();
      _weightMin.clear();
      _weightMax.clear();
    });
  }

  double? _parse(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final currentValue = isFrom ? _filters.dateFrom : _filters.dateTo;
    final firstDate = DateTime.now().subtract(const Duration(days: 1));
    final lastDate = DateTime.now().add(const Duration(days: 730));
    var initial = DateTime.tryParse(currentValue ?? '') ?? DateTime.now();
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _brand,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _ink900,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _brand),
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final value = _dateFilterValue(picked);
      _filters = _filters.copyWith(
        dateFrom: isFrom ? value : null,
        dateTo: isFrom ? null : value,
      );
    });
  }
}

class _SavedSearchesScreen extends StatefulWidget {
  final ListingFeedBloc bloc;
  final Map<String, String> content;

  const _SavedSearchesScreen({required this.bloc, required this.content});

  @override
  State<_SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends State<_SavedSearchesScreen> {
  bool _loading = true;
  final Set<String> _deletingIds = {};
  List<SavedSearch> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await widget.bloc.getSavedSearches();
      if (!mounted) return;
      setState(() => _items = _visibleSavedSearches(response.data));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(SavedSearch item) async {
    if (_deletingIds.contains(item.id)) return;
    final previous = List<SavedSearch>.from(_items);
    setState(() {
      _deletingIds.add(item.id);
      _items = _items.where((saved) => saved.id != item.id).toList();
    });
    try {
      await widget.bloc.deleteSavedSearch(item.id);
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = previous);
    } finally {
      if (mounted) {
        setState(() => _deletingIds.remove(item.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _SimpleTopBar(
              title: _contentText(
                widget.content,
                'search.saved_title',
                'Saxlanmış axtarışlar',
              ),
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _brand),
                    )
                  : _items.isEmpty
                      ? _SavedEmpty(content: widget.content)
                      : RefreshIndicator(
                          color: _brand,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return _SavedSearchCard(
                                item: item,
                                content: widget.content,
                                deleting: _deletingIds.contains(item.id),
                                onTap: () => Navigator.pop(
                                  context,
                                  _filtersFromSavedSearch(item),
                                ),
                                onDelete: () => _delete(item),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemCount: _items.length,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedSearchCard extends StatelessWidget {
  final SavedSearch item;
  final Map<String, String> content;
  final bool deleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SavedSearchCard({
    required this.item,
    required this.content,
    required this.deleting,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final filters = _filtersFromSavedSearch(item);
    final title = _savedSearchDisplayName(content, item, filters);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _ink900.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: _ink900.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.notify ? _brand50 : _ink900.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.notify
                    ? PhosphorIconsFill.bellRinging
                    : PhosphorIconsFill.bookmarkSimple,
                color: item.notify ? _brand : _ink500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _ink900,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.notify)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _contentText(
                              content,
                              'search.alert_active',
                              'Bildiriş aktiv',
                            ),
                            style: const TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final chip
                          in _activeChips(content, filters, const {}).take(4))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: _ink900.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            chip.label,
                            style: const TextStyle(
                              color: _ink600,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.lastRunAt != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      _contentText(
                        content,
                        'search.last_check_template',
                        'Son yoxlama: {time}',
                      ).replaceAll(
                          '{time}', _relativeTime(content, item.lastRunAt)),
                      style: const TextStyle(color: _ink400, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: deleting ? null : onDelete,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: deleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _brand,
                        ),
                      )
                    : const Icon(PhosphorIconsRegular.trash, color: _ink400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveSearchSheet extends StatefulWidget {
  final Map<String, String> content;
  final ListingFilterState filters;
  final Future<String> Function(String? name, bool notify) onSave;

  const _SaveSearchSheet({
    required this.content,
    required this.filters,
    required this.onSave,
  });

  @override
  State<_SaveSearchSheet> createState() => _SaveSearchSheetState();
}

class _SaveSearchSheetState extends State<_SaveSearchSheet> {
  final _name = TextEditingController();
  bool _notify = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Grabber(),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _brand50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              PhosphorIconsFill.bellRinging,
              color: _brand,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _contentText(widget.content, 'search.save_title'),
            style: const TextStyle(
              color: _ink900,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _contentText(widget.content, 'search.save_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: _ink500, fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _TinyChip(_routeLabel(widget.content, widget.filters)),
              for (final chip
                  in _activeChips(widget.content, widget.filters, const {})
                      .take(3))
                _TinyChip(chip.label),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _name,
            decoration: _inputDecoration(
                _contentText(widget.content, 'search.save_name_hint')),
          ),
          const SizedBox(height: 12),
          _SwitchRow(
            label: _contentText(widget.content, 'search.save_notify'),
            icon: PhosphorIconsFill.bell,
            value: _notify,
            onChanged: (value) => setState(() => _notify = value),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _PrimaryAction(
            label: _loading
                ? _contentText(widget.content, 'common.wait')
                : _contentText(widget.content, 'common.save'),
            onTap: _loading
                ? () {}
                : () async {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    try {
                      await widget.onSave(
                        _name.text.trim().isEmpty ? null : _name.text.trim(),
                        _notify,
                      );
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    } catch (_) {
                      if (!mounted) return;
                      setState(() {
                        _loading = false;
                        _error = _contentText(
                          widget.content,
                          'search.save_error',
                        );
                      });
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _SearchFilterChip {
  final String key;
  final String label;

  const _SearchFilterChip(this.key, this.label);
}

List<_SearchFilterChip> _activeChips(
  Map<String, String> content,
  ListingFilterState filters,
  Map<String, String> packageNames,
) {
  final chips = <_SearchFilterChip>[];
  if (filters.type != null) {
    chips.add(_SearchFilterChip(
      'type',
      filters.type == 'trip'
          ? _contentText(content, 'search.type_trip')
          : _contentText(content, 'search.type_shipment'),
    ));
  }
  for (final code in filters.packageTypes) {
    chips.add(_SearchFilterChip('package:$code', packageNames[code] ?? code));
  }
  if (filters.verifiedOnly) {
    chips.add(_SearchFilterChip(
        'verified', _contentText(content, 'search.verified')));
  }
  if (filters.following) {
    chips.add(_SearchFilterChip(
        'following', _contentText(content, 'search.following')));
  }
  if (filters.priceMin != null || filters.priceMax != null) {
    chips.add(_SearchFilterChip(
        'price', _rangeLabel(filters.priceMin, filters.priceMax, '₼')));
  }
  if (filters.weightMin != null || filters.weightMax != null) {
    chips.add(_SearchFilterChip(
        'weight', _rangeLabel(filters.weightMin, filters.weightMax, 'kq')));
  }
  if (filters.dateFrom != null || filters.dateTo != null) {
    chips.add(_SearchFilterChip(
      'date',
      '${filters.dateFrom ?? '...'} – ${filters.dateTo ?? '...'}',
    ));
  }
  if (filters.ratingMin != null) {
    chips.add(_SearchFilterChip('rating', '${filters.ratingMin}+'));
  }
  if (filters.tierMin != null) {
    chips.add(_SearchFilterChip('tier', '${filters.tierMin}+'));
  }
  return chips;
}

String _defaultSavedSearchName(
  Map<String, String> content,
  ListingFilterState filters,
  Map<String, String> packageNames,
) {
  final parts = <String>[_routeLabel(content, filters)];
  final type = filters.type;
  if (type == 'trip') parts.add(_contentText(content, 'search.type_trip'));
  if (type == 'shipment_post') {
    parts.add(_contentText(content, 'search.type_shipment'));
  }
  parts.addAll(
    _activeChips(content, filters, packageNames)
        .where((chip) => chip.key != 'type')
        .map((chip) => chip.label)
        .take(2),
  );
  return parts.where((part) => part.trim().isNotEmpty).join(' · ');
}

String _savedSearchDisplayName(
  Map<String, String> content,
  SavedSearch item,
  ListingFilterState filters,
) {
  final name = item.name?.trim() ?? '';
  if (name.isNotEmpty && !RegExp(r'^\d+$').hasMatch(name)) return name;
  return _defaultSavedSearchName(content, filters, const {});
}

ListingFilterState _filtersFromSavedSearch(SavedSearch item) {
  final routeNames = _routeNamesFromSavedSearch(item);
  return ListingFilterState.fromFilterMap(
    item.filters,
    cityFromName: _savedCityName(item.filters, 'from') ?? routeNames.$1,
    cityFromCountry: _savedCityCountry(item.filters, 'from'),
    cityToName: _savedCityName(item.filters, 'to') ?? routeNames.$2,
    cityToCountry: _savedCityCountry(item.filters, 'to'),
  );
}

(String?, String?) _routeNamesFromSavedSearch(SavedSearch item) {
  final name = item.name?.trim() ?? '';
  if (!name.contains('→')) return (null, null);
  final routePart = name.split('·').first.trim();
  final parts = routePart.split('→');
  if (parts.length != 2) return (null, null);
  final from = parts.first.trim();
  final to = parts.last.trim();
  return (
    from.isEmpty || from.startsWith('#') ? null : from,
    to.isEmpty || to.startsWith('#') ? null : to,
  );
}

String? _savedCityName(Map<String, dynamic> filters, String side) {
  final direct = filters['city_${side}_name'] ?? filters['${side}_name'];
  if (direct != null && direct.toString().trim().isNotEmpty) {
    return direct.toString().trim();
  }
  final nested = filters['city_$side'];
  if (nested is Map) {
    final name = nested['name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString().trim();
    }
  }
  return null;
}

String? _savedCityCountry(Map<String, dynamic> filters, String side) {
  final direct = filters['city_${side}_country'] ?? filters['${side}_country'];
  if (direct != null && direct.toString().trim().isNotEmpty) {
    return direct.toString().trim();
  }
  final nested = filters['city_$side'];
  if (nested is Map) {
    final country = nested['country_name'] ?? nested['country'];
    if (country != null && country.toString().trim().isNotEmpty) {
      return country.toString().trim();
    }
  }
  return null;
}

List<SavedSearch> _visibleSavedSearches(List<SavedSearch> items) {
  final result = <SavedSearch>[];
  final seen = <String>{};
  for (final item in items) {
    if (item.id.trim().isEmpty) continue;
    final kind = item.kind?.trim();
    if (kind != null && kind.isNotEmpty && kind != 'explicit') continue;
    if (_isUnnamedIdOnlySearch(item)) continue;
    final key = _savedSearchKey(item);
    if (seen.add(key)) {
      result.add(item);
    }
  }
  return result;
}

bool _isUnnamedIdOnlySearch(SavedSearch item) {
  final name = item.name?.trim() ?? '';
  if (name.isNotEmpty && !RegExp(r'^\d+$').hasMatch(name)) return false;
  final filters = item.filters;
  return !_hasSavedCityLabel(filters, 'from') &&
      !_hasSavedCityLabel(filters, 'to');
}

bool _hasSavedCityLabel(Map<String, dynamic> filters, String side) {
  final direct = filters['city_${side}_name'] ?? filters['${side}_name'];
  if (direct != null && direct.toString().trim().isNotEmpty) return true;
  final nested = filters['city_$side'];
  if (nested is Map) {
    final name = nested['name'];
    return name != null && name.toString().trim().isNotEmpty;
  }
  return false;
}

String _savedSearchKey(SavedSearch item) {
  final filters = item.filters;
  return [
    item.kind ?? 'explicit',
    filters['type']?.toString() ?? '',
    filters['city_from_id']?.toString() ?? '',
    filters['city_to_id']?.toString() ?? '',
    (filters['package_types'] is List)
        ? (filters['package_types'] as List).join(',')
        : '',
    filters['date_from']?.toString() ?? '',
    filters['date_to']?.toString() ?? '',
    filters['weight_min']?.toString() ?? '',
    filters['weight_max']?.toString() ?? '',
    filters['price_min']?.toString() ?? '',
    filters['price_max']?.toString() ?? '',
    filters['rating_min']?.toString() ?? '',
    filters['tier_min']?.toString() ?? '',
  ].join('|');
}

String _routeLabel(Map<String, String> content, ListingFilterState filters) {
  final from = filters.cityFrom?.name ??
      _contentText(content, 'search.from_placeholder');
  final to =
      filters.cityTo?.name ?? _contentText(content, 'search.to_placeholder');
  return '$from → $to';
}

String _rangeLabel(double? min, double? max, String suffix) {
  if (min != null && max != null) return '${_num(min)} – ${_num(max)} $suffix';
  if (min != null) return '≥ ${_num(min)} $suffix';
  return '≤ ${_num(max)} $suffix';
}

String _num(double? value) {
  if (value == null) return '';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _dateFilterValue(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _sortLabel(Map<String, String> content, String sort) {
  return switch (sort) {
    'date_desc' => _contentText(content, 'sort.date_desc'),
    'date_asc' => _contentText(content, 'sort.date_asc'),
    'price_asc' => _contentText(content, 'sort.price_asc'),
    'price_desc' => _contentText(content, 'sort.price_desc'),
    'weight_desc' => _contentText(content, 'sort.weight_desc'),
    'weight_asc' => _contentText(content, 'sort.weight_asc'),
    'rating_desc' => _contentText(content, 'sort.rating_desc'),
    _ => _contentText(content, 'sort.relevance'),
  };
}

List<_RouteSuggestion> _parseTrendingRoutes(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((item) {
        try {
          return _RouteSuggestion(
            from: City.fromJson(Map<String, dynamic>.from(item['from'] as Map)),
            to: City.fromJson(Map<String, dynamic>.from(item['to'] as Map)),
            total: int.tryParse(item['total']?.toString() ?? '') ?? 0,
          );
        } catch (_) {
          return null;
        }
      })
      .whereType<_RouteSuggestion>()
      .toList();
}

class _RouteSuggestion {
  final City from;
  final City to;
  final int total;

  const _RouteSuggestion({
    required this.from,
    required this.to,
    required this.total,
  });
}

String _relativeTime(Map<String, String> content, String? value) {
  if (value == null) return '-';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final diff = DateTime.now().difference(date);
  if (diff.inHours < 1) return _contentText(content, 'time.now');
  if (diff.inHours < 24) {
    return _contentText(content, 'time.hours_ago_template')
        .replaceAll('{count}', '${diff.inHours}');
  }
  if (diff.inDays == 1) return _contentText(content, 'common.yesterday');
  return _contentText(content, 'time.days_ago_template')
      .replaceAll('{count}', '${diff.inDays}');
}

IconData _packageIcon(String code) {
  return switch (code) {
    'documents' => PhosphorIconsRegular.fileText,
    'small_parcel' => PhosphorIconsRegular.cube,
    'electronics' => PhosphorIconsRegular.deviceMobile,
    'clothing' => PhosphorIconsRegular.shoppingBag,
    'food' => PhosphorIconsRegular.forkKnife,
    _ => PhosphorIconsRegular.dotsThreeCircle,
  };
}

class _SimpleTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SimpleTopBar({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _ink900.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(PhosphorIconsBold.arrowLeft, color: _ink700),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: _ink900,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedEmpty extends StatelessWidget {
  final Map<String, String> content;

  const _SavedEmpty({required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          _contentText(content, 'search.saved_empty'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: _ink500, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FilterTitle extends StatelessWidget {
  final String label;

  const _FilterTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: const TextStyle(
          color: _ink700,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final Map<String, String> content;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _Segmented({
    required this.content,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _ink900.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _seg(_contentText(content, 'search.type_all'), null),
          _seg(_contentText(content, 'search.type_trip'), 'trip'),
          _seg(_contentText(content, 'search.type_shipment'), 'shipment_post'),
        ],
      ),
    );
  }

  Widget _seg(String label, String? itemValue) {
    final selected = value == itemValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(itemValue),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _brand : _ink500,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _brand50 : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? _brand : _ink900.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? _brand : _ink500, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? _brand : _ink700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _ink900.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: value ? _brand : _ink500, size: 18),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _ink700,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: value ? _brand : _ink900.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SmallInput({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(hint),
    );
  }
}

class _DateFilterBox extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateFilterBox({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ink900.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasValue ? _ink900 : _ink400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: hasValue ? onClear : onTap,
              child: Icon(
                hasValue ? PhosphorIconsBold.x : PhosphorIconsRegular.calendar,
                color: _ink400,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _ink900.withValues(alpha: 0.07)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _ink900.withValues(alpha: 0.07)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _brand),
    ),
  );
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _brand,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _brand.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TinyChip extends StatelessWidget {
  final String label;

  const _TinyChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _ink900.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _ink600,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  final Widget child;

  const _SheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: child,
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _ink300,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
