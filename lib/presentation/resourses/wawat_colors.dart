import 'dart:ui';
import 'package:flutter/material.dart';

/// Цветовая схема для приложения Wawat
class WawatColors {
  // Основные цвета
  static const Color primary = Color(0xFF5B4FFF); // Фиолетовый
  static const Color secondary = Color(0xFF764BA2); // Темный фиолетовый

  // Фоновые цвета
  static const Color backgroundLight = Color(0xFFF0F4FF); // Светло-синий фон
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Белый

  // Текстовые цвета
  static const Color textPrimary = Color(0xFF1A1A1A); // Черный
  static const Color textSecondary = Color(0xFF999999); // Серый
  static const Color textDisabled = Color(0xFF999999); // Отключенный текст

  // Акцентные цвета
  static const Color success = Color(0xFF4CAF50); // Зеленый (для "Проверен")
  static const Color warning = Color(0xFFFFA726); // Оранжевый
  static const Color error = Color(0xFFE57373); // Красный
  static const Color info = Color(0xFF64B5F6); // Синий

  // Цвета для чипов и тегов
  static const Color chipPurple = Color(0xFF5B4FFF);
  static const Color chipGreen = Color(0xFF4CAF50);
  static const Color chipYellow = Color(0xFFFFC107);
  static const Color chipGray = Color(0xFF9E9E9E);

  // Цвета для полей ввода
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusedBorder = Color(0xFF5B4FFF);

  // Градиенты
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

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000); // 10% opacity
  static const Color shadowMedium = Color(0x26000000); // 15% opacity
  static const Color shadowHeavy = Color(0x33000000); // 20% opacity
}
