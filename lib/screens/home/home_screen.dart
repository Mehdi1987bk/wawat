 import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/bloc/base_screen.dart';
 import 'bottom_bar.dart';
import 'home_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

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
    return Scaffold(
      body: Stack(
        children: [
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          // return LoginScreen();
                          return Container();
                        },
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
      ),
    );
  }

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

  @override
  void initState() {
    super.initState();

    _tabs = <Widget>[
      Container(),
      Container(),
      Container(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.selectedIndex,
      children: _tabs,
    );
  }
}


