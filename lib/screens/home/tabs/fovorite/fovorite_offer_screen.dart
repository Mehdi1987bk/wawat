import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../home_tab/notification/unread_notif_bloc.dart';
import '../home_tab/widget/auth_modal_utils.dart';
import '../listings/details/listing_details_screen.dart';
import '../listings/widgets/listing_card.dart';
import 'fovorite_offer_bloc.dart';

const _brand = Color(0xFF0271EB);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

class FovoriteOfferListScreen extends BaseScreen {
  FovoriteOfferListScreen({super.key});

  @override
  State<FovoriteOfferListScreen> createState() =>
      _FovoriteOfferListScreenState();
}

class _FovoriteOfferListScreenState
    extends BaseState<FovoriteOfferListScreen, FovoriteOfferBloc> {
  final ScrollController _scrollController = ScrollController();
  late final UnreadNotificationBloc _notificationBloc;

  @override
  bool get useSystemOverlay => false;

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    _notificationBloc = UnreadNotificationBloc()..init();
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
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    return ThemeAwareScreen(
      isDark: isDark,
      lightBackgroundColor: const Color(0xFFEEF1F6),
      darkBackgroundColor: const Color(0xFF101010),
      child: SafeArea(
        child: RefreshIndicator(
          color: _brand,
          onRefresh: bloc.loadList,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: _FavoritesHeader(bloc: _notificationBloc)),
              StreamBuilder<List<Listing>>(
                stream: bloc.paginableList,
                builder: (context, snapshot) {
                  final listings = snapshot.data;
                  if (listings == null) {
                    return const SliverToBoxAdapter(child: _FavoriteSkeleton());
                  }

                  if (listings.isEmpty) {
                    return const SliverToBoxAdapter(child: _EmptyFavorites());
                  }

                  return SliverList.builder(
                    itemCount: listings.length + 1,
                    itemBuilder: (context, index) {
                      if (index == listings.length) {
                        return const SizedBox(height: 112);
                      }
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        packageNamesByCode: bloc.packageNamesByCode,
                        isCompact: true,
                        onDetailsTap: _openDetails,
                        onFavoriteChanged: _onFavoriteChanged,
                        onOfferTap: (listing) => showListingProposalFlow(
                          context,
                          listing: listing,
                          packageNamesByCode: bloc.packageNamesByCode,
                        ),
                        onMessageTap: (listing) => openListingChat(
                          context,
                          listing: listing,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
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
    _notificationBloc.dispose();
    super.dispose();
  }

  @override
  FovoriteOfferBloc provideBloc() {
    return FovoriteOfferBloc();
  }
}

class _FavoritesHeader extends StatelessWidget {
  final UnreadNotificationBloc bloc;

  const _FavoritesHeader({required this.bloc});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _ink900;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.arrow_back, color: titleColor),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sevimlilər',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Yadda saxladığın elanlar',
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

class _FavoriteSkeleton extends StatelessWidget {
  const _FavoriteSkeleton();

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

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.22),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, size: 64, color: _brand),
          const SizedBox(height: 14),
          Text(
            'Hələ sevimli elan yoxdur',
            style: TextStyle(
              color: isDark ? Colors.white : _ink900,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Text(
              'Bəyəndiyin elanları ürək işarəsi ilə burada saxla.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : _ink500,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
