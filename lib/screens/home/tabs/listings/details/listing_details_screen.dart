import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../../home_tab/widget/auth_modal_utils.dart';
import '../widgets/listing_card.dart';
import 'listing_details_bloc.dart';

const _brand = Color(0xFF0271EB);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);

class ListingDetailsScreen extends BaseScreen<ListingDetailsBloc> {
  final String listingId;

  ListingDetailsScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState
    extends BaseState<ListingDetailsScreen, ListingDetailsBloc> {
  late Future<ListingResponse> _detailsFuture;

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    bloc.loadPackageTypes();
    _detailsFuture = bloc.getDetails(widget.listingId);
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
        return ThemeAwareScreen(
          isDark: isDark,
          lightBackgroundColor: const Color(0xFFEEF1F6),
          darkBackgroundColor: const Color(0xFF101010),
          child: SafeArea(
            child: FutureBuilder<ListingResponse>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _TopBar(isDark: isDark)),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SliverToBoxAdapter(child: _DetailsSkeleton())
                    else if (snapshot.hasError)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ErrorState(onRetry: _reload),
                      )
                    else if (snapshot.hasData)
                      ..._content(snapshot.requireData)
                    else
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ErrorState(onRetry: _reload),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _content(ListingResponse response) {
    final listing = response.data;
    final similar = response.meta?.similar ?? const <Listing>[];
    return [
      SliverToBoxAdapter(
        child: ListingCard(
          listing: listing,
          packageNamesByCode: bloc.packageNamesByCode,
          isCompact: false,
          onFavoriteChanged: _onFavoriteChanged,
          onOfferTap: _requireAuth,
          onMessageTap: _requireAuth,
        ),
      ),
      SliverToBoxAdapter(child: _DescriptionBlock(listing: listing)),
      if (similar.isNotEmpty) const SliverToBoxAdapter(child: _SimilarTitle()),
      if (similar.isNotEmpty)
        SliverList.builder(
          itemCount: similar.length,
          itemBuilder: (context, index) {
            final item = similar[index];
            return ListingCard(
              listing: item,
              packageNamesByCode: bloc.packageNamesByCode,
              isCompact: true,
              onDetailsTap: (listing) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ListingDetailsScreen(listingId: listing.id),
                  ),
                );
              },
              onFavoriteChanged: _onFavoriteChanged,
              onOfferTap: _requireAuth,
              onMessageTap: _requireAuth,
            );
          },
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
    ];
  }

  Future<void> _onFavoriteChanged(Listing listing, bool nextValue) async {
    final isLogged = await bloc.isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      throw StateError('auth_required');
    }
    await bloc.setFavorite(listing, nextValue);
  }

  void _requireAuth(Listing listing) async {
    final isLogged = await bloc.isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu axın növbəti mərhələdə qoşulacaq.')),
    );
  }

  void _reload() {
    setState(() {
      _detailsFuture = bloc.getDetails(widget.listingId);
    });
  }

  @override
  ListingDetailsBloc provideBloc() {
    return ListingDetailsBloc();
  }
}

class _TopBar extends StatelessWidget {
  final bool isDark;

  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : _ink900;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.arrow_back, color: titleColor),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          Text(
            'Elan detalları',
            style: TextStyle(
              color: titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  final Listing listing;

  const _DescriptionBlock({required this.listing});

  @override
  Widget build(BuildContext context) {
    if (listing.description == null || listing.description!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0x0F0F172A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Təsvir',
            style: TextStyle(
              color: isDark ? Colors.white : _ink900,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            listing.description!,
            style: TextStyle(
              color: isDark ? Colors.white70 : _ink500,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarTitle extends StatelessWidget {
  const _SimilarTitle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        'Oxşar elanlar',
        style: TextStyle(
          color: isDark ? Colors.white : _ink900,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 360,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EBF1),
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EBF1),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _brand, size: 56),
            const SizedBox(height: 14),
            const Text(
              'Elan tapılmadı',
              style: TextStyle(
                color: _ink900,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elan silinmiş, moderasiyada ola bilər və ya sənə açıq deyil.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink500,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onRetry,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _brand,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Yenidən yoxla',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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
