import 'package:buking/screens/home/tabs/home_tab/search/search_offer_bloc.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/auth_modal_utils.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/build_header.dart';
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
import '../../../../generated/l10n.dart';
import '../../../splesh/Intro_page.dart';
import 'home_tab_bloc.dart';
import 'notification/notification_bloc.dart';
import 'notification/notification_screen.dart';
import 'notification/unread_notif_bloc.dart';

class HomeTabScreen extends BaseScreen {
  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState
    extends BaseState<HomeTabScreen, HomeTabBloc> {
  final PublishSubject<void> onPacketsAdded = PublishSubject();
  final ScrollController _scrollController = ScrollController();

  late final UnreadNotificationBloc _notificationBloc;
  late final SearchOfferBloc _offerBloc;

  @override
  bool get showProgressIndicator => false;

  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    _notificationBloc = UnreadNotificationBloc();
    _notificationBloc.init();

    // Инициализация блока офферов
    _offerBloc = SearchOfferBloc(onPacketsAdded);
    _offerBloc.init();
    // Не передаем параметры - все nullable
    _offerBloc.setSearchParams();
    _offerBloc.load();

    // Добавляем слушатель для пагинации
    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_scrollController.position.extentAfter <= MediaQuery.of(context).size.height) {
        _offerBloc.load();
      }
    });
  }

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
                child: RefreshIndicator(
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  color: isDark ? const Color(0xFF6366F1) : null,
                  onRefresh: () {
                    return _offerBloc.loadList();
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [

                      SliverToBoxAdapter(child: buildHeroSection(context, isDark)),
                      // Search Form
                      SliverToBoxAdapter(
                        child: SearchFormWidget(bloc: bloc),
                      ),

                      // Offers List
                      StreamBuilder<List<OfferModel>>(
                        stream: _offerBloc.paginableList,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final offers = snapshot.requireData;

                            if (offers.isEmpty) {
                              return SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height / 5,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: isDark
                                              ? const Color(0xFF4A4A4A)
                                              : const Color(0xFFD1D5DB),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          S.of(context).vetg3rwce3f4,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? const Color(0xFFB0B0B0)
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                        SizedBox(height: 100,)
,                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return SliverPadding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 20,

                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                    final offer = offers[index];
                                    return WawatCourierCard(
                                      courier: offer,
                                      onFavoriteToggle: (v) {
                                        _offerBloc.setFavorites(offer.id);
                                      },
                                    );
                                  },
                                  childCount: offers.length,
                                ),
                              ),
                            );
                          }

                          // Показываем индикатор загрузки только если данных еще нет
                          if (!snapshot.hasData) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: isDark
                                        ? const Color(0xFF6366F1)
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }

                          return const SliverToBoxAdapter(child: SizedBox());
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔔 HEADER
              StreamBuilder<int>(
                stream: _notificationBloc.unreadCountStream,
                initialData: 0,
                builder: (context, snapshot) {
                  return BuildHeader(
                    context,
                    isDark: isDark,
                    unreadCount: snapshot.data ?? 0,
                    onNotificationsReturned: () {
                      _notificationBloc.fetchUnreadCount();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notificationBloc.dispose();
    _offerBloc.dispose();
    super.dispose();
  }

  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc(onPacketsAdded);
  }
}