import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
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

  @override
  Widget body() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () {
          return bloc.loadList();
        },
        child: Stack(
          children: [
            BuildHeader(context),
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
                                  top: MediaQuery.of(context).size.height / 3),
                              child: Center(
                                child: Text("Нет избранных"),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, groupIndex) {
                                final offer = groups[
                                    groupIndex]; // одна группа (date + items)

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
    );
  }

  @override
  FovoriteOfferBloc provideBloc() {
    return FovoriteOfferBloc(onPacketsAdded);
  }
}
