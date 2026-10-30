import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/flight_auth.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight_enums.dart';
import '../../data/models/flight_watch.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_event_visual.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../flight/flight_card_screen.dart';

/// `watch/item` — карточка одной подписки.
///
/// Повторный `POST …/watch` перезаписывает подписку целиком: набор событий
/// заменяется, а `mute_hours` без ключа сервер сбрасывает в `null`. Поэтому
/// при сохранении остаток тишины пересылается заново — иначе «не беспокоить»
/// молча пропало бы.
///
/// Привязанного объявления здесь нет намеренно: `listing_id` у подписки —
/// внутреннее целое, а эндпоинты объявлений работают с ULID `public_id`,
/// открыть объявление по этому значению нельзя (§15).
class WatchItemScreen extends StatefulWidget {
  const WatchItemScreen({super.key, required this.watch});

  final FlightWatch watch;

  @override
  State<WatchItemScreen> createState() => _WatchItemScreenState();
}

class _WatchItemScreenState extends State<WatchItemScreen> {
  final _repo = FlightRepository.instance;

  late final Set<String> _events = {
    ...(widget.watch.events.isEmpty
        ? WatchEvent.defaults
        : widget.watch.events),
  };

  bool _saving = false;
  bool _stopping = false;

  @override
  Widget build(BuildContext context) {
    final flight = widget.watch.flight;
    final visual = fStatusVisual(flight?.status);
    final muted = widget.watch.isMuted(DateTime.now());
    return FlightScaffold(
      title: ft('watch_item_title', 'İzləmə kartı'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    flight?.displayNumber ??
                        ft('watch_unknown_flight', 'Uçuş'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (flight != null)
                  FBadge(
                    (flight.statusLabel ?? visual.label).toUpperCase(),
                    background: FT.heroBadgeBg(visual.tone),
                    foreground: FT.heroBadgeFg(visual.tone),
                    fontSize: 9.5,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _heroLine(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: FT.onHero(.82),
              ),
            ),
            if (muted)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FBadge(
                  ft('watch_muted_badge', 'SƏSSİZDİR — {time}-DƏK', {
                    'time': fClock(widget.watch.mutedUntil),
                  }),
                  background: FT.heroBadgeBg(FTone.info),
                  foreground: FT.heroBadgeFg(FTone.info),
                  icon: PhosphorIconsFill.bellSlash,
                  fontSize: 9,
                ),
              ),
          ],
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            if (widget.watch.key != null)
              FCard(
                padding: EdgeInsets.zero,
                child: FListRow(
                  icon: PhosphorIconsFill.airplaneTilt,
                  title: ft('watch_item_open_flight', 'Uçuş kartına keç'),
                  subtitle: ft(
                    'watch_item_open_flight_hint',
                    'canlı vəziyyət və detallar',
                  ),
                  flat: true,
                  onTap: () => FlightNav.push(
                    context,
                    FlightCardScreen(flightKey: widget.watch.key!),
                  ),
                ),
              ),
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FCardTitle(
                    ft('watch_item_events', 'Hansı hadisələr gəlsin'),
                  ),
                  for (var i = 0; i < WatchEvent.all.length; i++)
                    _eventRow(
                      WatchEvent.all[i],
                      last: i == WatchEvent.all.length - 1,
                    ),
                ],
              ),
            ),
            FPrimaryButton(
              label: ft('save', 'Yadda saxla'),
              icon: PhosphorIconsBold.check,
              loading: _saving,
              onTap: _save,
            ),
            FSecondaryButton(
              label: ft('watch_item_stop', 'İzləməni dayandır'),
              icon: PhosphorIconsBold.bellSlash,
              onTap: _stopping ? null : _stop,
            ),
          ],
        ),
      ],
    );
  }

  String _heroLine() {
    final flight = widget.watch.flight;
    if (flight == null) return '—';
    final parts = <String>[
      '${flight.departureCode ?? '—'} → ${flight.arrivalCode ?? '—'}',
      fDateStringLong(flight.flightDate),
    ];
    final from = flight.departureLocal?.clock;
    final to = flight.arrivalLocal?.clock;
    if (from != null && to != null) parts.add('$from → $to');
    return parts.join(' · ');
  }

  /// На карточке подписки у тумблеров пояснений нет — только названия.
  Widget _eventRow(String event, {required bool last}) {
    final visual = fWatchEventVisual(event);
    return FToggleRow(
      icon: visual.icon,
      title: visual.title,
      value: _events.contains(event),
      last: last,
      onChanged: (value) => setState(() {
        if (value) {
          _events.add(event);
        } else {
          _events.remove(event);
        }
      }),
    );
  }

  /// Остаток тишины в часах — его нужно переслать, иначе сервер снимет
  /// «не беспокоить». Ноль не годится: диапазон начинается с `0`, но нулём
  /// тишина как раз и снимается, поэтому меньше часа округляем вверх.
  int? get _muteHours {
    final until = widget.watch.mutedUntil;
    if (until == null) return null;
    final left = until.difference(DateTime.now().toUtc());
    if (left.isNegative) return null;
    final hours = (left.inMinutes / 60).ceil();
    return hours.clamp(1, 168);
  }

  Future<void> _save() async {
    final key = widget.watch.key;
    if (key == null) return;
    if (_events.isEmpty) {
      // Пустой массив сервер не принимает (`min:1`): «не присылать ничего» —
      // это удалить подписку, а не сохранить её без событий.
      fToast(
        context,
        ft(
          'watch_item_need_event',
          'Ən azı bir hadisə seç — heç nə gəlməsin deyirsənsə, izləməni '
              'dayandır',
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.watch(
        key,
        events: _events.toList(),
        muteHours: _muteHours,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      fToast(context, ft('watch_item_saved', 'İzləmə yeniləndi'));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final error = FlightError.from(e);
      setState(() => _saving = false);
      if (error.isUnauthenticated) {
        FlightAuth.present(context);
        return;
      }
      fToast(
        context,
        error.display(ft('watch_item_save_failed', 'İzləmə yenilənmədi')),
      );
    }
  }

  Future<void> _stop() async {
    final key = widget.watch.key;
    if (key == null) return;
    setState(() => _stopping = true);
    try {
      await _repo.unwatch(key);
      if (!mounted) return;
      setState(() => _stopping = false);
      fToast(context, ft('watch_item_stopped', 'İzləmə dayandırıldı'));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final error = FlightError.from(e);
      setState(() => _stopping = false);
      if (error.isUnauthenticated) {
        FlightAuth.present(context);
        return;
      }
      // 404 здесь не ошибка: подписки уже нет, значит цель достигнута.
      if (error.isNotFound) {
        fToast(context, ft('watch_item_stopped', 'İzləmə dayandırıldı'));
        Navigator.of(context).pop(true);
        return;
      }
      fToast(
        context,
        error.display(ft('watch_item_stop_failed', 'İzləmə dayandırılmadı')),
      );
    }
  }
}
