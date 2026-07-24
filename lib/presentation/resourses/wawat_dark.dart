import 'package:flutter/material.dart';

/// Единая палитра ТЁМНОГО режима Wawat (графит).
///
/// Использовать только в тёмной ветке тернарника, светлую часть оставляя как есть:
/// ```dart
/// final isDark = Theme.of(context).brightness == Brightness.dark;
/// color: isDark ? WawatDark.textPrimary : _ink900,   // светлый режим не меняется
/// ```
/// Значения совпадают с уже готовыми тёмными экранами (#121212 / #1E1E1E / white10),
/// поэтому весь тёмный режим выглядит одинаково аккуратно.
class WawatDark {
  WawatDark._();

  // Поверхности
  static const Color bg = Color(0xFF121212); // фон страницы / scaffold
  static const Color surface = Color(0xFF1E1E1E); // карточки, аппбар, боттом-шиты
  static const Color surfaceAlt = Color(0xFF242424); // вложенные заливки, поля ввода
  static const Color elevated = Color(0xFF2A2A2A); // приподнятые чипы/сегменты

  // Линии
  static const Color border = Color(0x1FFFFFFF); // ~12% белого — обводка карточек
  static const Color divider = Color(0x14FFFFFF); // ~8% белого — разделители

  // Текст
  static const Color textPrimary = Color(0xFFF3F5F7); // заголовки
  static const Color textSecondary = Color(0xFF9CA3AF); // вторичный текст
  static const Color textMuted = Color(0xFF6B7280); // подписи, hint
  static const Color textFaint = Color(0x61FFFFFF); // ~38% белого — disabled

  // Иконки
  static const Color icon = Color(0xFFCBD5E1);
  static const Color iconMuted = Color(0xFF6B7280);

  // Акцент
  static const Color brand = Color(0xFF017BFE); // синий бренд (одинаков в обоих режимах)
  static const Color brandSoft = Color(0xFF14263F); // мягкая подложка под акцент

  // Статусы (читаются в обоих режимах)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}
