import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/models/flight_enums.dart';
import '../flight_text.dart';
import 'flight_tokens.dart';

/// Как показывать событие подписки: иконка, название, пояснение.
///
/// Девять событий из §8. Порог «5 дəqiqə» в пояснении к времени — серверный:
/// приложение его не передаёт, такого поля нет.
({IconData icon, String title, String hint}) fWatchEventVisual(String event) =>
    switch (event) {
      WatchEvent.statusChanged => (
          icon: PhosphorIconsFill.arrowsClockwise,
          title: ft('event_status', 'Status dəyişdi'),
          hint: ft('event_status_hint', 'hər status keçidində'),
        ),
      WatchEvent.scheduleChanged => (
          icon: PhosphorIconsFill.clockCountdown,
          title: ft('event_schedule', 'Vaxt dəyişdi'),
          hint: ft(
            'event_schedule_hint',
            'gediş və ya gəliş vaxtı 5 dəqiqədən çox dəyişəndə',
          ),
        ),
      WatchEvent.gateChanged => (
          icon: PhosphorIconsFill.doorOpen,
          title: ft('event_gate', 'Qapı dəyişdi'),
          hint: ft('event_gate_hint', 'çıxış qapısı yeniləndikdə'),
        ),
      WatchEvent.terminalChanged => (
          icon: PhosphorIconsFill.buildings,
          title: ft('event_terminal', 'Terminal dəyişdi'),
          hint: ft('event_terminal_hint', 'terminal yeniləndikdə'),
        ),
      WatchEvent.baggageBelt => (
          icon: PhosphorIconsFill.suitcaseRolling,
          title: ft('event_belt', 'Baqaj lenti açıqlandı'),
          hint: ft('event_belt_hint', 'lent nömrəsi məlum olanda'),
        ),
      WatchEvent.departed => (
          icon: PhosphorIconsFill.airplaneTakeoff,
          title: ft('event_departed', 'Uçdu'),
          hint: ft('event_departed_hint', 'təyyarə havaya qalxanda'),
        ),
      WatchEvent.arrived => (
          icon: PhosphorIconsFill.airplaneLanding,
          title: ft('event_arrived', 'Endi'),
          hint: ft('event_arrived_hint', 'təyyarə yerə enəndə'),
        ),
      WatchEvent.canceled => (
          icon: PhosphorIconsFill.xCircle,
          title: ft('event_canceled', 'Ləğv edildi'),
          hint: ft('event_canceled_hint', 'uçuş ləğv olunanda'),
        ),
      WatchEvent.diverted => (
          icon: PhosphorIconsFill.arrowBendDoubleUpRight,
          title: ft('event_diverted', 'İstiqamət dəyişdi'),
          hint: ft('event_diverted_hint', 'başqa limana enəndə'),
        ),
      _ => (
          icon: PhosphorIconsFill.bellRinging,
          title: event,
          hint: '',
        ),
    };

/// Как показывать строку в ленте уведомлений.
///
/// Тип уведомления (§11) — это имя события с приставкой `flight_`, поэтому
/// иконка берётся из той же карты. Заголовок и текст приходят с сервера —
/// своих слов тут не выдумываем.
({IconData icon, FTone tone}) fFlightNotificationVisual(String? type) {
  const prefix = 'flight_';
  final raw = type ?? '';
  final event = raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  final tone = switch (event) {
    WatchEvent.canceled || WatchEvent.diverted => FTone.bad,
    WatchEvent.scheduleChanged ||
    WatchEvent.gateChanged ||
    WatchEvent.terminalChanged =>
      FTone.warn,
    WatchEvent.departed ||
    WatchEvent.arrived ||
    WatchEvent.baggageBelt =>
      FTone.ok,
    _ => FTone.info,
  };
  return (icon: fWatchEventVisual(event).icon, tone: tone);
}
