import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeAwareScreen extends StatelessWidget {
  final bool isDark;
  final Widget child;
  final Color? lightBackgroundColor;
  final Color? darkBackgroundColor;

  const ThemeAwareScreen({
    Key? key,
    required this.isDark,
    required this.child,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
         statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark
            ? (darkBackgroundColor ?? const Color(0xFF121212))
            : (lightBackgroundColor ?? Colors.white),
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: isDark
            ? (darkBackgroundColor ?? const Color(0xFF121212))
            : (lightBackgroundColor ?? Colors.white),
        child: child,
      ),
    );
  }
}
