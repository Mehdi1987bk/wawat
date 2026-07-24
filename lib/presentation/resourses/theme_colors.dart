import 'package:flutter/material.dart';

import 'wawat_dark.dart';

/// Общие тема-зависимые хелперы цвета — ОДНА палитра на всё приложение.
///
/// Каждый хелпер возвращает тёмный токен из [WawatDark] в dark и ПРЕЖНИЙ светлый
/// цвет в light (светлый режим не меняется). Применение:
/// ```dart
/// final isDark = Theme.of(context).brightness == Brightness.dark;
/// Text('...', style: TextStyle(color: cText(isDark)));
/// Container(color: cCard(isDark), ...);
/// ```
/// Бренд как ЗАЛИВКА — [cBrandFill] (#017bfe, не меняется). Бренд как ТЕКСТ/ИКОНКА —
/// [cBrandText] (#7FB6FF в dark).

// ── светлые эталонные значения (как в профиль-эталоне) ──
const Color _lScreen = Color(0xFFF4F6F9);
const Color _lFill = Color(0xFFF1F5F9);
const Color _lInk900 = Color(0xFF0F172A);
const Color _lInk600 = Color(0xFF475569);
const Color _lInk500 = Color(0xFF64748B);
const Color _lInk400 = Color(0xFF94A3B8);
const Color _lInk300 = Color(0xFFCBD5E1);
const Color _lBrand = Color(0xFF017BFE);
const Color _lBrand50 = Color(0xFFEAF3FE);

// ── Поверхности ──
Color cScreen(bool d) => d ? WawatDark.bg : _lScreen; // фон экрана/скролла
Color cCard(bool d) =>
    d ? WawatDark.surface : Colors.white; // карточки/листы/строки
Color cBar(bool d) => d ? WawatDark.bar : Colors.white; // статус/app/таб-бар
Color cFill(bool d) => d ? WawatDark.surfaceAlt : _lFill; // поля ввода / чипы

// ── Текст ──
Color cText(bool d) => d ? WawatDark.textPrimary : _lInk900; // основной
Color cText2(bool d) => d ? WawatDark.textSecondary : _lInk500; // вторичный
Color cText3(bool d) =>
    d ? WawatDark.textSecondary : _lInk600; // вторичный (тёмный ink)
Color cMuted(bool d) => d ? WawatDark.textMuted : _lInk400; // приглушённый
Color cFaint(bool d) =>
    d ? WawatDark.iconMuted : _lInk300; // тусклые иконки/шевроны

// ── Линии ──
Color cLine(bool d) => d
    ? WawatDark.divider
    : _lInk900.withValues(alpha: .06); // тонкий разделитель
Color cBorder(bool d) =>
    d ? WawatDark.border : _lInk900.withValues(alpha: .08); // обводка

// ── Бренд ──
const Color cBrandFill = _lBrand; // ЗАЛИВКА — не меняется
Color cBrandText(bool d) =>
    d ? WawatDark.brandText : _lBrand; // текст/иконка бренда
Color cBrandSoft(bool d) =>
    d ? WawatDark.brandChip : _lBrand50; // плашка под бренд-иконку
Color cBrandBadge(bool d) =>
    d ? WawatDark.brandBadge : _lBrand50; // бейдж/выбранное состояние

// ── Границы карточек / тени ──
BoxBorder? cCardBorder(bool d) =>
    d ? Border.all(color: WawatDark.border) : null;

/// Тень карточки: глубокая чёрная в dark, переданная [light] — в light
/// (light-ветку не меняем).
List<BoxShadow>? cCardShadow(bool d, List<BoxShadow>? light) =>
    d ? WawatDark.cardShadow : light;
