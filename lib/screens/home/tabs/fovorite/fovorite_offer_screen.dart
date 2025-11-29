import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../chat/chat_list.dart';
import '../home_tab/courier_screen/courier_screen.dart';
import '../home_tab/widget/auth_modal_utils.dart';
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
  PreferredSizeWidget? appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Избранных',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget body() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () {
          return bloc.loadList();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverToBoxAdapter(
            //   child: NavigatorPop(title: S.of(context).notifications,),
            // ),
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
                          final offer =
                              groups[groupIndex]; // одна группа (date + items)

                          return WawatCourierCard(
                            courier: offer,
                            onFavoriteToggle: (v) {
                              bloc.setFavorites(offer.id);
                            },
                            onDetails: () async {
                              final isLogged =
                                  await sl.get<AuthRepository>().isLogged();
                              if (!isLogged) {
                                return AuthModalUtils.showAuthRequiredModal(
                                    context);
                              } else {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (BuildContext context) {
                                      return CourierDetailsScreen(
                                        courier: offer,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            onMessage: () async {
                              final isLogged =
                                  await sl.get<AuthRepository>().isLogged();
                              if (!isLogged) {
                                return AuthModalUtils.showAuthRequiredModal(
                                    context);
                              } else {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (BuildContext context) {
                                      return ChatScreen(
                                        courier: offer,
                                      );
                                    },
                                  ),
                                );
                              }
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
    );
  }

  @override
  FovoriteOfferBloc provideBloc() {
    return FovoriteOfferBloc(onPacketsAdded);
  }
}
