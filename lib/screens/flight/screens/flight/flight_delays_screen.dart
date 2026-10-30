import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight_stats.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `flight/delays` — статистика задержек номера.
///
/// `GET /flights/{number}/delays` — тело провайдера как есть (§7.5): медиана,
/// персентили, группы и число учтённых рейсов. Периода наблюдения в ответе
/// нет, поэтому диапазон дат на экране не показывается — только «по N
/// рейсам».
///
/// `class` — оценка провайдера. Известные значения переводятся, незнакомое
/// показывается как пришло: придумывать градацию нельзя.
class FlightDelaysScreen extends StatefulWidget {
  const FlightDelaysScreen({
    super.key,
    required this.number,
    required this.displayNumber,
  });

  final String number;
  final String displayNumber;

  @override
  State<FlightDelaysScreen> createState() => _FlightDelaysScreenState();
}

class _FlightDelaysScreenState extends State<FlightDelaysScreen> {
  final _repo = FlightRepository.instance;

  FlightDelayStats? _stats;
  FlightError? _error;
  String? _stale;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.flightDelays(widget.number);
      if (!mounted) return;
      setState(() {
        _stats = result.data;
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

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final median = stats?.medianDelay?.minutes;
    return FlightScaffold(
      title: ft('delays_title', 'Gecikmə statistikası'),
      subtitle: widget.displayNumber,
      hero: median == null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ft('delays_median', 'MEDİAN GECİKMƏ'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .6,
                      color: FT.onHero(.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$median',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          ft('unit_minute', 'dəqiqə'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: FT.onHero(.7),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_classLabel != null)
                        FBadge(
                          _classLabel!,
                          background: Colors.white.withValues(alpha: .18),
                          foreground: Colors.white,
                        ),
                    ],
                  ),
                  if (stats?.numConsideredFlights != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        ft(
                          'delays_based_on',
                          '{n} uçuş əsasında hesablanıb',
                          {'n': '${stats!.numConsideredFlights}'},
                        ),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: FT.onHero(.6),
                        ),
                      ),
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
    if (_loading) return const [FCardSkeleton(rows: 4)];
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: _load)];
    }
    final stats = _stats;
    if (stats == null || stats.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.timer,
          title: ft('delays_empty', 'Statistika yoxdur'),
          message: ft(
            'delays_empty_message',
            'Bu nömrə üzrə ölçülmüş uçuş sayı statistika üçün azdır.',
          ),
        ),
      ];
    }

    return [
      if (stats.percentiles.isNotEmpty) _percentiles(context, stats),
      if (stats.brackets.isNotEmpty) _brackets(context, stats),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FRow(
              ft('delays_considered', 'Nəzərə alınan uçuş'),
              value: stats.numConsideredFlights == null
                  ? null
                  : '${stats.numConsideredFlights}',
            ),
            FRow(
              ft('delays_class', 'Hesablama sinfi'),
              value: stats.delayClass,
              mono: true,
              last: true,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _percentiles(BuildContext context, FlightDelayStats stats) {
    final d = fDark(context);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(ft('delays_percentiles', 'Persentillər')),
          const SizedBox(height: 4),
          FEqualRow(
            children: [
              for (var i = 0; i < stats.percentiles.length; i++) ...[
                if (i != 0) const SizedBox(width: 8),
                Expanded(child: _percentileTile(d, stats.percentiles[i])),
              ],
            ],
          ),
          const SizedBox(height: 11),
          FInfoNote(
            ft(
              'delays_percentiles_note',
              'P90 = 10 uçuşdan 9-u bu gecikmədən az gecikib. Yüksək P95 '
                  'nadir, amma uzun gecikmələri göstərir.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _percentileTile(bool d, DelayPercentile percentile) {
    final minutes = percentile.delay?.minutes;
    final p = percentile.percentile;
    final color = p <= 50
        ? FT.ok(d)
        : (p <= 90 ? FT.warn(d) : FT.bad(d));
    return FMiniTile(
      label: percentile.label,
      value: minutes == null
          ? '—'
          : '$minutes ${ft('unit_min_short', 'dəq')}',
      valueColor: color,
    );
  }

  Widget _brackets(BuildContext context, FlightDelayStats stats) {
    final d = fDark(context);
    final total = stats.brackets
        .map((bracket) => bracket.numFlights ?? 0)
        .fold<int>(0, (a, b) => a + b);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(ft('delays_brackets', 'Gecikmə qrupları')),
          const SizedBox(height: 8),
          for (var i = 0; i < stats.brackets.length; i++)
            _bracketRow(
              d,
              stats.brackets[i],
              total,
              last: i == stats.brackets.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _bracketRow(
    bool d,
    DelayBracket bracket,
    int total, {
    required bool last,
  }) {
    final flights = bracket.numFlights ?? 0;
    final percent = total == 0 ? 0.0 : flights * 100 / total;
    final from = bracket.from?.minutes ?? 0;
    final color = from <= 15
        ? FT.ok(d)
        : (from < 60 ? FT.warn(d) : FT.bad(d));
    return FBarRow(
      label: bracket.range(ft('unit_min_short', 'dəq')),
      value: ft('delays_flights', '{n} uçuş', {'n': '$flights'}),
      percent: percent,
      color: color,
      last: last,
    );
  }

  /// Оценка провайдера. Незнакомое значение показывается как есть.
  String? get _classLabel {
    final raw = _stats?.delayClass;
    if (raw == null || raw.trim().isEmpty) return null;
    return switch (raw.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '')) {
      'excellent' => ft('delays_class_excellent', 'Çox yaxşı'),
      'good' => ft('delays_class_good', 'Yaxşı'),
      'fair' || 'average' || 'medium' => ft('delays_class_fair', 'Orta'),
      'poor' || 'bad' => ft('delays_class_poor', 'Pis'),
      'verypoor' => ft('delays_class_very_poor', 'Çox pis'),
      _ => raw,
    };
  }
}
