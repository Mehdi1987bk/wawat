import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../presentation/resourses/wawat_dimensions.dart';
import '../../../../../presentation/resourses/wawat_text_styles.dart';
import '../../home_tab/widget/wawat_courier_card.dart';
import '../widgte/delivery_history_widget.dart';
import 'delivery_full_list_bloc.dart';

class DeliveryFullListScreen extends BaseScreen {
  DeliveryFullListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DeliveryFullListScreen> createState() => _DeliveryFullListScreenState();
}

class _DeliveryFullListScreenState
    extends BaseState<DeliveryFullListScreen, DeliveryFullListBloc> {
  final PublishSubject<void> onPacketsAdded = PublishSubject();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get showProgressIndicator => false;

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
    return Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Истории обьявления',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: WawatColors.primary,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: StreamBuilder<List<OfferModel>>(
            stream: bloc.paginableList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final groups = snapshot.requireData;
                if (groups.isEmpty) {
                  return Center(
                    child: Text(''),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 40),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final offer = groups[index];

                      return WawatCourierCard(
                          courier: offer,
                          onFavoriteToggle: (v) {},
                          onVisibilityToggle: (bool isVisible) {
                             print('Видимость изменена: $isVisible');
                            bloc.editStatusOffer(
                              offer.id.toString(),
                              isVisible == true ? "active" : "deleted",
                            ).then((onValue) => bloc.loadList());
                          },
                          detailsActiv: false,
                          sendMessageActiv: false);
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ));
  }

  @override
  DeliveryFullListBloc provideBloc() {
    return DeliveryFullListBloc(onPacketsAdded);
  }
}
