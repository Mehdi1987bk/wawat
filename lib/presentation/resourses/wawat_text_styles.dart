import 'package:flutter/material.dart';
import 'wawat_colors.dart';

/// Текстовые стили для приложения Wawat
class WawatTextStyles {
  // Заголовки
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: WawatColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: WawatColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: WawatColors.textPrimary,
    height: 1.4,
  );

  // Основной текст
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: WawatColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: WawatColors.textPrimary,
    height: 1.5,
  );

  // Вторичный текст
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: WawatColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: WawatColors.textSecondary,
    height: 1.4,
  );

  // Лейблы для полей
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: WawatColors.textPrimary,
    height: 1.3,
  );

  // Placeholder текст
  static const TextStyle placeholder = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: WawatColors.textSecondary,
    height: 1.5,
  );

  // Кнопки
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Ссылки
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: WawatColors.primary,
    decoration: TextDecoration.underline,
    height: 1.5,
  );

  // Чипы
  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.2,
  );
}
