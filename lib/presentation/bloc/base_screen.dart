import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import '../resourses/app_colors.dart';
import 'base_bloc.dart';
import 'bloc_provider.dart';

abstract class BaseScreen<Bloc extends BaseBloc> extends StatefulWidget {
  BaseScreen({Key? key}) : super(key: key);
}

abstract class BaseState<T extends BaseScreen, Bloc extends BaseBloc>
    extends State<T> with AutomaticKeepAliveClientMixin {
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
    super.build(context);
    return BlocProvider<Bloc>(
      bloc: bloc,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          key: scaffoldKey,
          appBar: appBar(),
          drawer: drawer(),
          backgroundColor: AppColors.bgColor,
          primary: primary,
          drawerEdgeDragWidth: drawerEdgeDragWidth,
          bottomNavigationBar: bottomNavigationBar(),
          floatingActionButton: floatingActionButton(),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (onWillPop != null) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: _mainBody(),
      );
    } else
      return _mainBody();
  }

  Widget _mainBody() {
    return Stack(
      children: <Widget>[
        body(),
        overlay(),
        StreamBuilder<bool>(
          stream: bloc.loadingStream.distinct(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return AbsorbPointer(
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                          child: showProgressIndicator
                              ? CircularProgressIndicator()
                              : Container())));
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  void showSnackbar(String message) {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }
  }

  bool get primary => true;

  Bloc provideBloc();

  Widget body();

  PreferredSizeWidget? appBar() => null;

  Widget? drawer() => null;

  Widget? bottomNavigationBar() => null;

  Widget? floatingActionButton() => null;

  Widget overlay() => const SizedBox.shrink();

  double get drawerEdgeDragWidth => 20.0;

  bool get showProgressIndicator => true;

  final WillPopCallback? onWillPop = null;

  @override
  bool get wantKeepAlive => false;

  Color? backgroundColor() => null;
}

abstract class BaseStateWithFlushBar<T extends BaseScreen,
    Bloc extends BaseBloc> extends BaseState<T, Bloc> {
  final Duration _animDuration = Duration(milliseconds: 500);
  PublishSubject<bool> _flush = PublishSubject<bool>();
  String? _message;

  @override
  Widget overlay() {
    return StreamBuilder<bool>(
        initialData: false,
        stream: _flush,
        builder: (context, snapshot) {
          return Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: _animDuration,
                child: (snapshot.hasData && snapshot.data!)
                    ? FlushWidget(
                        message: _message ?? '',
                        onTap: () {
                          _flush.add(false);
                        },
                      )
                    : const SizedBox.shrink(),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: animation,
                      curve: Curves.ease,
                    ),
                    axisAlignment: -1.0,
                    child: child,
                  );
                },
              ),
            ),
          );
        });
  }

  void showFlush({String? message, VoidCallback? onTap}) {
    _message = message;
    _flush.add(true);
    Future<void>.delayed(Duration(seconds: 5)).then((value) {
      if (mounted) {
        _flush.add(false);
      }
    });
  }

  @override
  void dispose() {
    _flush.close();
    super.dispose();
  }
}

class FlushWidget extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  FlushWidget({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        constraints: BoxConstraints(minHeight: 48.0),
        decoration: BoxDecoration(
          color: AppColors.textColor,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.check_circle,
              size: 28.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                message,

              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
