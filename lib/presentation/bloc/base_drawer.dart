import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base_bloc.dart';
import 'bloc_provider.dart';

abstract class BaseDrawer<Bloc extends BaseBloc> extends StatefulWidget {
  BaseDrawer({Key? key}) : super(key: key);
}

abstract class BaseState<T extends BaseDrawer, Bloc extends BaseBloc>
    extends State<T> {
  late Bloc bloc;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    bloc = provideBloc();
    bloc.init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<Bloc>(bloc: bloc, child: body());
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  bool get primary => true;

  Bloc provideBloc();

  Widget body();
}
