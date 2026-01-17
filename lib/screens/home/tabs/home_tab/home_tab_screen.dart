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

  @override
  bool get showProgressIndicator => false;

  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    _notificationBloc = UnreadNotificationBloc();
    _notificationBloc.init();
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
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      SearchFormWidget(bloc: bloc),
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
    super.dispose();
  }

  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc(onPacketsAdded);
  }
}
