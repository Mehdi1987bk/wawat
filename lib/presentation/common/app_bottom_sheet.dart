import 'package:flutter/material.dart';

/// Keyboard-safe, app-wide replacement for [showModalBottomSheet].
///
/// Every sheet is scroll-controlled and its content is padded by the current
/// keyboard inset, so focusing a field inside the sheet lifts the whole sheet
/// above the keyboard instead of letting the keyboard cover it. When there is
/// no keyboard the inset is 0, so non-input sheets look exactly as before.
///
/// All parameters forward to [showModalBottomSheet]; do NOT add your own
/// `MediaQuery.viewInsets` bottom padding inside the builder — this helper
/// already provides it (adding it again would double-pad the sheet).
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  ShapeBorder? shape,
  Clip? clipBehavior,
  double? elevation,
  BoxConstraints? constraints,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = false,
  bool useRootNavigator = false,
  bool? showDragHandle,
  RouteSettings? routeSettings,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    shape: shape,
    clipBehavior: clipBehavior,
    elevation: elevation,
    constraints: constraints,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    showDragHandle: showDragHandle,
    routeSettings: routeSettings,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: builder(sheetContext),
    ),
  );
}
