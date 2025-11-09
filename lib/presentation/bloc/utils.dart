
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

void hideKeyboardOnScroll(
    BuildContext context, ScrollController scrollController) {
  if (scrollController.position.userScrollDirection ==
      ScrollDirection.forward ||
      scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
    FocusScope.of(context).unfocus();
  }
}