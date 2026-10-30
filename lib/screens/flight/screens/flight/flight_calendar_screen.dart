import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'flight_instances_screen.dart';

/// `flight/calendar` — в какие дни летает этот номер.
///
/// `GET /flights/{number}/dates?from&to` отдаёт только строки дат — ни времён,
/// ни статусов там нет. Поэтому выбранный день — это второй запрос
/// (`/flights/{number}/{date}`), и он делается лишь после нажатия: месяц
/// целиком не выгружается.
class FlightCalendarScreen extends StatefulWidget {
  const FlightCalendarScreen({
    super.key,
    required this.number,
    required this.displayNumber,
    this.selected,
  });

  final String number;
  final String displayNumber;

  /// Дата, с которой пришли: её месяц показывается первым.
  final String? selected;

  @override
  State<FlightCalendarScreen> createState() => _FlightCalendarScreenState();
}

class _FlightCalendarScreenState extends State<FlightCalendarScreen> {
  final _repo = FlightRepository.instance;

  late DateTime _month;
  Set<String> _dates = const {};
  FlightError? _error;
  String? _stale;
  bool _loading = true;

  String? _picked;
  List<FlightSummary> _dayFlights = const [];
  bool _dayLoading = false;

  @override
  void initState() {
    super.initState();
    final from = widget.selected == null
        ? null
        : DateTime.tryParse(widget.selected!);
    final base = from ?? DateTime.now();
    _month = DateTime(base.year, base.month);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final first = DateTime(_month.year, _month.month, 1);
    final last = DateTime(_month.year, _month.month + 1, 0);
    try {
      final result = await _repo.flightDates(
        widget.number,
        from: fApiDate(first),
        to: fApiDate(last),
      );
      if (!mounted) return;
      setState(() {
        _dates = (result.data ?? const <String>[]).toSet();
        _stale = fStaleLineText(result.meta);
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

  Future<void> _pick(DateTime day) async {
    final date = fApiDate(day);
    setState(() {
      _picked = date;
      _dayFlights = const [];
      _dayLoading = true;
    });
    try {
      final result = await _repo.flights(widget.number, date);
      if (!mounted) return;
      setState(() {
        _dayFlights = result.data ?? const [];
        _dayLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Сам день уже известен — ошибка одного запроса не ломает календарь.
      setState(() => _dayLoading = false);
    }
  }

  void _shift(int months) {
    setState(() {
      _month = DateTime(_month.year, _month.month + months);
      _picked = null;
      _dayFlights = const [];
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('calendar_title', 'Təqvim'),
      subtitle: widget.displayNumber,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FHeroIntro(
              title: ft('calendar_hero', 'Hansı günlər uçur?'),
              message: ft(
                'calendar_hero_message',
                'Rənglənmiş günlərdə bu nömrə uçur. Günə toxun — həmin günün '
                    'uçuşunu göstərək.',
              ),
            ),
            const SizedBox(height: 14),
            FBadge(
              '${fMonth(_month.month)} ${_month.year} · '
              '${ft('calendar_days', '{n} uçuş günü', {'n': '${_dates.length}'})}',
              icon: PhosphorIconsFill.calendarDots,
              background: Colors.white.withValues(alpha: .16),
              foreground: Colors.white,
            ),
          ],
        ),
      ),
      stale: _stale,
      slivers: [
        FlightBody(children: _body(context)),
      ],
    );
  }

  List<Widget> _body(BuildContext context) {
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: _load)];
    }
    return [
      FCard(child: _grid(context)),
      if (_picked != null) ..._dayCard(context),
    ];
  }

  Widget _grid(BuildContext context) {
    final d = fDark(context);
    final first = DateTime(_month.year, _month.month, 1);
    final total = DateTime(_month.year, _month.month + 1, 0).day;
    // В календаре приложения неделя начинается с понедельника.
    final lead = first.weekday - 1;
    final cells = <Widget>[];
    for (var i = 0; i < lead; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= total; day++) {
      cells.add(_dayCell(context, DateTime(_month.year, _month.month, day)));
    }
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _arrow(PhosphorIconsBold.caretLeft, () => _shift(-1)),
            Expanded(
              child: Text(
                '${fMonth(_month.month)} ${_month.year}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cText(d),
                ),
              ),
            ),
            _arrow(PhosphorIconsBold.caretRight, () => _shift(1)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final head in _weekdayHeads)
              Expanded(
                child: Text(
                  head,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                    color: cText3(d),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: FCardSkeleton(rows: 4),
          )
        else
          for (var row = 0; row < cells.length / 7; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(child: cells[row * 7 + col]),
                ],
              ),
            ),
        const SizedBox(height: 10),
        Row(
          children: [
            _legend(context, FT.brand50(d), ft('calendar_flies', 'Uçur')),
            const SizedBox(width: 14),
            _legend(context, FT.brand, ft('calendar_picked', 'Seçildi')),
          ],
        ),
      ],
    );
  }

  Widget _arrow(IconData icon, VoidCallback onTap) {
    final d = fDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rSoft,
      child: Container(
        height: 32,
        width: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FT.chip(d),
          borderRadius: FT.rSoft,
          border: Border.all(color: FT.chipBorder(d)),
        ),
        child: Icon(icon, size: 14, color: cText2(d)),
      ),
    );
  }

  Widget _dayCell(BuildContext context, DateTime day) {
    final d = fDark(context);
    final date = fApiDate(day);
    final flies = _dates.contains(date);
    final picked = _picked == date;
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: flies ? () => _pick(day) : null,
          borderRadius: FT.rSoft,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: picked
                  ? FT.brand
                  : (flies ? FT.brand50(d) : Colors.transparent),
              borderRadius: FT.rSoft,
              border: Border.all(
                color: picked
                    ? FT.brand
                    : (flies ? FT.brand100(d) : Colors.transparent),
              ),
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: flies ? FontWeight.w700 : FontWeight.w600,
                color: picked
                    ? Colors.white
                    : (flies ? FT.brand600(d) : cText3(d)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String label) {
    final d = fDark(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: FT.brand100(d)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cText3(d),
          ),
        ),
      ],
    );
  }

  List<Widget> _dayCard(BuildContext context) {
    final date = _picked!;
    if (_dayLoading) return const [FCardSkeleton(rows: 3)];
    if (_dayFlights.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.calendarX,
          title: ft('calendar_day_empty', 'Bu gün üçün uçuş gəlmədi'),
          message: ft(
            'calendar_day_empty_message',
            'Təqvimdə gün var, amma uçuşun özü mənbədə hələ yoxdur. Bir az '
                'sonra yenidən yoxla.',
          ),
        ),
      ];
    }
    final flight = _dayFlights.first;
    final visual = fStatusVisual(flight.status);
    final from = flight.departureLocal?.clock;
    final to = flight.arrivalLocal?.clock;
    return [
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(
              fDateStringLong(date),
              trailing: _dayFlights.length > 1
                  ? FBadge(
                      ft('calendar_two_legs', '{n} uçuş', {
                        'n': '${_dayFlights.length}',
                      }),
                      fontSize: 9,
                    )
                  : null,
            ),
            FRow(
              ft('calendar_departure', 'Gediş'),
              value: from == null || to == null ? null : '$from → $to',
            ),
            FRow(
              ft('card_aircraft', 'Təyyarə'),
              value: flight.aircraftModel,
            ),
            FRow(
              ft('calendar_status', 'Status'),
              valueWidget: FBadge(
                (flight.statusLabel ?? visual.label).toUpperCase(),
                tone: visual.tone,
                fontSize: 9,
              ),
              last: true,
            ),
          ],
        ),
      ),
      FPrimaryButton(
        label: ft('calendar_open_day', 'Bu günün uçuşuna bax'),
        icon: PhosphorIconsBold.arrowRight,
        onTap: () => FlightNav.push(
          context,
          FlightInstancesScreen(
            number: widget.number,
            displayNumber: widget.displayNumber,
            date: date,
          ),
        ),
      ),
    ];
  }

  List<String> get _weekdayHeads =>
      [for (var weekday = 1; weekday <= 7; weekday++) fWeekdayShort(weekday)];
}
