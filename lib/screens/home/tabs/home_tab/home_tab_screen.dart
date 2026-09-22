import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/popular_routes_response.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../presentation/bloc/utils.dart';
import '../../scrollable_tab.dart';
import '../../../../presentation/resourses/theme_colors.dart';
import '../../../../presentation/resourses/wawat_dark.dart';
import '../../../../services/wawat_content.dart';
import '../../../../services/home_stats_service.dart';
import '../../../../presentation/common/locale_aware_refetch.dart';
import '../../../../services/localization_service.dart';
import '../../../../services/theme_manager.dart';
import '../home_tab/widget/auth_modal_utils.dart';
import '../home_tab/widget/search_form_page.dart';
import '../home_tab/search/search_offer_list_screen.dart';
import '../listings/details/listing_details_screen.dart';
import '../listings/listing_feed_bloc.dart';
import '../../../../services/telemetry/telemetry.dart';
import '../../../../services/telemetry/telemetry_events.dart';
import '../listings/widgets/listing_card.dart';
import 'home_tab_bloc.dart';
import 'notification/notification_screen.dart';
import 'notification/unread_notif_bloc.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

String _contentText(Map<String, String> content, String key,
    [String? fallback]) {
  return WawatContent.text(content, key, fallback);
}

class HomeTabScreen extends BaseScreen {
  HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends BaseState<HomeTabScreen, HomeTabBloc>
    with ScrollableTab, LocaleAwareRefetch {
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

  late final UnreadNotificationBloc _notificationBloc;
  late final ListingFeedBloc _listingBloc;
  late final HomeStatsService _homeStatsService;
  HomeStats? _homeStats;
  bool _homeStatsLoading = true;

  @override
  bool get showProgressIndicator => false;

  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    // Shared app-wide singleton (realtime new_notification updates its badge);
    // refresh its count on open, but never dispose it here.
    _notificationBloc = sl.get<UnreadNotificationBloc>()..fetchUnreadCount();
    _listingBloc = ListingFeedBloc()..init();
    _listingBloc.refreshList();
    _homeStatsService = HomeStatsService();
    unawaited(_loadHomeStats());

    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_scrollController.position.extentAfter <=
          MediaQuery.of(context).size.height) {
        _listingBloc.load();
      }
    });
  }

  Future<void> _loadHomeStats() async {
    final cached = await _homeStatsService.loadCached();
    if (!mounted) return;
    if (cached != null) {
      setState(() => _homeStats = cached);
    }

    try {
      final fresh = await _homeStatsService.refresh();
      if (!mounted) return;
      setState(() {
        _homeStats = fresh;
        _homeStatsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _homeStatsLoading = false);
    }
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      _listingBloc.refreshList(),
      _loadHomeStats(),
    ]);
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
        return StreamBuilder<Map<String, String>>(
          stream: _listingBloc.listingContent,
          initialData: const {},
          builder: (context, contentSnapshot) {
            final content = contentSnapshot.data ?? const {};
            return Container(
              color: isDark ? cScreen(true) : const Color(0xFFEEF1F6),
              child: RefreshIndicator(
                color: _brand,
                onRefresh: _refreshHome,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _HeroSearchSection(
                        notificationBloc: _notificationBloc,
                        listingBloc: _listingBloc,
                        content: content,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _HomeStatsSlot(
                        isDark: isDark,
                        stats: _homeStats,
                        loading: _homeStatsLoading,
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: _PopularRoutes(
                            bloc: _listingBloc, content: content)),
                    StreamBuilder<List<Listing>>(
                      stream: _listingBloc.paginableList,
                      builder: (context, snapshot) {
                        final listings = snapshot.data;
                        if (listings == null) {
                          return const SliverToBoxAdapter(
                              child: _ListingSkeleton());
                        }

                        if (listings.isEmpty) {
                          return SliverToBoxAdapter(
                            child: StreamBuilder(
                              stream: _listingBloc.suggestions,
                              initialData: const [],
                              builder: (context, suggestionsSnapshot) {
                                return _EmptyState(
                                  suggestions:
                                      suggestionsSnapshot.data ?? const [],
                                  content: content,
                                );
                              },
                            ),
                          );
                        }

                        return StreamBuilder<Map<String, String>>(
                          stream: _listingBloc.packageNamesByCode,
                          initialData: const {},
                          builder: (context, packagesSnapshot) {
                            final packageNames =
                                packagesSnapshot.data ?? const {};
                            return SliverList.builder(
                              itemCount: listings.length + 1,
                              itemBuilder: (context, index) {
                                if (index == listings.length) {
                                  return _FeedEnd(
                                    isEnd:
                                        _listingBloc.lastPagination != null &&
                                            (_listingBloc.lastPagination!
                                                        .currentPage ??
                                                    1) >=
                                                _listingBloc
                                                    .lastPagination!.lastPage,
                                    content: content,
                                  );
                                }
                                final listing = listings[index];
                                final isVip = _isVipListing(listing);
                                final previousWasVip = index > 0 &&
                                    _isVipListing(listings[index - 1]);
                                final showVipHeader = index == 0 && isVip;
                                final showAllHeader =
                                    !isVip && (index == 0 || previousWasVip);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showVipHeader)
                                      _FeedSectionTitle(
                                        label: _contentText(
                                          content,
                                          'promotion.section.vip',
                                          'VİP elanlar',
                                        ),
                                        isDark: isDark,
                                        vip: true,
                                      ),
                                    if (showAllHeader)
                                      _FeedSectionTitle(
                                        label: _contentText(
                                          content,
                                          'promotion.section.all',
                                          'Bütün elanlar',
                                        ),
                                        isDark: isDark,
                                      ),
                                    ListingCard(
                                      listing: listing,
                                      packageNamesByCode: packageNames,
                                      isCompact: true,
                                      onDetailsTap: _openDetails,
                                      onFavoriteChanged: _onFavoriteChanged,
                                      onOfferTap: (listing) =>
                                          showListingProposalFlow(
                                        context,
                                        listing: listing,
                                        packageNamesByCode: packageNames,
                                        content: content,
                                      ),
                                      onMessageTap: (listing) =>
                                          openListingChat(
                                        context,
                                        listing: listing,
                                        content: content,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 108)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onFavoriteChanged(Listing listing, bool nextValue) async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      throw StateError('auth_required');
    }
    await _listingBloc.setFavorite(listing, nextValue);
  }

  void _openDetails(Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailsScreen(listingId: listing.id),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // _notificationBloc is a shared singleton — do not dispose it here.
    _listingBloc.dispose();
    super.dispose();
  }

  @override
  void onLocaleChanged() {
    _listingBloc.reloadForLocaleChange();
    unawaited(_loadHomeStats());
  }

  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc(const Stream.empty());
  }
}

bool _isVipListing(Listing listing) {
  return (listing.promotion?.type ?? listing.promotionType) == 'vip';
}

class _FeedSectionTitle extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool vip;

  const _FeedSectionTitle({
    required this.label,
    required this.isDark,
    this.vip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 14),
      child: Row(
        children: [
          if (vip) ...[
            const Icon(
              PhosphorIconsFill.crownSimple,
              color: Color(0xFFF59E0B),
              size: 18,
            ),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: TextStyle(
              color: isDark ? cText(true) : _ink900,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSearchSection extends StatelessWidget {
  static const double _heroHeight = 326;
  static const double _searchHeight = 251;
  static const double _searchOverlap = 125;
  static const double _bottomGap = 10;

  final UnreadNotificationBloc notificationBloc;
  final ListingFeedBloc listingBloc;
  final Map<String, String> content;

  const _HeroSearchSection({
    required this.notificationBloc,
    required this.listingBloc,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _heroHeight + _searchHeight - _searchOverlap + _bottomGap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HeroHeader(
              bloc: notificationBloc,
              height: _heroHeight,
              content: content,
            ),
          ),
          Positioned(
            top: _heroHeight - _searchOverlap,
            left: 0,
            right: 0,
            child: SearchFormWidget(bloc: listingBloc),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final UnreadNotificationBloc bloc;
  final double height;
  final Map<String, String> content;

  const _HeroHeader({
    required this.bloc,
    required this.height,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0C57C9), Color(0xFF072F6E), Color(0xFF0A1B3E)]
              : const [Color(0xFF0F7BF4), Color(0xFF0257AE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HeroPathPainter())),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 168,
                        height: 40,
                        child: Image.asset(
                          'asset/wawatair_bluewhite.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      const Spacer(),
                      StreamBuilder<int>(
                        stream: bloc.unreadCountStream,
                        initialData: 0,
                        builder: (context, snapshot) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              final isLogged =
                                  await sl.get<AuthRepository>().isLogged();
                              if (!context.mounted) return;
                              if (!isLogged) {
                                AuthModalUtils.showAuthRequiredModal(context);
                                return;
                              }
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => NotificationScreen(),
                                ),
                              );
                              bloc.fetchUnreadCount();
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    PhosphorIconsRegular.bell,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                if ((snapshot.data ?? 0) > 0)
                                  Positioned(
                                    right: 1,
                                    top: 1,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF2FC2A),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _contentText(
                      content,
                      'home.hero_title',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _contentText(
                      content,
                      'home.hero_subtitle',
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(-10, 210)
      ..quadraticBezierTo(size.width * 0.48, 112, size.width + 20, 186);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawCircle(const Offset(60, 150), 3.5, dotPaint);
    dotPaint.color = const Color(0xFFF2FC2A).withValues(alpha: 0.70);
    canvas.drawCircle(Offset(size.width - 40, 170), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeStatsSlot extends StatelessWidget {
  final bool isDark;
  final HomeStats? stats;
  final bool loading;

  const _HomeStatsSlot({
    required this.isDark,
    required this.stats,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final value = stats;
    if (value != null) {
      final template = LocalizationService.instance.rawValue(
        'home.stats_summary',
      );
      if (template == null) return const SizedBox.shrink();
      return _CommunityStats(
        isDark: isDark,
        stats: value,
        template: template,
      );
    }
    if (!loading) return const SizedBox.shrink();

    return Container(
      height: 55,
      margin: const EdgeInsets.only(left: 24, right: 24, top: 20),
      decoration: BoxDecoration(
        color: isDark ? cCard(true) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? WawatDark.border : const Color(0x0F0F172A),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const _OnlineDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.border : const Color(0xFFE8ECF2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _CommunityStats extends StatelessWidget {
  const _CommunityStats({
    required this.isDark,
    required this.stats,
    required this.template,
  });

  final bool isDark;
  final HomeStats stats;
  final String template;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final numberFormat = NumberFormat.decimalPattern(locale);
    final values = <String, String>{
      'deliveries': numberFormat.format(stats.deliveriesThisMonth),
      'verified': numberFormat.format(stats.verifiedTravelers),
    };

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? cCard(true) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? WawatDark.border : const Color(0x0F0F172A)),
      ),
      child: Row(
        children: [
          const _OnlineDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: _summarySpans(template, values, isDark),
              ),
              style: TextStyle(
                color: isDark ? cText2(true) : _ink500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<InlineSpan> _summarySpans(
  String template,
  Map<String, String> values,
  bool isDark,
) {
  final placeholders = RegExp(r'\{(deliveries|verified)\}');
  final spans = <InlineSpan>[];
  var start = 0;

  for (final match in placeholders.allMatches(template)) {
    if (match.start > start) {
      spans.add(TextSpan(text: template.substring(start, match.start)));
    }
    final key = match.group(1)!;
    spans.add(
      TextSpan(
        text: values[key],
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? cText(true) : _ink900,
        ),
      ),
    );
    start = match.end;
  }
  if (start < template.length) {
    spans.add(TextSpan(text: template.substring(start)));
  }
  return spans;
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PopularRoutes extends StatefulWidget {
  final ListingFeedBloc bloc;
  final Map<String, String> content;

  const _PopularRoutes({
    required this.bloc,
    required this.content,
  });

  @override
  State<_PopularRoutes> createState() => _PopularRoutesState();
}

class _PopularRoutesState extends State<_PopularRoutes> {
  List<PopularRoute> _routes = const [];
  bool _openingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final response = await widget.bloc.getPopularRoutes();
      if (!mounted) return;
      setState(() => _routes = response.data.take(3).toList(growable: false));
    } catch (_) {
      if (!mounted) return;
      setState(() => _routes = const []);
    }
  }

  Future<void> _openRoute(PopularRoute route) async {
    if (_openingRoute) return;
    setState(() => _openingRoute = true);

    final filters = ListingFilterState(
      cityFrom: route.fromCity,
      cityTo: route.toCity,
    );
    try {
      Telemetry.instance.event(TelemetryEvents.trendingRouteTapped, params: {
        TelemetryParams.fromCity: route.cityFrom,
        TelemetryParams.toCity: route.cityTo,
      });
      logSearchEvent(filters, source: 'popular_route');
      await widget.bloc.saveRecentSearch(filters);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SearchOfferListScreen(filters: filters),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_routes.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              _contentText(
                widget.content,
                'home.popular_routes',
              ),
              style: TextStyle(
                color: isDark ? cText(true) : _ink900,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _routes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final route = _routes[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openRoute(route),
                  child: Container(
                    width: 178,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? cCard(true) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            isDark ? WawatDark.border : const Color(0x0F0F172A),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RouteTitle(label: route.label, isDark: isDark),
                        const SizedBox(height: 5),
                        Text(
                          _contentText(
                                  widget.content,
                                  'home.route_travelers_template',
                                  '{count} səyahətçi')
                              .replaceAll('{count}', '${route.travelersCount}'),
                          style: TextStyle(
                            color: isDark ? cMuted(true) : _ink400,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _contentText(
                                  widget.content,
                                  'home.route_price_from_template',
                                  '{price} \$-dən')
                              .replaceAll('{price}', route.formattedMinPrice),
                          style: TextStyle(
                            color: isDark ? cBrandText(true) : _brand,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

class _RouteTitle extends StatelessWidget {
  final String label;
  final bool isDark;

  const _RouteTitle({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final parts = label.split('→');
    final baseStyle = TextStyle(
      color: isDark ? cText(true) : _ink900,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    if (parts.length != 2) {
      return Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.first.trim()),
          TextSpan(
            text: '  →  ',
            style: TextStyle(color: isDark ? cBrandText(true) : _brand),
          ),
          TextSpan(text: parts.last.trim()),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: baseStyle,
    );
  }
}

class _ListingSkeleton extends StatelessWidget {
  const _ListingSkeleton();

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

class _EmptyState extends StatelessWidget {
  final List suggestions;
  final Map<String, String> content;

  const _EmptyState({
    required this.suggestions,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.magnifyingGlass,
              color: isDark ? cBrandText(true) : _brand, size: 54),
          const SizedBox(height: 14),
          Text(
            _contentText(content, 'search.empty_title'),
            style: TextStyle(
              color: isDark ? cText(true) : _ink900,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _contentText(
              content,
              'search.empty_subtitle',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? cText2(true) : _ink500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
                  color: isDark ? cBrandSoft(true) : _brand50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.label!,
                  style: TextStyle(
                    color: isDark ? cBrandText(true) : _brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _FeedEnd extends StatelessWidget {
  final bool isEnd;
  final Map<String, String> content;

  const _FeedEnd({
    required this.isEnd,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isEnd) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: CircularProgressIndicator(
            color: isDark ? cBrandText(true) : _brand,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Text(
        _contentText(content, 'feed.end'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? cMuted(true) : _ink400,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
