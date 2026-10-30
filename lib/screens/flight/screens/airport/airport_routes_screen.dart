import 'package:flutter/material.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight_stats.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../map/airport_distance_screen.dart';

/// `airport/routes` — прямые направления аэропорта.
///
/// Ответ — массив направлений; сводных чисел в нём нет. «38 istiqamət ·
/// gündə 92 uçuş · 21 ölkə · 17 aviaşirkət» считаются здесь по массиву:
/// направления — длина, рейсы — сумма `averageDailyFlights`, страны —
/// различные `countryCode`, авиакомпании — различные перевозчики.
///
/// Город берётся из самого ответа (`municipalityName`), запрашивать его
/// отдельно не нужно — в отличие от табло, где города нет.
class AirportRoutesScreen extends StatefulWidget {
  const AirportRoutesScreen({super.key, required this.code, this.date});

  final String code;
  final DateTime? date;

  @override
  State<AirportRoutesScreen> createState() => _AirportRoutesScreenState();
}

class _AirportRoutesScreenState extends State<AirportRoutesScreen> {
  final _repo = FlightRepository.instance;

  List<AirportRoute> _routes = const [];
  FlightError? _error;
  String? _stale;
  bool _loading = true;

  late DateTime _date = widget.date ?? DateTime.now();

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
      final result = await _repo.airportRoutes(
        widget.code,
        date: fApiDate(_date),
      );
      if (!mounted) return;
      setState(() {
        final list = [...?result.data];
        // Самые частые направления сверху: порядок ответа произвольный.
        list.sort((a, b) => (b.averageDailyFlights ?? 0)
            .compareTo(a.averageDailyFlights ?? 0));
        _routes = list;
        _stale = fStaleLineText(result.meta, place: widget.code);
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

  double get _dailyFlights => _routes.fold<double>(
        0,
        (sum, route) => sum + (route.averageDailyFlights ?? 0),
      );

  int get _countries => _routes
      .map((route) => route.destination?.countryCode)
      .whereType<String>()
      .map((code) => code.toUpperCase())
      .toSet()
      .length;

  int get _airlines => _routes
      .expand((route) => route.operators)
      .map((operator) => operator.iata ?? operator.icao ?? operator.name)
      .whereType<String>()
      .map((name) => name.toUpperCase())
      .toSet()
      .length;

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('airport_routes_title', '{code} · Marşrutlar', {
        'code': widget.code,
      }),
      stale: _stale,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _loading ? '—' : '${_routes.length}',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                height: 1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ft(
                'routes_hero',
                'birbaşa istiqamət · gündə {n} uçuş',
                {'n': fNum(_dailyFlights)},
              ),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: FT.onHero(.78),
              ),
            ),
            if (!_loading && _routes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  FBadge(
                    ft('routes_countries', '{n} ölkə', {'n': '$_countries'}),
                    background: Colors.white.withValues(alpha: .16),
                    foreground: Colors.white,
                    fontSize: 10.5,
                  ),
                  const SizedBox(width: 6),
                  FBadge(
                    ft('routes_airlines', '{n} aviaşirkət', {'n': '$_airlines'}),
                    background: Colors.white.withValues(alpha: .16),
                    foreground: Colors.white,
                    fontSize: 10.5,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            FHeroPickField(
              label: ft('routes_date', 'Tarix'),
              value: '${fDateShort(_date)}, ${fWeekday(_date)}',
              hint: ft('routes_date_hint', 'o günün cədvəli üzrə'),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
      slivers: [FlightBody(children: _body())],
    );
  }

  List<Widget> _body() {
    if (_loading) return const [FListSkeleton(rows: 6)];
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: _load)];
    }
    if (_routes.isEmpty) {
      return [
        FCalmEmpty(
          title: ft('routes_empty', 'Bu tarixə birbaşa istiqamət tapılmadı'),
          message: ft(
            'routes_empty_message',
            'Mənbə bu liman üçün marşrut siyahısı vermədi. Başqa tarix '
                'seçməyə dəyər.',
          ),
        ),
      ];
    }
    final top = _routes.first.averageDailyFlights ?? 0;
    return [
      FCard(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            for (var i = 0; i < _routes.length; i++)
              _route(_routes[i], top, last: i == _routes.length - 1),
          ],
        ),
      ),
    ];
  }

  Widget _header() {
    final d = fDark(context);
    final style = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: .4,
      color: cMuted(d),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(ft('routes_col_dest', 'İstiqamət'), style: style)),
          Text(ft('routes_col_daily', 'Günlük uçuş'), style: style),
        ],
      ),
    );
  }

  Widget _route(AirportRoute route, double top, {required bool last}) {
    final d = fDark(context);
    final destination = route.destination;
    final code = destination?.code ?? '—';
    final daily = route.averageDailyFlights;
    final operators = route.operators
        .map((operator) => operator.name ?? operator.iata ?? operator.icao)
        .whereType<String>()
        .toList(growable: false);
    return InkWell(
      onTap: destination?.code == null
          ? null
          : () => FlightNav.push(
                context,
                AirportDistanceScreen(from: widget.code, to: destination!.code!),
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: last
            ? null
            : BoxDecoration(
                border: Border(bottom: BorderSide(color: cLine(d))),
              ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 34,
              width: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FT.chip(d),
                borderRadius: FT.rIcon,
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  fontFamilyFallback: const ['Menlo', 'Courier'],
                  color: cText2(d),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          destination?.municipalityName ??
                              destination?.name ??
                              code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: cText(d),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _daily(daily),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          fontFamilyFallback: const ['Menlo', 'Courier'],
                          color: cText(d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _bar(d, daily, top),
                  if (operators.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      operators.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: cText3(d),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Полоса — доля от самого частого направления: процентов в ответе нет,
  /// есть только среднее число рейсов в день.
  Widget _bar(bool d, double? daily, double top) {
    final percent = (daily == null || top <= 0) ? 0.0 : (daily / top);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 5,
        color: FT.chip(d),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: percent.clamp(0.02, 1).toDouble(),
          child: Container(color: FT.brand),
        ),
      ),
    );
  }

  /// `6.2` — дробь оставляем как есть, целое без хвоста: в ответе это
  /// среднее, а не счётчик.
  String _daily(double? value) {
    if (value == null) return '—';
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    setState(() => _date = picked);
    _load();
  }
}
