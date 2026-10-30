import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'flight_card_screen.dart';

/// `flight/history` и `history-future` — последние и будущие вылеты номера.
///
/// Один эндпоинт `GET /flights/{number}/history?from&to` с окном не больше
/// 14 дней: назад — что уже улетело, вперёд — что стоит в расписании. Сервер
/// подрезает слишком широкое окно сам, и фактические границы приходят в
/// `meta.from`/`meta.to` — бейдж сверху показывает их, а не то, что просили.
///
/// Три сводных числа под прошлыми рейсами считаются на телефоне: в ответе
/// такой сводки нет.
class FlightHistoryScreen extends StatefulWidget {
  const FlightHistoryScreen({
    super.key,
    required this.number,
    required this.displayNumber,
    this.future = false,
  });

  final String number;
  final String displayNumber;
  final bool future;

  @override
  State<FlightHistoryScreen> createState() => _FlightHistoryScreenState();
}

class _FlightHistoryScreenState extends State<FlightHistoryScreen> {
  final _repo = FlightRepository.instance;

  late int _index = widget.future ? 1 : 0;

  final _flights = <int, List<FlightSummary>>{};
  final _windows = <int, String?>{};
  final _errors = <int, FlightError?>{};
  final _stale = <int, String?>{};
  final _loading = <int>{};

  bool get _isFuture => _index == 1;

  @override
  void initState() {
    super.initState();
    _load(_index);
  }

  Future<void> _load(int index, {bool force = false}) async {
    if (_loading.contains(index)) return;
    if (!force && _flights.containsKey(index)) return;
    setState(() {
      _loading.add(index);
      _errors[index] = null;
    });
    final today = DateTime.now();
    // Окно в 14 дней — предел эндпоинта: больше сервер всё равно подрежет.
    final from = index == 0 ? today.subtract(const Duration(days: 13)) : today;
    final to = index == 0 ? today : today.add(const Duration(days: 13));
    try {
      final result = await _repo.flightHistory(
        widget.number,
        from: fApiDate(from),
        to: fApiDate(to),
      );
      if (!mounted) return;
      final list = (result.data ?? const <FlightSummary>[]).toList()
        ..sort((a, b) => (a.flightDate ?? '').compareTo(b.flightDate ?? ''));
      setState(() {
        _flights[index] = index == 0 ? list.reversed.toList() : list;
        _windows[index] = _window(
          result.meta.from ?? fApiDate(from),
          result.meta.to ?? fApiDate(to),
        );
        _stale[index] = fStaleLineText(result.meta);
        _loading.remove(index);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errors[index] = FlightError.from(e);
        _loading.remove(index);
      });
    }
  }

  /// `14–21 oktyabr` или `28 sentyabr – 3 oktyabr`.
  String? _window(String? from, String? to) {
    final a = from == null ? null : DateTime.tryParse(from);
    final b = to == null ? null : DateTime.tryParse(to);
    if (a == null || b == null) return null;
    if (a.month == b.month && a.year == b.year) {
      return '${a.day}–${b.day} ${fMonthLower(a.month)}';
    }
    return '${fDateShort(a)} – ${fDateShort(b)}';
  }

  @override
  Widget build(BuildContext context) {
    final list = _flights[_index] ?? const <FlightSummary>[];
    final window = _windows[_index];
    return FlightScaffold(
      title: ft('history_title', 'Son uçuşlar'),
      subtitle: widget.displayNumber,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FSegment(
              onHero: true,
              index: _index,
              items: [
                ft('history_past', 'Keçmiş'),
                ft('history_future', 'Gələcək'),
              ],
              onChanged: (value) {
                setState(() => _index = value);
                _load(value);
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (window != null)
                  FBadge(
                    window,
                    icon: PhosphorIconsFill.calendarDots,
                    background: Colors.white.withValues(alpha: .16),
                    foreground: Colors.white,
                  ),
                if (list.isNotEmpty)
                  FBadge(
                    _isFuture
                        ? ft('history_count_future', '{n} uçuş planlanıb', {
                            'n': '${list.length}',
                          })
                        : ft('history_count', '{n} uçuş', {
                            'n': '${list.length}',
                          }),
                    background: Colors.white.withValues(alpha: .16),
                    foreground: Colors.white,
                  ),
              ],
            ),
          ],
        ),
      ),
      stale: _stale[_index],
      slivers: [
        FlightBody(children: _body(context, list)),
      ],
    );
  }

  List<Widget> _body(BuildContext context, List<FlightSummary> list) {
    if (_loading.contains(_index)) return const [FListSkeleton(rows: 5)];
    final error = _errors[_index];
    if (error != null) {
      return [FErrorView(error: error, onRetry: () => _load(_index, force: true))];
    }
    if (list.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.chartLine,
          title: _isFuture
              ? ft('history_empty_future', 'Planlanmış uçuş yoxdur')
              : ft('history_empty', 'Keçmiş uçuş yoxdur'),
          message: _isFuture
              ? ft(
                  'history_empty_future_message',
                  'Bu nömrə üçün önümüzdəki iki həftəyə cədvəl hələ '
                      'açıqlanmayıb.',
                )
              : ft(
                  'history_empty_message',
                  'Bu nömrə son iki həftədə uçmayıb.',
                ),
        ),
      ];
    }
    return [
      FCard(
        child: Column(
          children: [
            for (var i = 0; i < list.length; i++)
              _row(context, list[i], last: i == list.length - 1),
          ],
        ),
      ),
      if (_isFuture)
        FInfoNote(
          ft(
            'history_future_note',
            'Cədvəl aviaşirkət tərəfindən dəyişdirilə bilər. Təyyarə modeli '
                'uçuşa yaxın təyin olunur.',
          ),
        )
      else
        ..._summary(context, list),
    ];
  }

  Widget _row(BuildContext context, FlightSummary flight, {required bool last}) {
    final visual = fStatusVisual(flight.status);
    final date = flight.flightDate == null
        ? null
        : DateTime.tryParse(flight.flightDate!);
    final from = flight.departureLocal?.clock;
    final to = flight.arrivalLocal?.clock;
    final route = '${flight.departureCode ?? '—'} → ${flight.arrivalCode ?? '—'}';
    final subtitle = _isFuture
        ? [route, flight.aircraftModel ?? ft('history_no_aircraft', 'təyyarə təyin olunmayıb')]
            .join(' · ')
        : [route, _punctuality(flight)].whereType<String>().join(' · ');

    return FDayRow(
      day: date == null ? '—' : '${date.day}',
      unit: date == null
          ? ''
          : (_isFuture
              ? fWeekdayShort(date.weekday)
              : fMonthLower(date.month).substring(0, 3).toUpperCase()),
      dayWidth: _isFuture ? 46 : 42,
      title: from == null || to == null ? '—' : '$from → $to',
      subtitle: subtitle,
      trailing: FBadge(
        (flight.statusLabel ?? visual.label).toUpperCase(),
        tone: visual.tone,
        fontSize: 9,
      ),
      last: last,
      onTap: flight.key == null
          ? null
          : () => FlightNav.push(
                context,
                FlightCardScreen(flightKey: flight.key!),
              ),
    );
  }

  /// `vaxtında` · `7 dəq tez` · `41 dəq gec` — только если задержка известна.
  String? _punctuality(FlightSummary flight) {
    final delay = flight.arrivalDelayMinutes ?? flight.departureDelayMinutes;
    if (delay == null) return null;
    if (delay.abs() <= 2) return ft('history_on_time', 'vaxtında');
    if (delay < 0) {
      return ft('history_early', '{n} dəq tez', {'n': '${delay.abs()}'});
    }
    return ft('history_late', '{n} dəq gec', {'n': '$delay'});
  }

  /// Сводка по показанным рейсам. Считается только по тем, у которых
  /// фактическая задержка известна — иначе процент был бы выдуманным.
  List<Widget> _summary(BuildContext context, List<FlightSummary> list) {
    final d = fDark(context);
    final delays = list
        .map((flight) => flight.arrivalDelayMinutes ?? flight.departureDelayMinutes)
        .whereType<int>()
        .toList();
    final canceled =
        list.where((flight) => FlightStatus.isCanceled(flight.status)).length;
    final onTime = delays.where((minutes) => minutes <= 15).length;
    final late = delays.where((minutes) => minutes > 0).toList();
    final average = late.isEmpty
        ? null
        : (late.reduce((a, b) => a + b) / late.length).round();

    return [
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(
              ft('history_summary', 'BU {n} UÇUŞ ÜZRƏ', {'n': '${list.length}'}),
            ),
            const SizedBox(height: 4),
            FEqualRow(
              children: [
                Expanded(
                  child: FMiniTile(
                    label: ft('history_on_time_label', 'VAXTINDA'),
                    value: delays.isEmpty
                        ? '—'
                        : '${(onTime * 100 / delays.length).round()}%',
                    valueColor: FT.ok(d),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FMiniTile(
                    label: ft('history_average_label', 'ORTA GECİKMƏ'),
                    value: average == null
                        ? '—'
                        : '$average ${ft('unit_min_short', 'dəq')}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FMiniTile(
                    label: ft('history_canceled_label', 'LƏĞV'),
                    value: '$canceled',
                    valueColor: canceled == 0 ? null : FT.bad(d),
                  ),
                ),
              ],
            ),
            if (delays.length != list.length) ...[
              const SizedBox(height: 11),
              FInfoNote(
                ft(
                  'history_summary_note',
                  'Faiz yalnız faktiki vaxtı bilinən {n} uçuş üzrə '
                      'hesablanıb.',
                  {'n': '${delays.length}'},
                ),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}
