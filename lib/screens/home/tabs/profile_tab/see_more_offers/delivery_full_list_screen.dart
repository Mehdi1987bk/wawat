import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../presentation/bloc/utils.dart';
import '../../../../../presentation/resourses/wawat_dimensions.dart';
import '../../../../../presentation/resourses/wawat_text_styles.dart';
import '../../../../../services/theme_manager.dart';
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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : AppColors.bgColor,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.white,
            ),
            title: Text(
              S.of(context).bd3g345h57h4b,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.white,
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : WawatColors.primary,
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: StreamBuilder<List<OfferModel>>(
              stream: bloc.paginableList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final groups = snapshot.requireData;
                  if (groups.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: isDark
                                  ? const Color(0xFF4A4A4A)
                                  : const Color(0xFFD1D5DB),
                            ),
                            const SizedBox(height: 24),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                              child:   Text(S.of(context).gbterg534g45v4),
                            ),
                            const SizedBox(height: 8),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                              ),
                              child:   Text(
                                S.of(context).ger345g3,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
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
                             bloc
                                .editStatusOffer(
                              offer.id.toString(),
                              isVisible == true ? "active" : "archived",
                            )
                                .then((onValue) => bloc.loadList());
                          },
                          detailsActiv: false,
                          sendMessageActiv: false,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  DeliveryFullListBloc provideBloc() {
    return DeliveryFullListBloc(onPacketsAdded);
  }
}
