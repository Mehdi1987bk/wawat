import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_widgets.dart';
import 'flight_card_screen.dart';

/// `flight/instances` — выбор плеча, когда номер за день летит дважды.
///
/// Ответ `GET /flights/{number}/{date}` — всегда массив (§4.1). Пустой —
/// спокойный пустой экран, один элемент — сразу карточка (этот экран
/// подменяет себя, чтобы «назад» не возвращал на лишний шаг), два и больше —
/// список: без `departure_code` карточка не знает, какое плечо открывать.
class FlightInstancesScreen extends StatefulWidget {
  const FlightInstancesScreen({
    super.key,
    required this.number,
    required this.date,
    this.displayNumber,
  });

  final String number;
  final String date;
  final String? displayNumber;

  @override
  State<FlightInstancesScreen> createState() => _FlightInstancesScreenState();
}

class _FlightInstancesScreenState extends State<FlightInstancesScreen> {
  final _repo = FlightRepository.instance;

  List<FlightSummary> _flights = const [];
  FlightError? _error;
  String? _stale;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.flights(widget.number, widget.date, force: force);
      if (!mounted) return;
      final list = result.data ?? const <FlightSummary>[];
      setState(() {
        _flights = list;
        _stale = fStaleLineText(result.meta);
        _loading = false;
      });
      if (list.length == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          FlightNav.replace(
            context,
            FlightCardScreen(flightKey: _keyOf(list.first)),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _loading = false;
      });
    }
  }

  FlightKey _keyOf(FlightSummary flight) =>
      flight.key ??
      FlightKey(
        number: widget.number,
        flightDate: widget.date,
        departureCode: flight.departureCode,
      );

  @override
  Widget build(BuildContext context) {
    final title = widget.displayNumber ?? widget.number;
    return FlightScaffold(
      title: title,
      subtitle: fDateStringShort(widget.date),
      hero: _flights.length < 2
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FHeroIntro(
                    title: ft('instances_hero', 'Hansı uçuş?'),
                    message: ft(
                      'instances_hero_message',
                      'Bu nömrə {date} tarixində {n} dəfə uçur. Birini seç.',
                      {
                        'date': fDateStringShort(widget.date),
                        'n': '${_flights.length}',
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      FBadge(
                        fDateStringLong(widget.date),
                        icon: PhosphorIconsFill.calendarDot,
                        background: Colors.white.withValues(alpha: .16),
                        foreground: Colors.white,
                      ),
                      FBadge(
                        ft('instances_count', '{n} nəticə', {
                          'n': '${_flights.length}',
                        }),
                        background: Colors.white.withValues(alpha: .16),
                        foreground: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
      stale: _stale,
      slivers: [
        FlightBody(children: _body()),
      ],
    );
  }

  List<Widget> _body() {
    if (_loading) return const [FListSkeleton(rows: 3)];
    if (_error != null) {
      return [
        FErrorView(
          error: _error!,
          onRetry: () => _load(force: true),
          onBack: () => Navigator.of(context).maybePop(),
          notFoundTitle: ft('instances_not_found', 'Bu nömrə tapılmadı'),
          notFoundMessage: ft(
            'instances_not_found_message',
            'Nömrəni yoxla: hərflər aviaşirkətin kodu, rəqəmlər uçuşun '
                'nömrəsidir.',
          ),
        ),
      ];
    }
    if (_flights.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.calendarX,
          title: ft('instances_empty', 'Bu tarixdə uçuş yoxdur'),
          message: ft(
            'instances_empty_message',
            'Bu nömrə həmin gün uçmur. Təqvimdən uçduğu günlərə bax.',
          ),
        ),
      ];
    }
    // Один рейс уже уходит в карточку — пока кадр не сменился, список не
    // мигает лишним содержимым.
    if (_flights.length == 1) return const [FListSkeleton(rows: 1)];
    return [
      for (final flight in _flights) _row(flight),
    ];
  }

  Widget _row(FlightSummary flight) {
    final visual = fStatusVisual(flight.status);
    final from = flight.departureCode ?? '—';
    final to = flight.arrivalCode ?? '—';
    final departure = flight.departureLocal?.clock;
    final arrival = flight.arrivalLocal?.clock;
    final meta = [flight.airline?.name, flight.aircraftModel]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' · ');
    return FFlightRow(
      number: flight.displayNumber,
      statusLabel: flight.statusLabel ?? visual.label,
      statusTone: visual.tone,
      route: '$from → $to',
      times: departure == null || arrival == null
          ? null
          : '$departure → $arrival',
      meta: meta.isEmpty ? null : meta,
      onTap: () => FlightNav.push(
        context,
        FlightCardScreen(flightKey: _keyOf(flight)),
      ),
    );
  }
}
