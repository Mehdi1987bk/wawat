import 'package:flutter/material.dart';

import '../../../../data/network/response/all_request_data.dart';
import '../../../../data/network/response/packages_response.dart';
import '../../../../data/network/response/user.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../presentation/bloc/utils.dart';
import 'home_tab_bloc.dart';
import 'widget/package_list.dart';
import 'widget/sales_vidget.dart';
import 'widget/user_details_widget.dart';

class HomeTabScreen extends BaseScreen {
  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends BaseState<HomeTabScreen, HomeTabBloc> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      hideKeyboardOnScroll(context, _scrollController);
      if (_scrollController.position.extentAfter <= MediaQuery.of(context).size.height) {}
    });
  }

  @override
  Widget body() {
    return Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "asset/bag_1.png",
              height: 400,
            )),
        Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "asset/bag_2.png",
              height: 400,
            )),
        ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20),
                  child: Text(
                    "Salam",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: Image.asset(
                    "asset/notif.png",
                    width: 40,
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc();
  }
}
