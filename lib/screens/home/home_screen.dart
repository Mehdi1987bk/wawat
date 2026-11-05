import 'package:buking/screens/home/tabs/create_post/create_post_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/search/search_offer_list_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/home_tab_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/auth_modal_utils.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_screen.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/bloc/base_screen.dart';
import '../auth/email_otp/email_otp_screen.dart';
import '../../services/notification_router.dart';
import '../../presentation/resourses/theme_colors.dart';
import '../chat/chat/chat_list_screen.dart';
import 'bottom_bar.dart';
import 'home_bloc.dart';
import 'scrollable_tab.dart';
import 'tabs/profile_tab/promo/app_review.dart';

class HomeScreen extends BaseScreen {
  final int? orderId;

  final int? initialTabIndex;

  HomeScreen({super.key, this.orderId, this.initialTabIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen, HomeBloc> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<__TabsState> _tabsKey = GlobalKey<__TabsState>();
  final ValueNotifier<bool> optionsNotifier = ValueNotifier(false);
  late int _selectedIndex = widget.initialTabIndex ?? 0;

  @override
  void dispose() {
    optionsNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        flushPendingNotificationNavigation();
        _maybeGateEmailVerification();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) AppReviewFlow.maybePrompt(context);
        });
      },
    );
  }

  Future<void> _maybeGateEmailVerification() async {
    final logged = await sl.get<AuthRepository>().isLogged();
    if (!logged) return;
    await presentEmailOtpIfRequired(autoSend: false);
  }

  @override
  Widget body() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        if (isDark) Positioned.fill(child: ColoredBox(color: cScreen(isDark))),
        _Tabs(
          key: _tabsKey,
          selectedIndex: _selectedIndex,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: BottomBar(
              onChanged: (index) async {
                if (index == _selectedIndex && index != 2) {
                  _tabsKey.currentState?.scrollActiveTabToTop();
                  return;
                }
                final isLogged = await sl.get<AuthRepository>().isLogged();
                if ((index != 0 && index != 1) && !isLogged) {
                  return AuthModalUtils.showAuthRequiredModal(context);
                }
                if (index == 2) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => CreatePostScreen(),
                    ),
                  );
                  return;
                }
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get resizeToAvoidBottomInset => false;

  @override
  HomeBloc provideBloc() {
    return HomeBloc();
  }
}

class _Tabs extends StatefulWidget {
  final int selectedIndex;

  _Tabs({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  __TabsState createState() => __TabsState();
}

class __TabsState extends State<_Tabs> {
  late List<Widget> _tabs;
  late final Set<int> _visitedTabs = {0, widget.selectedIndex};
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey<ChatListScreenState> _chatKey =
      GlobalKey<ChatListScreenState>();
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _tabs = <Widget>[
      HomeTabScreen(key: _homeKey),
      SearchOfferListScreen(
        key: _searchKey,
        showBackButton: false,
        openResultsInNewPage: true,
      ),
      const SizedBox.shrink(),
      ChatListScreen(key: _chatKey),
      ProfileTabScreen(key: _profileKey),
    ];
  }

  void scrollActiveTabToTop() {
    State? state;
    switch (widget.selectedIndex) {
      case 0:
        state = _homeKey.currentState;
        break;
      case 1:
        state = _searchKey.currentState;
        break;
      case 3:
        state = _chatKey.currentState;
        break;
      case 4:
        state = _profileKey.currentState;
        break;
    }
    if (state is ScrollableTab) (state as ScrollableTab).scrollToTop();
  }

  @override
  void didUpdateWidget(covariant _Tabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visitedTabs.add(widget.selectedIndex);
    if (widget.selectedIndex == 3 && oldWidget.selectedIndex != 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatKey.currentState?.refreshFromTabFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.selectedIndex,
      children: List.generate(
        _tabs.length,
        (index) => _visitedTabs.contains(index)
            ? _tabs[index]
            : const SizedBox.shrink(),
      ),
    );
  }
}
