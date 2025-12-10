import 'package:buking/screens/home/tabs/home_tab/widget/auth_modal_utils.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/search_form_page.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/wawat_courier_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../data/network/response/offer_models.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../presentation/bloc/utils.dart';
import '../../../../presentation/resourses/wawat_colors.dart';
import '../../../../presentation/resourses/wawat_dimensions.dart';
import '../../../../presentation/resourses/wawat_text_styles.dart';
import '../../../../services/theme_manager.dart';
import 'home_tab_bloc.dart';
import 'notification/notification_screen.dart';

class HomeTabScreen extends BaseScreen {
  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends BaseState<HomeTabScreen, HomeTabBloc> {
  final PublishSubject<void> onPacketsAdded = PublishSubject();
  final ScrollController _scrollController = ScrollController();

  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  bool get showProgressIndicator => false;
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

  int _selectedTab = 0;

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
        return SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 80),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                       SearchFormWidget(
                        bloc: bloc,
                      ),
                      // _buildPopularOffers(isDark),
                    ],
                  ),
                ),
              ),
              BuildHeader(context, isDark),
            ],
          ),
        );
      },
    );
  }


  // Widget _buildPopularOffers(bool isDark) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SizedBox(height: WawatDimensions.spacingMd),
  //       StreamBuilder<List<OfferModel>>(
  //         stream: bloc.paginableList,
  //         builder: (context, snapshot) {
  //           if (snapshot.hasData) {
  //             final groups = snapshot.requireData;
  //             if (groups.isEmpty) {
  //               return Center(
  //                 child: Text(''),
  //               );
  //             }
  //
  //             return Column(
  //               children: [
  //                 Padding(
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: WawatDimensions.spacingMd),
  //                   child: Center(
  //                     child: AnimatedDefaultTextStyle(
  //                       duration: const Duration(milliseconds: 300),
  //                       style: WawatTextStyles.h2.copyWith(
  //                         color:
  //                         isDark ? Colors.white : WawatTextStyles.h2.color,
  //                       ),
  //                       child: Text(
  //                         'Популярные предложения',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsets.only(top: 20, bottom: 40),
  //                   child: ListView.builder(
  //                     shrinkWrap: true,
  //                     physics: const NeverScrollableScrollPhysics(),
  //                     itemCount: groups.length,
  //                     itemBuilder: (context, index) {
  //                       final offer = groups[index];
  //
  //                       return WawatCourierCard(
  //                         courier: offer,
  //                         onFavoriteToggle: (v) {
  //                           bloc.setFavorites(offer.id);
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             );
  //           }
  //
  //           return const SizedBox();
  //         },
  //       )
  //     ],
  //   );
  // }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _categoryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc(onPacketsAdded);
  }
}

Widget BuildHeader(BuildContext context, bool isDark) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: EdgeInsets.all(WawatDimensions.spacingMd),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'asset/logo.png',
          fit: BoxFit.fitWidth,
          height: 40,
          color: isDark ? Colors.white : null,
          colorBlendMode: isDark ? BlendMode.modulate : null,
        ),
        GestureDetector(
          onTap: () async {
            final isLogged = await sl.get<AuthRepository>().isLogged();
            if (!isLogged) {
              return AuthModalUtils.showAuthRequiredModal(context);
            } else {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (BuildContext context) {
                    return NotificationScreen();
                  }));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'asset/notif_aa.png',
              fit: BoxFit.fitWidth,
              height: 35,
              color: isDark ? Colors.white : null,
              colorBlendMode: isDark ? BlendMode.modulate : null,
            ),
          ),
        ),
      ],
    ),
  );
}