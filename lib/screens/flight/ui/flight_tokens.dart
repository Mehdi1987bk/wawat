import 'package:flutter/material.dart';

import '../../../presentation/resourses/theme_colors.dart';
import '../../../presentation/resourses/wawat_dark.dart';

/// Токены раздела рейсов.
///
/// Поверхности, текст и линии берутся из общих хелперов приложения
/// (`cScreen`, `cCard`, `cText` и далее) — модуль должен выглядеть частью
/// приложения, а не отдельной программой. Здесь живёт только то, чего в
/// приложении ещё не было: светофорные цвета статусов, синее небо карточки
/// рейса, цвета карты и тени прототипа.
///
/// Насыщенность шрифта нигде не выше `w700`: в прототипе заголовки набраны
/// 800-м, в приложении такого веса нет.
class FT {
  FT._();

  // Светофор статусов — пять тонов прототипа.
  static Color ok(bool d) => d ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
  static Color okBg(bool d) =>
      d ? const Color(0x2E10B981) : const Color(0x1F10B981);
  static Color warn(bool d) =>
      d ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
  static Color warnBg(bool d) =>
      d ? const Color(0x2EFBBF24) : const Color(0x24F59E0B);
  static Color bad(bool d) => d ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
  static Color badBg(bool d) =>
      d ? const Color(0x2EEF4444) : const Color(0x1FEF4444);
  static Color info(bool d) =>
      d ? const Color(0xFFBFDBFE) : const Color(0xFF0263CE);
  static Color infoBg(bool d) =>
      d ? const Color(0x2E4F9DFF) : const Color(0x1A017BFE);

  /// Фон «чипа»: мягкая подложка под иконки и приглушённые бейджи.
  static Color chip(bool d) => d
      ? const Color(0x0FFFFFFF)
      : const Color(0xFF0F172A).withValues(alpha: .04);
  static Color chipBorder(bool d) => d
      ? const Color(0x17FFFFFF)
      : const Color(0xFF0F172A).withValues(alpha: .07);

  /// Фирменный синий как заливка кнопки — один и тот же в обеих темах.
  static const Color brand = Color(0xFF017BFE);

  /// Текст и иконки фирменного цвета на мягкой подложке.
  static Color brand600(bool d) =>
      d ? WawatDark.brandTextStrong : const Color(0xFF0263CE);
  static Color brand50(bool d) => cBrandSoft(d);
  static Color brand100(bool d) =>
      d ? const Color(0x3D017BFE) : const Color(0xFFCFE3FD);

  /// Небо карточки рейса. В тёмной теме синий глубже, иначе герой слепит.
  static Color hero(bool d) => d ? const Color(0xFF0B4BAF) : brand;

  /// Кольца и лучи радара на небе.
  static Color heroRing(bool d) => d
      ? const Color(0xFF8FC0FF).withValues(alpha: .16)
      : Colors.white.withValues(alpha: .14);
  static Color heroSweep(bool d) => d
      ? const Color(0xFF4F9DFF).withValues(alpha: .40)
      : Colors.white.withValues(alpha: .26);

  /// Жёлтый прогресса — акцент приложения.
  static const Color accent = WawatDark.accent;

  /// Текст на небе.
  static Color onHero(double opacity) =>
      Colors.white.withValues(alpha: opacity);

  /// Зачёркнутое прежнее время.
  static const Color struck = Color(0xFFFCA5A5);

  /// Море под картой — пока плитки не загрузились.
  static Color mapSea(bool d) =>
      d ? const Color(0xFF0A1120) : const Color(0xFFDBE6F3);

  /// Плитки карты. Ключа не требуют — те же, что в прототипе.
  static String tileUrl(bool d) => d
      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}'
      : 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}';

  /// Подложка выбранного слоя. «Простая» идёт по теме телефона, «ночная»
  /// всегда тёмная, «спутник» — снимки. Все три без ключа.
  static String tileUrlFor(FMapTiles tiles, bool d) => switch (tiles) {
        FMapTiles.plain => tileUrl(d),
        FMapTiles.night => tileUrl(true),
        FMapTiles.satellite =>
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      };

  static const String tileAttribution = '© Esri · OpenStreetMap';

  static String tileAttributionFor(FMapTiles tiles) =>
      tiles == FMapTiles.satellite
          ? '© Esri · Maxar · Earthstar'
          : tileAttribution;

  /// Море под спутниковой подложкой тёмное — иначе края снимка светятся.
  static Color mapSeaFor(FMapTiles tiles, bool d) => switch (tiles) {
        FMapTiles.plain => mapSea(d),
        FMapTiles.night => mapSea(true),
        FMapTiles.satellite => const Color(0xFF0B1A2B),
      };

  /// Пройденная часть маршрута и остаток.
  static const Color routeDone = brand;
  static Color routeRest(bool d) => const Color(0xFF4F9DFF);

  /// Живая метка на карте и в бейджах.
  static const Color livePing = Color(0xFF34D399);
  static const Color liveCore = Color(0xFF10B981);

  /// Бейдж статуса на небе. Светофорные цвета приложения на синем читаются
  /// плохо, поэтому у неба свои — светлее, как в прототипе.
  static Color heroBadgeBg(FTone tone) => switch (tone) {
        FTone.ok => const Color(0x3D10B981),
        FTone.warn => const Color(0x38F59E0B),
        FTone.bad => const Color(0x3DEF4444),
        FTone.info => const Color(0x2EFFFFFF),
        FTone.mute => const Color(0x2EFFFFFF),
      };

  static Color heroBadgeFg(FTone tone) => switch (tone) {
        FTone.ok => const Color(0xFFA7F3D0),
        FTone.warn => const Color(0xFFFDE68A),
        FTone.bad => const Color(0xFFFECACA),
        FTone.info => Colors.white,
        FTone.mute => Colors.white,
      };

  static List<BoxShadow> cardShadow(bool d) => d
      ? WawatDark.cardShadow
      : const [
          BoxShadow(
              color: Color(0x0A0F172A), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(
            color: Color(0x290F172A),
            blurRadius: 24,
            spreadRadius: -12,
            offset: Offset(0, 8),
          ),
        ];

  static List<BoxShadow> brandShadow(bool d) => d
      ? WawatDark.brandButtonShadow
      : const [
          BoxShadow(
            color: Color(0x8C017BFE),
            blurRadius: 18,
            spreadRadius: -8,
            offset: Offset(0, 8),
          ),
        ];

  // Радиусы прототипа.
  static const BorderRadius rCard = BorderRadius.all(Radius.circular(24));
  static const BorderRadius rTile = BorderRadius.all(Radius.circular(20));
  static const BorderRadius rField = BorderRadius.all(Radius.circular(16));
  static const BorderRadius rIcon = BorderRadius.all(Radius.circular(14));
  static const BorderRadius rSoft = BorderRadius.all(Radius.circular(12));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(999));
}

/// Тон бейджа и строк статуса — пять значений прототипа.
enum FTone { ok, warn, bad, info, mute }

extension FToneColors on FTone {
  Color fg(bool d) {
    switch (this) {
      case FTone.ok:
        return FT.ok(d);
      case FTone.warn:
        return FT.warn(d);
      case FTone.bad:
        return FT.bad(d);
      case FTone.info:
        return FT.info(d);
      case FTone.mute:
        return cMuted(d);
    }
  }

  Color bg(bool d) {
    switch (this) {
      case FTone.ok:
        return FT.okBg(d);
      case FTone.warn:
        return FT.warnBg(d);
      case FTone.bad:
        return FT.badBg(d);
      case FTone.info:
        return FT.infoBg(d);
      case FTone.mute:
        return FT.chip(d);
    }
  }
}

/// Подложка карты — выбор человека на экране «Xəritə qatları».
///
/// Живёт здесь, а не в виджете карты: слой выбирается на одном экране,
/// хранится в настройках и применяется на другом.
enum FMapTiles { plain, satellite, night }
