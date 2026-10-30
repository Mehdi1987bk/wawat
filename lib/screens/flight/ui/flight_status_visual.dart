import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/models/flight_enums.dart';
import '../flight_text.dart';
import 'flight_tokens.dart';

/// Как показывать статус рейса: иконка, цвет, запасная подпись.
///
/// Подпись на экране берётся из `status_label` — он уже переведён сервером.
/// [label] здесь нужна только там, где своего ответа нет: словарь статусов и
/// редкий случай пустого `status_label`.
class FlightStatusVisual {
  final IconData icon;
  final FTone tone;
  final String label;
  final String hint;

  const FlightStatusVisual({
    required this.icon,
    required this.tone,
    required this.label,
    required this.hint,
  });
}

/// Порядок — как на экране словаря статусов в прототипе (он отличается от
/// порядка перечисления в гайде).
const flightStatusOrder = <String>[
  FlightStatus.expected,
  FlightStatus.checkIn,
  FlightStatus.boarding,
  FlightStatus.gateClosed,
  FlightStatus.departed,
  FlightStatus.enRoute,
  FlightStatus.approaching,
  FlightStatus.arrived,
  FlightStatus.delayed,
  FlightStatus.diverted,
  FlightStatus.canceled,
  FlightStatus.canceledUncertain,
  FlightStatus.unknown,
];

FlightStatusVisual fStatusVisual(String? status) {
  switch (status) {
    case FlightStatus.expected:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.calendarDot,
        tone: FTone.mute,
        label: ft('status_expected', 'Gözlənilir'),
        hint: ft('status_expected_hint', 'Cədvəldə var, hələ hərəkət yoxdur'),
      );
    case FlightStatus.checkIn:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.identificationCard,
        tone: FTone.info,
        label: ft('status_check_in', 'Qeydiyyat'),
        hint: ft('status_check_in_hint', 'Check-in masaları işləyir'),
      );
    case FlightStatus.boarding:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.doorOpen,
        tone: FTone.warn,
        label: ft('status_boarding', 'Minik'),
        hint: ft('status_boarding_hint', 'Sərnişinlər təyyarəyə minir'),
      );
    case FlightStatus.gateClosed:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.lockSimple,
        tone: FTone.warn,
        label: ft('status_gate_closed', 'Qapı bağlandı'),
        hint: ft('status_gate_closed_hint', 'Minik bitdi'),
      );
    case FlightStatus.departed:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.airplaneTakeoff,
        tone: FTone.info,
        label: ft('status_departed', 'Uçdu'),
        hint: ft('status_departed_hint', 'Təkərlər yerdən ayrıldı'),
      );
    case FlightStatus.enRoute:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.airplaneTilt,
        tone: FTone.ok,
        label: ft('status_en_route', 'Havada'),
        hint: ft(
          'status_en_route_hint',
          'Uçuş havadadır — vaxt və gediş izlənir',
        ),
      );
    case FlightStatus.approaching:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.airplaneLanding,
        tone: FTone.ok,
        label: ft('status_approaching', 'Yaxınlaşır'),
        hint: ft('status_approaching_hint', 'Enmə mərhələsindədir'),
      );
    case FlightStatus.arrived:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.checkCircle,
        tone: FTone.ok,
        label: ft('status_arrived', 'Endi'),
        hint: ft('status_arrived_hint', 'Yerə endi və dayandı'),
      );
    case FlightStatus.delayed:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.clockCountdown,
        tone: FTone.warn,
        label: ft('status_delayed', 'Gecikir'),
        hint: ft('status_delayed_hint', 'Yeni saat elan olunub'),
      );
    case FlightStatus.diverted:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.arrowBendDoubleUpRight,
        tone: FTone.bad,
        label: ft('status_diverted', 'İstiqamət dəyişdi'),
        hint: ft('status_diverted_hint', 'Başqa limana endi'),
      );
    case FlightStatus.canceled:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.xCircle,
        tone: FTone.bad,
        label: ft('status_canceled', 'Ləğv edildi'),
        hint: ft('status_canceled_hint', 'İcra olunmayacaq'),
      );
    case FlightStatus.canceledUncertain:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.question,
        tone: FTone.bad,
        label: ft('status_canceled_uncertain', 'Ləğv ehtimalı'),
        hint: ft('status_canceled_uncertain_hint', 'Təsdiq gözlənilir'),
      );
    default:
      return FlightStatusVisual(
        icon: PhosphorIconsFill.dotsThreeCircle,
        tone: FTone.mute,
        label: ft('status_unknown', 'Bilinmir'),
        hint: ft('status_unknown_hint', 'Mənbədə məlumat yoxdur'),
      );
  }
}

/// Иконка и тон уведомления по рейсу — девять типов из §8.
///
/// Подпись не нужна: заголовок и текст приходят от сервера уже переведённые.
/// Здесь только то, чего в ответе нет — чем событие отличается на глаз.
({IconData icon, FTone tone}) fFlightNotifVisual(String? type) =>
    switch (type) {
      FlightNotificationType.statusChanged => (
          icon: PhosphorIconsFill.arrowsClockwise,
          tone: FTone.info,
        ),
      FlightNotificationType.scheduleChanged => (
          icon: PhosphorIconsFill.clockCountdown,
          tone: FTone.warn,
        ),
      FlightNotificationType.gateChanged => (
          icon: PhosphorIconsFill.doorOpen,
          tone: FTone.info,
        ),
      FlightNotificationType.terminalChanged => (
          icon: PhosphorIconsFill.buildings,
          tone: FTone.info,
        ),
      FlightNotificationType.baggageBelt => (
          icon: PhosphorIconsFill.suitcaseRolling,
          tone: FTone.info,
        ),
      FlightNotificationType.departed => (
          icon: PhosphorIconsFill.airplaneTakeoff,
          tone: FTone.ok,
        ),
      FlightNotificationType.arrived => (
          icon: PhosphorIconsFill.airplaneLanding,
          tone: FTone.ok,
        ),
      FlightNotificationType.canceled => (
          icon: PhosphorIconsFill.xCircle,
          tone: FTone.bad,
        ),
      FlightNotificationType.diverted => (
          icon: PhosphorIconsFill.arrowBendDoubleUpRight,
          tone: FTone.bad,
        ),
      _ => (icon: PhosphorIconsFill.bellRinging, tone: FTone.mute),
    };
