import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/listing_response.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../presentation/bloc/utils.dart';
import '../../../../services/theme_manager.dart';
import '../home_tab/widget/auth_modal_utils.dart';
import '../home_tab/widget/search_form_page.dart';
import '../listings/details/listing_details_screen.dart';
import '../listings/listing_feed_bloc.dart';
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
  final value = content[key];
  if (value == null || value.trim().isEmpty) return fallback ?? key;
  return value;
}

class HomeTabScreen extends BaseScreen {
  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends BaseState<HomeTabScreen, HomeTabBloc> {
  final ScrollController _scrollController = ScrollController();
  late final UnreadNotificationBloc _notificationBloc;
  late final ListingFeedBloc _listingBloc;

  @override
  bool get showProgressIndicator => false;

  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    _notificationBloc = UnreadNotificationBloc()..init();
    _listingBloc = ListingFeedBloc()..init();
    _listingBloc.refreshList();

    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_scrollController.position.extentAfter <=
          MediaQuery.of(context).size.height) {
        _listingBloc.load();
      }
    });
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
              color: isDark ? const Color(0xFF101010) : const Color(0xFFEEF1F6),
              child: RefreshIndicator(
                color: _brand,
                onRefresh: _listingBloc.refreshList,
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
                        child:
                            _CommunityStats(isDark: isDark, content: content)),
                    SliverToBoxAdapter(
                        child: _PopularRoutes(
                            bloc: _listingBloc, content: content)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 16, 14),
                        child: Text(
                          _contentText(content, 'home.featured_listings'),
                          style: TextStyle(
                            color: isDark ? Colors.white : _ink900,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
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
    _notificationBloc.dispose();
    _listingBloc.dispose();
    super.dispose();
  }

  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc(const Stream.empty());
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
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F7BF4), Color(0xFF0257AE)],
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
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Text(
                          'W',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Wawatair',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w600,
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

class _CommunityStats extends StatelessWidget {
  final bool isDark;
  final Map<String, String> content;

  const _CommunityStats({
    required this.isDark,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0x0F0F172A)),
      ),
      child: Row(
        children: [
          const _OnlineDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: _contentText(content, 'home.stats_prefix'),
                children: const [
                  TextSpan(
                    text: '1,240',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, color: _ink900),
                  ),
                  TextSpan(text: ' çatdırılma · '),
                  TextSpan(
                    text: '3,500+',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, color: _ink900),
                  ),
                  TextSpan(text: ' təsdiqlənmiş səyahətçi'),
                ],
              ),
              style: TextStyle(
                color: isDark ? Colors.white70 : _ink500,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  List<String> _labels = const [
    'Bakı → İstanbul',
    'Bakı → Dubai',
    'Gəncə → London'
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      await widget.bloc.getTrendingRoutes();
    } catch (_) {
      try {
        final cities = await widget.bloc.getPopularCities();
        if (!mounted || cities.data.length < 2) return;
        setState(() {
          _labels = [
            for (var i = 0; i < cities.data.length - 1 && i < 3; i++)
              '${cities.data[i].name} → ${cities.data[i + 1].name}',
          ];
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
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
                color: isDark ? Colors.white : _ink900,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _labels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Container(
                  width: 178,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0x0F0F172A),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RouteTitle(label: _labels[index], isDark: isDark),
                      const SizedBox(height: 5),
                      Text(
                        index == 1 ? '18 səyahətçi' : '24 səyahətçi',
                        style: TextStyle(
                          color: _ink400,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        index == 1 ? '8 ₼-dən' : '5 ₼-dən',
                        style: TextStyle(
                          color: _brand,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
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
      color: isDark ? Colors.white : _ink900,
      fontSize: 14,
      fontWeight: FontWeight.w900,
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
          const TextSpan(
            text: '  →  ',
            style: TextStyle(color: _brand),
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

class _EmptyState extends StatelessWidget {
  final List suggestions;
  final Map<String, String> content;

  const _EmptyState({
    required this.suggestions,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          const Icon(PhosphorIconsRegular.magnifyingGlass,
              color: _brand, size: 54),
          const SizedBox(height: 14),
          Text(
            _contentText(content, 'search.empty_title'),
            style: const TextStyle(
              color: _ink900,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _contentText(
              content,
              'search.empty_subtitle',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
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

class _FeedEnd extends StatelessWidget {
  final bool isEnd;
  final Map<String, String> content;

  const _FeedEnd({
    required this.isEnd,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEnd) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator(color: _brand)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Text(
        _contentText(content, 'feed.end'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _ink400,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
