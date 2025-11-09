import 'package:flutter/material.dart';
import 'base_screen.dart';
import 'paginable_bloc.dart';
import 'utils.dart';

mixin ScrollControllerMixin<Page extends BaseScreen, Bloc extends PaginableBloc>
    on BaseState<Page, Bloc> {
  final ScrollController scrollController = ScrollController();



  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      hideKeyboardOnScroll(context, scrollController);
      if (scrollController.position.extentAfter <=
          MediaQuery.of(context).size.height) {
        bloc.load();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
