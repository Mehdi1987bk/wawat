import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../services/theme_aware_screen.dart';
import '../../../../services/theme_manager.dart';
import '../home_tab/home_tab_screen.dart';
import '../home_tab/widget/wawat_courier_card.dart';
import 'fovorite_offer_bloc.dart';

class FovoriteOfferListScreen extends BaseScreen {
  final String? offerType;
  final String? packageType;
  final int? cityFromId;
  final int? cityToId;
  final String? dateFrom;
  final String? dateTo;


  FovoriteOfferListScreen({
    Key? key,
    this.offerType,
    this.packageType,
    this.cityFromId,
    this.cityToId,
    this.dateFrom,
    this.dateTo,
  }) : super(key: key);

  @override
  State<FovoriteOfferListScreen> createState() =>
      _FovoriteOfferListScreenState();
}

class _FovoriteOfferListScreenState
    extends BaseState<FovoriteOfferListScreen, FovoriteOfferBloc> {
  final PublishSubject<void> onPacketsAdded = PublishSubject();
  final ScrollController _scrollController = ScrollController();
  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();

    bloc.load();
    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_scrollController.position.extentAfter <=
          MediaQuery.of(context).size.height) {
        bloc.load();
      }
    });
  }

  Widget body() {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    return ThemeAwareScreen(
      isDark: isDark,
      child: SafeArea(
        child: RefreshIndicator(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          color: isDark ? const Color(0xFF6366F1) : null,
          onRefresh: () {
            return bloc.loadList();
          },
          child: Stack(
            children: [
              BuildHeader(context, isDark),
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    StreamBuilder<List<OfferModel>>(
                      stream: bloc.paginableList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final groups = snapshot.requireData;
                          if (groups.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top:
                                    MediaQuery.of(context).size.height / 3),
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFFB0B0B0)
                                          : const Color(0xFF6B7280),
                                    ),
                                    child: Text("Нет избранных"),
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverPadding(
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, groupIndex) {
                                  final offer = groups[groupIndex];

                                  return WawatCourierCard(
                                    courier: offer,
                                    onFavoriteToggle: (v) {
                                      bloc.setFavorites(offer.id);
                                    },
                                  );
                                },
                                childCount: groups.length,
                              ),
                            ),
                            padding: EdgeInsets.only(top: 20, bottom: 120),
                          );
                        }
                        return const SliverToBoxAdapter(child: SizedBox());
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  FovoriteOfferBloc provideBloc() {
    return FovoriteOfferBloc(onPacketsAdded);
  }
}
