import 'package:flutter/material.dart';

/// Единая палитра ТЁМНОГО режима Wawat (navy) — ЕДИНСТВЕННЫЙ источник правды.
///
/// Использовать только в тёмной ветке, светлую часть оставляя как есть:
/// ```dart
/// final isDark = Theme.of(context).brightness == Brightness.dark;
/// color: isDark ? WawatDark.textPrimary : _ink900, // light не меняется
/// ```
/// Для типовых ролей есть готовые хелперы `c*(isDark)` в `theme_colors.dart`.
///
/// ВАЖНО: [brand] (#017bfe) — это цвет ЗАЛИВОК (кнопки, «плюс», активные заливки),
/// его НЕ меняем. Бренд как ТЕКСТ/ИКОНКА на тёмном — [brandText] (#7FB6FF).
class WawatDark {
  WawatDark._();

  // ── Поверхности ────────────────────────────────────────────────
  static const Color bg =
      Color(0xFF0A0F1A); // фон приложения / scaffold / скролл
  static const Color surface =
      Color(0xFF141D2E); // карточки, листы, строки, кнопки-списки
  static const Color surfaceAlt =
      Color(0xFF1C2740); // приподнятая: поля ввода, чипы
  static const Color elevated =
      Color(0xFF1C2740); // алиас приподнятой поверхности
  static const Color bar =
      Color(0xFF0F1728); // залипающие бары: статус/app/таб-бар

  // ── Линии ──────────────────────────────────────────────────────
  static const Color border =
      Color(0x14FFFFFF); // ~.08 — обводки/границы карточек
  static const Color divider = Color(0x0FFFFFFF); // ~.06 — тонкие разделители

  // ── Текст ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEAF0FA); // основной
  static const Color textSecondary = Color(0xFF9FB0C7); // вторичный
  static const Color textMuted =
      Color(0xFF6B7B93); // приглушённый (подписи/значения)
  static const Color textFaint = Color(0xFF55637A); // тусклый
  static const Color placeholder = Color(0xFF6B7B93); // плейсхолдер ввода

  // ── Иконки ─────────────────────────────────────────────────────
  static const Color icon = Color(0xFF9FB0C7); // нейтральная иконка
  static const Color iconMuted = Color(0xFF55637A); // тусклые иконки / шевроны

  // ── Бренд ──────────────────────────────────────────────────────
  static const Color brand = Color(0xFF017BFE); // ЗАЛИВКА — НЕ менять
  static const Color textOnBrand =
      Color(0xFFFFFFFF); // текст/иконка на бренд-заливке
  static const Color brandText = Color(0xFF7FB6FF); // бренд как текст/иконка
  static const Color brandTextStrong =
      Color(0xFF4F9DFF); // усиленный бренд-текст
  static const Color brandChip =
      Color(0x24017BFE); // rgba(1,123,254,.14) — плашка
  static const Color brandBadge =
      Color(0x33017BFE); // rgba(1,123,254,.20) — бейдж/выбранное
  static const Color brandSoft = Color(0x24017BFE); // алиас плашки .14

  // ── Жёлтый акцент ──────────────────────────────────────────────
  static const Color accent = Color(0xFFF2FC2A); // НЕ менять
  static const Color onAccent = Color(0xFF0B1220); // текст на жёлтом

  // ── Статусы ────────────────────────────────────────────────────
  static const Color success = Color(0xFF4FD6A0); // текст успеха
  static const Color successBg = Color(0x2910B981); // rgba(16,185,129,.16)
  static const Color warning = Color(0xFFF4C64D); // текст предупреждения
  static const Color warningBg = Color(0x29F5B40A); // rgba(245,180,10,.16)
  static const Color danger = Color(0xFFEF4444); // сплошная опасная кнопка
  static const Color dangerText = Color(0xFFFF9A9A); // опасный текст
  static const Color dangerSoftBg = Color(0x1FEF4444); // rgba(239,68,68,.12)
  static const Color dangerSoftBorder =
      Color(0x4DEF4444); // rgba(239,68,68,.30)

  // ── Рейтинг / live ─────────────────────────────────────────────
  static const Color star = Color(0xFFFBBF24); // звезда — НЕ менять
  static const Color pingBase = Color(0xFF10B981); // «онлайн» база — НЕ менять
  static const Color pingWave = Color(0xFF34D399); // волна пульса — НЕ менять

  // ── VIP / золото ───────────────────────────────────────────────
  static const Color gold = Color(0xFFEAB308); // золотая заливка (VIP-бейдж)
  static const Color onGold = Color(0xFF0B1220); // текст на золоте
  static const Color goldSoftBg = Color(0x29EAB308); // rgba(234,179,8,.16)
  static const Color goldSoftText = Color(0xFFF4C64D); // текст на мягком золоте
  static const Color goldRing =
      Color(0x8CEAB308); // rgba(234,179,8,.55) — кольцо VIP-карточки

  // ── Тиры ───────────────────────────────────────────────────────
  static const Color tierBronzeBg = Color(0x33B07842); // rgba(176,120,66,.20)
  static const Color tierBronzeText = Color(0xFFE7B48A);
  static const Color tierSilverBg = Color(0x2994A3B8); // rgba(148,163,184,.16)
  static const Color tierSilverText = Color(0xFFCBD5E1);
  static const Color tierGoldBg = Color(0x2EEAB308); // rgba(234,179,8,.18)
  static const Color tierGoldText = Color(0xFFF4C64D);
  static const Color tierPlatinumBg =
      Color(0x2E818CF8); // rgba(129,140,248,.18)
  static const Color tierPlatinumText = Color(0xFFB7C0FF);

  // ── Скелетон / shimmer ─────────────────────────────────────────
  static const Color skeletonBase = Color(0x0DFFFFFF); // rgba(255,255,255,.05)
  static const Color skeletonHi = Color(0x1AFFFFFF); // rgba(255,255,255,.10)

  // ── Состояния ──────────────────────────────────────────────────
  static const Color focusRing = Color(0xFF4F9DFF); // рамка фокуса поля
  static const Color focusGlow =
      Color(0x404F9DFF); // rgba(79,157,255,.25) — свечение
  static const Color disabledBg = Color(0x14FFFFFF); // rgba(255,255,255,.08)
  static const Color disabledFg = Color(0xFF55637A);
  static const Color ripple = Color(0x0FFFFFFF); // rgba(255,255,255,.06)

  // ── Модалки ────────────────────────────────────────────────────
  static const Color scrim =
      Color(0x9E000000); // rgba(0,0,0,.62) — затемнение под модалкой
  static const Color grab =
      Color(0x33FFFFFF); // rgba(255,255,255,.20) — «хваталка» листа

  // ── Тени ───────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x80000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
        color: Color(0xBF000000),
        blurRadius: 30,
        spreadRadius: -16,
        offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> brandButtonShadow = [
    BoxShadow(
        color: Color(0x99017BFE),
        blurRadius: 22,
        spreadRadius: -8,
        offset: Offset(0, 10)),
  ];
}
