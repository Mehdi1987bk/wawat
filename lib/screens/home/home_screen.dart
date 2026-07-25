import 'package:buking/screens/home/tabs/create_post/create_post_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/search/search_offer_list_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/home_tab_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/auth_modal_utils.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_screen.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/bloc/base_screen.dart';
import '../../presentation/resourses/theme_colors.dart';
import '../chat/chat/chat_list_screen.dart';
import 'bottom_bar.dart';
import 'home_bloc.dart';
import 'tabs/profile_tab/promo/app_review.dart';

class HomeScreen extends BaseScreen {
  final int? orderId;

  HomeScreen({super.key, this.orderId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen, HomeBloc> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
          selectedIndex: _selectedIndex,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: BottomBar(
              onChanged: (index) async {
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
  final GlobalKey<ChatListScreenState> _chatKey =
      GlobalKey<ChatListScreenState>();

  @override
  void initState() {
    super.initState();

    _tabs = <Widget>[
      HomeTabScreen(),
      SearchOfferListScreen(
        showBackButton: false,
        openResultsInNewPage: true,
      ),
      const SizedBox.shrink(),
      ChatListScreen(key: _chatKey),
      ProfileTabScreen(),
    ];
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
