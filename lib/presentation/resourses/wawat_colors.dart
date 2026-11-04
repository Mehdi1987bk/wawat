import 'dart:ui';
import 'package:flutter/material.dart';

class WawatColors {
  static const Color primary = Color(0xFF5B4FFF);
  static const Color secondary = Color(0xFF764BA2);

  static const Color backgroundLight = Color(0xFFF0F4FF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);

  static const Color chipPurple = Color(0xFF5B4FFF);
  static const Color chipGreen = Color(0xFF4CAF50);
  static const Color chipYellow = Color(0xFFFFC107);
  static const Color chipGray = Color(0xFF9E9E9E);

  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusedBorder = Color(0xFF5B4FFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B4FFF), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF5B4FFF), Color(0xFF764BA2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x26000000);
  static const Color shadowHeavy = Color(0x33000000);
}
