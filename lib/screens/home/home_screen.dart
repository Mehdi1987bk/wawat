import 'package:buking/screens/home/tabs/create_post/create_post_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/search/search_offer_list_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/home_tab_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/auth_modal_utils.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_screen.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/bloc/base_screen.dart';
import '../../services/notification_router.dart';
import '../../presentation/resourses/theme_colors.dart';
import '../chat/chat/chat_list_screen.dart';
import 'bottom_bar.dart';
import 'home_bloc.dart';
import 'scrollable_tab.dart';
import 'tabs/profile_tab/promo/app_review.dart';

class HomeScreen extends BaseScreen {
  final int? orderId;

  HomeScreen({super.key, this.orderId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen, HomeBloc> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<__TabsState> _tabsKey = GlobalKey<__TabsState>();
  final ValueNotifier<bool> optionsNotifier = ValueNotifier(false);
  int _selectedIndex = 0;

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
        // Route a cold-start push tap now that Home is mounted. main() cannot
        // flush it (SpleshScreen would replace the pushed route on its way to
        // Home); doing it here pushes the target on TOP of Home instead.
        flushPendingNotificationNavigation();
        // Backend-gated store-review reward prompt (shows only when the API
        // says should_show; frequency/timing is decided server-side).
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) AppReviewFlow.maybePrompt(context);
        });
        // if (widget.purchasedProduct != null) {
        //   showDialog(
        //     context: context,
        //     builder: (_) {
        //       return RateDialog(
        //         onchanged: (rate) {
        //           bloc
        //               .raiting(RaitingRequest(
        //               productId: widget.purchasedProduct?.id ?? 0,
        //               orderId: widget.orderId ?? 0,
        //               point: rate))
        //               .then(
        //                 (value) => showDialog(
        //               context: context,
        //               builder: (_) {
        //                 return RateTrue();
        //               },
        //             ),
        //           );
        //         },
        //       );
        //     },
        //   );
        // }
      },
    );
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
                // Re-tapping the already-active tab scrolls it back to the top.
                // Switching to a different tab just restores where you left off
                // (the tabs live in an IndexedStack, so offset is preserved) —
                // only a second tap on that tab scrolls it up.
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
  bool get resizeToAvoidBottomInset => false; // ← ДОБАВЛЕНА ЭТА СТРОКА

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
  final Set<int> _visitedTabs = {0};
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

  /// Scrolls the currently-selected tab back to the top (used when its own tab
  /// button is tapped again). Tabs implement [ScrollableTab].
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
    // `state` is typed as State, so `is` doesn't promote to the unrelated
    // ScrollableTab mixin — cast explicitly (guarded by the check).
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
