import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_city_names.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../data/models/flight_stats.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../flight/flight_card_screen.dart';
import 'airport_board_filter_screen.dart';
import 'airport_feeds_screen.dart';

/// `airport/departures` и `airport/arrivals` — одно табло с переключателем.
///
/// Эндпоинт один (`/board`), меняется только `direction`, поэтому и экран
/// один: две копии разошлись бы при первой правке строки.
///
/// Из полей табло строится так: `*_local` — это **расписание**
/// (`scheduled.local`); если есть задержка, зачёркнутым показывается именно
/// оно, а крупным — расписание плюс `*_delay_minutes`. Сортировка — по
/// крупному времени.
///
/// Чего в ответе табло нет и чего поэтому нет в строке: выхода, стойки
/// регистрации, баггажной лены (они только в `/detail`, то есть запрос на
/// строку) и названия города — код раскрывается нашим каталогом лиманов.
///
/// Бейдж «Cədvəl üzrə» / «Canlı» берётся из `/feeds`: в Баку поток живых
/// обновлений лежит, `is_live` у всех строк `false`, и писать «Canlı» нельзя.
class AirportBoardScreen extends StatefulWidget {
  const AirportBoardScreen({
    super.key,
    required this.code,
    this.airport,
    this.arrivals = false,
  });

  final String code;
  final Airport? airport;
  final bool arrivals;

  @override
  State<AirportBoardScreen> createState() => _AirportBoardScreenState();
}

class _AirportBoardScreenState extends State<AirportBoardScreen> {
  final _repo = FlightRepository.instance;

  late bool _arrivals = widget.arrivals;
  BoardFilter _filter = const BoardFilter();

  List<FlightSummary> _flights = const [];
  AirportFeeds? _feeds;
  Airport? _airport;
  FlightError? _error;
  String? _stale;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _airport = widget.airport;
    _load();
  }

  /// Местное время лимана считает сервер (`local_time`) — на телефоне своя
  /// зона, и окно «следующие два часа» по ней уехало бы.
  DateTime get _localNow {
    final raw = _airport?.localTime;
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    return parsed ?? DateTime.now();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await FlightCityNames.load();
    if (_airport == null) {
      try {
        final result = await _repo.airport(widget.code);
        if (!mounted) return;
        _airport = result.data;
      } catch (_) {
        // Карточка лимана тут нужна только для местного времени и зоны.
      }
    }
    try {
      final window = _window();
      final result = await _repo.board(
        widget.code,
        direction: _arrivals ? BoardDirection.arrival : BoardDirection.departure,
        from: window?.$1,
        to: window?.$2,
        force: force,
      );
      AirportFeeds? feeds = _feeds;
      if (feeds == null) {
        try {
          feeds = (await _repo.feeds(widget.code)).data;
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _flights = _sorted(result.data ?? const []);
        _stale = fStaleLineText(result.meta, place: widget.code);
        _feeds = feeds;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _loading = false;
      });
    }
  }

  /// `from` без `to` сервер не принимает (`required_with`), поэтому окно
  /// всегда парное; пустое окно означает серверное «−2 часа → +10 часов».
  (String, String)? _window() {
    final hours = _filter.hours;
    if (hours != null) {
      final from = _localNow;
      return (fApiLocalWindow(from), fApiLocalWindow(
        from.add(Duration(hours: hours)),
      ));
    }
    final from = _filter.from;
    final to = _filter.to;
    if (from == null || to == null) return null;
    return (fApiLocalWindow(from), fApiLocalWindow(to));
  }

  List<FlightSummary> _sorted(List<FlightSummary> all) {
    final list = [...all];
    list.sort((a, b) => _actualMinutes(a).compareTo(_actualMinutes(b)));
    return list;
  }

  int _actualMinutes(FlightSummary flight) =>
      fClockMinutes(_actualClock(flight));

  String? _scheduledClock(FlightSummary flight) =>
      _arrivals ? flight.arrivalLocal?.clock : flight.departureLocal?.clock;

  int? _delay(FlightSummary flight) =>
      _arrivals ? flight.arrivalDelayMinutes : flight.departureDelayMinutes;

  String? _actualClock(FlightSummary flight) =>
      fClockPlus(_scheduledClock(flight), _delay(flight));

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('board_title', '{code} · Lövhə', {'code': widget.code}),
      actions: [
        FSkyAction(icon: PhosphorIconsBold.funnel, onTap: _openFilter),
      ],
      stale: _stale,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FSegment(
              onHero: true,
              index: _arrivals ? 1 : 0,
              items: [
                ft('airport_departures', 'Gedişlər'),
                ft('airport_arrivals', 'Gəlişlər'),
              ],
              onChanged: (value) {
                final arrivals = value == 1;
                if (arrivals == _arrivals) return;
                setState(() {
                  _arrivals = arrivals;
                  _flights = const [];
                });
                _load();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _sourceBadge(),
                      FBadge(
                        _windowLabel(),
                        background: FT.heroBadgeBg(FTone.info),
                        foreground: FT.heroBadgeFg(FTone.info),
                        fontSize: 9.5,
                        onTap: _openFilter,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_localNow.hour.toString().padLeft(2, '0')}:'
                  '${_localNow.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FT.onHero(.88),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(gap: 8, children: _body()),
      ],
    );
  }

  /// Живые данные или расписание — это свойство лимана, не рейса.
  Widget _sourceBadge() {
    final live = _feeds?.live.status;
    final isLive = live == FeedStatus.ok || live == FeedStatus.okPartial;
    return FBadge(
      isLive
          ? ft('board_source_live', 'Canlı')
          : ft('board_source_schedule', 'Cədvəl üzrə'),
      icon: isLive
          ? PhosphorIconsFill.broadcast
          : PhosphorIconsFill.calendarDots,
      background: FT.heroBadgeBg(isLive ? FTone.ok : FTone.info),
      foreground: FT.heroBadgeFg(isLive ? FTone.ok : FTone.info),
      fontSize: 9.5,
      onTap: () => FlightNav.push(
        context,
        AirportFeedsScreen(code: widget.code),
      ),
    );
  }

  String _windowLabel() {
    final hours = _filter.hours;
    if (hours != null) {
      return ft('board_window_hours', 'Növbəti {n} saat', {'n': '$hours'});
    }
    final from = _filter.from;
    final to = _filter.to;
    if (from == null || to == null) {
      return ft('board_window_default', 'Standart pəncərə');
    }
    return '${from.hour.toString().padLeft(2, '0')}:'
        '${from.minute.toString().padLeft(2, '0')} → '
        '${to.hour.toString().padLeft(2, '0')}:'
        '${to.minute.toString().padLeft(2, '0')}';
  }

  List<Widget> _body() {
    if (_loading) return const [FListSkeleton(rows: 6)];
    if (_error != null) {
      return [
        FErrorView(
          error: _error!,
          onRetry: () => _load(force: true),
          onFeeds: () => FlightNav.push(
            context,
            AirportFeedsScreen(code: widget.code),
          ),
        ),
      ];
    }
    final visible = _visible();
    if (visible.isEmpty) {
      return [
        FEmptyResult(
          icon: PhosphorIconsFill.calendarX,
          title: _flights.isEmpty
              ? ft('board_empty', 'Bu pəncərədə uçuş yoxdur')
              : ft('board_filtered_out', 'Süzgəc hamısını kənarda qoydu'),
          message: _flights.isEmpty
              ? ft(
                  'board_empty_message',
                  'Vaxt aralığını genişləndir — gün ərzində uçuş ola bilər.',
                )
              : ft(
                  'board_filtered_out_message',
                  'Yük və ləğv olunan uçuşların göstərilməsini aç.',
                ),
          actions: [
            FSecondaryButton(
              label: ft('board_change_window', 'Aralığı dəyiş'),
              icon: PhosphorIconsBold.funnel,
              onTap: _openFilter,
            ),
          ],
        ),
      ];
    }
    return [
      for (final flight in visible) _row(flight),
    ];
  }

  /// Серверного фильтра у этих двух нет — отбор на телефоне.
  List<FlightSummary> _visible() => _flights.where((flight) {
        if (!_filter.showCargo && flight.isCargo) return false;
        if (!_filter.showCanceled && FlightStatus.isCanceled(flight.status)) {
          return false;
        }
        return true;
      }).toList(growable: false);

  Widget _row(FlightSummary flight) {
    final d = fDark(context);
    final visual = fStatusVisual(flight.status);
    final delay = _delay(flight);
    final delayed = delay != null && delay != 0;
    final scheduled = _scheduledClock(flight);
    final actual = _actualClock(flight);
    final code = _arrivals ? flight.departureCode : flight.arrivalCode;
    final meta = [
      flight.displayNumber,
      flight.airline?.name,
      flight.aircraftModel,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' · ');
    return FCard(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      onTap: () => _open(flight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actual ?? '—',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: cText(d),
                  ),
                ),
                if (delayed && scheduled != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      scheduled,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: FT.struck,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FlightCityNames.label(code),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                if (meta.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cText3(d),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FBadge(
                flight.statusLabel ?? visual.label,
                tone: visual.tone,
                fontSize: 9,
              ),
              if (delayed)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    fDeltaMinutes(delay),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: FT.warn(d),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _open(FlightSummary flight) {
    final key = flight.key ??
        FlightKey(
          number: flight.number,
          flightDate: flight.flightDate ?? fApiDate(DateTime.now()),
          // На табло гедишей вылет — это наш лиман; на гелишах код вылета
          // приходит в самой строке.
          departureCode: _arrivals ? flight.departureCode : widget.code,
        );
    FlightNav.push(context, FlightCardScreen(flightKey: key));
  }

  Future<void> _openFilter() async {
    final result = await FlightNav.push<BoardFilter>(
      context,
      AirportBoardFilterScreen(
        filter: _filter,
        localNow: _localNow,
        timeZone: _airport?.timeZone,
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _filter = result);
    _load();
  }
}
