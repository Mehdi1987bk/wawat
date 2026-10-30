import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight_stats.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'airport_board_screen.dart';
import 'airport_feeds_screen.dart';

/// `airport/delays`, `delays-past`, `delays-period` и `delays-none` — один
/// экран с тремя режимами.
///
/// Ответ идёт от провайдера как есть, поля в camelCase: на каждой стороне
/// `medianDelay`, `delayIndex`, `numTotal`, `numQualifiedTotal`,
/// `numCancelled`. Разбивки «0–15 / 15–30 / 30–60 / 60+» в этом ответе
/// **нет** — она есть только в статистике рейса (`/flights/{number}/delays`),
/// поэтому в прототипе такие полосы нарисованы, а здесь их нет: выдумывать
/// проценты нельзя (§16).
///
/// Причины задержки (погода, ветер, METAR) в модуле тоже нет источника.
///
/// Окно — максимум 12 часов: сервер молча обрезает `to` до `from + 12 ч`, а
/// фактическое окно возвращает в `meta.from` / `meta.to`. Суток или недели
/// одним запросом не бывает — каждые 12 часов это отдельный запрос.
///
/// `data: null` плюс `meta.unavailable_reason` — не ошибка, а спокойное
/// пустое состояние: по измерениям так отвечает GYD.
class AirportDelaysScreen extends StatefulWidget {
  const AirportDelaysScreen({super.key, required this.code, this.airport});

  final String code;
  final Airport? airport;

  @override
  State<AirportDelaysScreen> createState() => _AirportDelaysScreenState();
}

enum _Mode { now, past, period }

class _AirportDelaysScreenState extends State<AirportDelaysScreen> {
  final _repo = FlightRepository.instance;

  _Mode _mode = _Mode.now;
  AirportDelays? _delays;
  FlightError? _error;
  String? _stale;
  String? _reason;
  bool _loading = true;

  late DateTime _moment = _localNow.subtract(const Duration(hours: 12));
  late DateTime _from = DateTime(_localNow.year, _localNow.month, _localNow.day, 6);
  late DateTime _to = DateTime(_localNow.year, _localNow.month, _localNow.day, 18);

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime get _localNow {
    final raw = widget.airport?.localTime;
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    return parsed ?? DateTime.now();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _reason = null;
    });
    try {
      final result = switch (_mode) {
        // Без параметров — текущий момент.
        _Mode.now => await _repo.airportDelays(widget.code),
        // Только `from`: окно сервер достроит сам до from + 12 часов.
        _Mode.past => await _repo.airportDelays(
            widget.code,
            from: fApiLocalWindow(_moment),
            to: fApiLocalWindow(_moment.add(const Duration(hours: 12))),
          ),
        _Mode.period => await _repo.airportDelays(
            widget.code,
            from: fApiLocalWindow(_from),
            to: fApiLocalWindow(_to),
          ),
      };
      if (!mounted) return;
      setState(() {
        _delays = result.data;
        _stale = fStaleLineText(result.meta, place: widget.code);
        _reason = result.meta.unavailableReason;
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

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('airport_delays_title', '{code} · Gecikmələr', {
        'code': widget.code,
      }),
      stale: _stale,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FSegment(
              onHero: true,
              index: _Mode.values.indexOf(_mode),
              items: [
                ft('delays_mode_now', 'İndi'),
                ft('delays_mode_past', 'Keçmiş an'),
                ft('delays_mode_period', 'Dövr'),
              ],
              onChanged: (value) {
                final mode = _Mode.values[value];
                if (mode == _mode) return;
                setState(() {
                  _mode = mode;
                  _delays = null;
                });
                _load();
              },
            ),
            const SizedBox(height: 12),
            ..._heroControls(),
          ],
        ),
      ),
      slivers: [
        FlightBody(children: _body()),
      ],
    );
  }

  List<Widget> _heroControls() {
    switch (_mode) {
      case _Mode.now:
        return [
          Text(
            [
              widget.airport?.summary.fullName ?? widget.airport?.summary.name,
              ft('delays_now_hint', 'indiki an'),
            ].whereType<String>().join(' · '),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FT.onHero(.74),
            ),
          ),
        ];
      case _Mode.past:
        return [
          FHeroPickField(
            label: ft('delays_moment', 'Seçilmiş an'),
            value: fApiLocalWindow(_moment).replaceFirst('T', ' '),
            hint: ft('delays_moment_hint', '12 saatlıq pəncərə'),
            onTap: () => _pickMoment(),
          ),
        ];
      case _Mode.period:
        return [
          Row(
            children: [
              Expanded(
                child: FHeroPickField(
                  label: ft('board_filter_start', 'Başlanğıc'),
                  value: fApiLocalWindow(_from).replaceFirst('T', ' '),
                  onTap: () => _pickRange(start: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FHeroPickField(
                  label: ft('board_filter_end', 'Son'),
                  value: fApiLocalWindow(_to).replaceFirst('T', ' '),
                  onTap: () => _pickRange(start: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                PhosphorIconsBold.clock,
                size: 13,
                color: FT.onHero(.66),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ft(
                    'delays_window_cap',
                    'Bir dəfəyə ən çox 12 saatlıq pəncərə',
                  ),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: FT.onHero(.66),
                  ),
                ),
              ),
            ],
          ),
        ];
    }
  }

  List<Widget> _body() {
    if (_loading) return const [FCardSkeleton(rows: 4), FCardSkeleton(rows: 4)];
    if (_error != null) {
      return [
        FErrorView(
          error: _error!,
          onRetry: _load,
          onFeeds: _openFeeds,
        ),
      ];
    }
    final delays = _delays;
    // Пустое состояние — только когда тела нет совсем. Если сторона пришла,
    // но без измерения, правда звучит как «неизвестно», а не «задержек нет»:
    // `medianDelay` и `delayIndex` приходят лишь при `numQualifiedTotal > 0`,
    // и это основной случай, а не краевой.
    if (delays == null ||
        (delays.departures == null && delays.arrivals == null)) {
      return [_none()];
    }
    return [
      if (delays.departures != null)
        _sideCard(
          title: ft('airport_departures', 'Gedişlər'),
          side: delays.departures!,
        ),
      if (delays.arrivals != null)
        _sideCard(
          title: ft('airport_arrivals', 'Gəlişlər'),
          side: delays.arrivals!,
        ),
      _windowCard(delays),
      FInfoNote(
        ft(
          'delays_explain',
          'Gecikmə cədvəl saatı ilə faktiki saat arasındakı fərqdir. '
              '«Hesablamaya düşən» rəqəmi ümumi uçuş sayına nə qədər '
              'yaxındırsa, statistika o qədər etibarlıdır.',
        ),
      ),
    ];
  }

  /// `delays-none`: источник не ведёт статистику по этому лиману. Текст
  /// провайдера (`unavailable_reason`) человеку не показываем — он
  /// английский и нужен поддержке.
  Widget _none() {
    return FStateBlock(
      icon: PhosphorIconsFill.chartLineDown,
      title: ft('delays_none_title', '{code} üçün gecikmə statistikası yoxdur', {
        'code': widget.code,
      }),
      message: ft(
        'delays_none_message',
        'Mənbə bu liman üçün gecikmə hesabı aparmır. Cədvəl, lövhə və zolaq '
            'məlumatı normal işləyir — yalnız bu statistika gəlmir.',
      ),
      actions: [
        FSecondaryButton(
          label: ft('delays_none_feeds', 'Data mənbələrinə bax'),
          icon: PhosphorIconsBold.pulse,
          onTap: _openFeeds,
        ),
        FSecondaryButton(
          label: ft('delays_none_board', 'Lövhəyə keç'),
          icon: PhosphorIconsBold.airplaneTakeoff,
          onTap: () => FlightNav.push(
            context,
            AirportBoardScreen(code: widget.code, airport: widget.airport),
          ),
        ),
      ],
    );
  }

  Widget _sideCard({required String title, required DelaySide side}) {
    final d = fDark(context);
    final index = side.delayIndex;
    final tone = _indexTone(index);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            title,
            trailing: FBadge(_indexLabel(index), tone: tone, fontSize: 9.5),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                side.medianDelay == null
                    ? '—'
                    : fMinutesShort(side.medianDelay!.value.inMinutes),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: cText(d),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ft('delays_median_small', 'median gecikmə'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cText3(d),
                ),
              ),
            ],
          ),
          if (index != null) ...[
            const SizedBox(height: 12),
            FBarRow(
              label: ft('delays_index', 'Gecikmə indeksi'),
              value: '${index.toStringAsFixed(1)} / 5.0',
              percent: (index / 5 * 100).clamp(0, 100).toDouble(),
              color: tone.fg(d),
              last: true,
            ),
          ],
          const SizedBox(height: 10),
          FRow(
            ft('delays_total', 'Uçuş sayı'),
            value: side.numTotal?.toString() ?? '—',
          ),
          FRow(
            ft('delays_qualified', 'Hesablamaya düşən'),
            value: side.numQualifiedTotal?.toString() ?? '—',
          ),
          FRow(
            ft('delays_cancelled', 'Ləğv edilən'),
            value: side.numCancelled?.toString() ?? '—',
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _windowCard(AirportDelays delays) {
    final from = delays.from;
    final to = delays.to;
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FRow(
            ft('delays_window', 'Pəncərə'),
            value: _windowValue(from, to),
            last: _reason == null,
          ),
          if (_reason != null)
            FRow(
              ft('delays_source_note', 'Mənbə qeydi'),
              value: _reason,
              last: true,
            ),
        ],
      ),
    );
  }

  /// Фактическое окно всегда берётся из ответа: сервер мог обрезать наше.
  String _windowValue(String? from, String? to) {
    if (from == null || to == null) {
      return ft('delays_window_now', 'indiki an');
    }
    final a = DateTime.tryParse(from);
    final b = DateTime.tryParse(to);
    if (a == null || b == null) return '$from → $to';
    final hours = b.difference(a).inMinutes / 60;
    return '${fClock(a)} → ${fClock(b)} · '
        '${ft('delays_window_hours', '{n} saat', {
          'n': hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1),
        })}';
  }

  /// «Normal / Yüksək / Ciddi» — из `delayIndex`; своего слова в ответе нет.
  String _indexLabel(double? index) {
    if (index == null) return ft('delays_index_unknown', 'Bilinmir');
    if (index < 2) return ft('delays_index_normal', 'Normal');
    if (index < 3.5) return ft('delays_index_high', 'Yüksək');
    return ft('delays_index_severe', 'Ciddi');
  }

  FTone _indexTone(double? index) {
    if (index == null) return FTone.mute;
    if (index < 2) return FTone.ok;
    if (index < 3.5) return FTone.warn;
    return FTone.bad;
  }

  void _openFeeds() =>
      FlightNav.push(context, AirportFeedsScreen(code: widget.code));

  Future<void> _pickMoment() async {
    final picked = await _pickStamp(_moment);
    if (!mounted || picked == null) return;
    setState(() => _moment = picked);
    _load();
  }

  Future<void> _pickRange({required bool start}) async {
    final picked = await _pickStamp(start ? _from : _to);
    if (!mounted || picked == null) return;
    setState(() {
      if (start) {
        _from = picked;
        // Больше 12 часов сервер всё равно обрежет — не даём выбрать лишнее.
        if (!_to.isAfter(_from) ||
            _to.difference(_from) > const Duration(hours: 12)) {
          _to = _from.add(const Duration(hours: 12));
        }
      } else {
        _to = picked;
        if (_to.difference(_from) > const Duration(hours: 12)) {
          _from = _to.subtract(const Duration(hours: 12));
        }
      }
    });
    _load();
  }

  Future<DateTime?> _pickStamp(DateTime current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: _localNow.subtract(const Duration(days: 365)),
      lastDate: _localNow.add(const Duration(days: 2)),
    );
    if (!mounted || date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
