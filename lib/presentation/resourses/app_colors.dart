import 'dart:ui';

class AppColors {
  // Light Theme Colors (Existing)
  static const Color appColor = Color(0xFF2F315E);
  static const Color textColor = Color(0xff002255);
  static const Color tabIcon = Color(0xff969393);
  static const Color bgColor = Color(0xFFEFF2FB);
  static const Color appBarbgColor = Color(0xfffafafa);
  static const Color darkBlue = Color(0xFF002255);
  static const Color darkBlue90 = Color(0xFF001d4a);
  static const Color leqasy = Color(0xFF5599FF);
  static const Color textInput = Color(0xFF242424);

  // Dark Theme Colors
  static const Color darkAppColor = Color(0xFF1A1B3E);
  static const Color darkTextColor = Color(0xFFE8E8E8);
  static const Color darkTabIcon = Color(0xFFB0B0B0);
  static const Color darkBgColor = Color(0xFF0F1014);
  static const Color darkAppBarbgColor = Color(0xFF1C1C1E);
  static const Color darkCardBg = Color(0xFF1E1F28);
  static const Color darkLeqasy = Color(0xFF5599FF);
  static const Color darkTextInput = Color(0xFFE8E8E8);

  // Dynamic Colors based on theme
  static Color getAppColor(bool isDark) => isDark ? darkAppColor : appColor;
  static Color getTextColor(bool isDark) => isDark ? darkTextColor : textColor;
  static Color getTabIcon(bool isDark) => isDark ? darkTabIcon : tabIcon;
  static Color getBgColor(bool isDark) => isDark ? darkBgColor : bgColor;
  static Color getAppBarBgColor(bool isDark) => isDark ? darkAppBarbgColor : appBarbgColor;
  static Color getCardBg(bool isDark) => isDark ? darkCardBg : Color(0xFFFFFFFF);
  static Color getLeqasy(bool isDark) => isDark ? darkLeqasy : leqasy;
  static Color getTextInput(bool isDark) => isDark ? darkTextInput : textInput;
}
