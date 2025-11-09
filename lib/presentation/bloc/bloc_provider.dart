import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'base_bloc.dart';

class BlocProvider<T extends BaseBloc> extends InheritedWidget {
  final T bloc;

  const BlocProvider({Key? key, required this.bloc, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(BlocProvider oldWidget) => bloc != oldWidget.bloc;

  static Type _typeOf<T>() => T;

  static T of<T extends BaseBloc>(BuildContext context) {
    final type = _typeOf<BlocProvider<T>>();

    final screen = (context.dependOnInheritedWidgetOfExactType(aspect: type)
    as BlocProvider<T>?) ??
        context
            .getElementForInheritedWidgetOfExactType<BlocProvider<T>>()
            ?.widget as BlocProvider<T>?;
    if (screen == null) throw 'Context does not contain viewModel $T';
    return screen.bloc;
  }
}
