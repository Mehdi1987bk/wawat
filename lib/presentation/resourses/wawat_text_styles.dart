import 'package:flutter/material.dart';
import 'wawat_colors.dart';

class WawatTextStyles {
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: WawatColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: WawatColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: WawatColors.linkColor,
    decoration: TextDecoration.underline,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: WawatColors.primary,
  );
}
