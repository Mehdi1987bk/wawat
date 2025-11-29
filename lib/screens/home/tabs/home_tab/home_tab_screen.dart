import 'package:buking/screens/home/tabs/home_tab/widget/auth_modal_utils.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/search_form_page.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/wawat_courier_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/network/response/offer_models.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../presentation/resourses/wawat_colors.dart';
import '../../../../presentation/resourses/wawat_dimensions.dart';
import '../../../../presentation/resourses/wawat_text_styles.dart';
import '../../../auth/auth_modal/auth_required_modal.dart';
import '../../../auth/login/login_modal.dart';
import '../../../auth/registration/registration_modal.dart';
import '../chat/chat_list.dart';
import 'courier_screen/courier_screen.dart';
import 'home_tab_bloc.dart';

class HomeTabScreen extends BaseScreen {
  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends BaseState<HomeTabScreen, HomeTabBloc> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _categoryController = TextEditingController();

  int _selectedTab = 0;

  @override
  Widget body() {
    return Scaffold(
      backgroundColor: WawatColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 80),
              child: Column(
                children: [
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeroSection(),
                          SearchFormWidget(
                            bloc: bloc,
                          ),
                          SizedBox(height: WawatDimensions.spacingLg),
                          _buildPopularOffers(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BuildHeader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Image.asset(
            "asset/home_ban.png",
            width: 127,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50, bottom: 10),
          child: Text(
            'Ищи тех, кто летит — и передавай посылки надёжно и быстро',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: WawatColors.textPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
          child: Text(
            'Быстрая и безопасная доставка посылок по всему миру',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: WawatColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WawatDimensions.spacingMd),
          child: Center(
            child: Text(
              'Популярные предложения',
              style: WawatTextStyles.h2,
            ),
          ),
        ),
        SizedBox(height: WawatDimensions.spacingMd),
        FutureBuilder<OfferListResponse>(
          future: bloc.myOffers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data?.data == null) {
              return const SizedBox();
            }
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 30),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.requireData.data.length,
              itemBuilder: (context, index) {
                return WawatCourierCard(
                  courier: snapshot.requireData.data[index],
                  onFavoriteToggle: (v) {
                    bloc.setFavorites(snapshot.requireData.data[index].id);
                  },
                  onDetails: () async {
                    final isLogged = await sl.get<AuthRepository>().isLogged();
                    if (!isLogged) {
                      return AuthModalUtils.showAuthRequiredModal(context);
                    } else {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return CourierDetailsScreen(
                              courier: snapshot.requireData.data[index],
                            );
                          },
                        ),
                      );
                    }
                  },
                  onMessage: () async {
                    final isLogged = await sl.get<AuthRepository>().isLogged();
                    if (!isLogged) {
                      return AuthModalUtils.showAuthRequiredModal(context);
                    } else {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return ChatScreen(
                              courier: snapshot.requireData.data[index],
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc();
  }
}

Widget BuildHeader(BuildContext context) {
  return Container(
    color: Colors.white,
    padding: EdgeInsets.all(WawatDimensions.spacingMd),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'asset/logo.png',
          fit: BoxFit.fitWidth,
          height: 40,
        ),
        GestureDetector(
          onTap: () async {
            final isLogged = await sl.get<AuthRepository>().isLogged();
            if (!isLogged) {
              return AuthModalUtils.showAuthRequiredModal(context);
            } else {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (BuildContext context) {
                return Container();
              }));
            }
          },
          child: Image.asset(
            'asset/notif_aa.png',
            fit: BoxFit.fitWidth,
            height: 40,
          ),
        ),
      ],
    ),
  );
}
