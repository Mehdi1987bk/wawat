import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_widgets.dart';
import '../airport/airport_list_screen.dart';
import 'link_attach_screen.dart';

/// `link/route-pick` — выбор рейса для объявления.
///
/// Единственный путь заполнить объявление данными рейса (§4.1): города и
/// дата → `GET /routes/{from}/{to}/{date}` → человек выбирает рейс из списка.
/// По одному номеру заполнить нельзя: в один день номер может выполнять
/// несколько плеч, и ответ по номеру тоже массив.
///
/// В списке остаются только предстоящие вылеты: у объявления `flight_date`
/// проверяется как `after_or_equal:today`, а время проходит правило
/// `DepartureNotPassed` — улетевший рейс вернул бы 422.
class LinkRoutePickScreen extends StatefulWidget {
  /// Лиманы приходят заполненными, когда экран открыт с готового маршрута —
  /// например с калькулятора расстояния.
  const LinkRoutePickScreen({super.key, this.from, this.to});

  final AirportSummary? from;
  final AirportSummary? to;

  @override
  State<LinkRoutePickScreen> createState() => _LinkRoutePickScreenState();
}

class _LinkRoutePickScreenState extends State<LinkRoutePickScreen> {
  final _repo = FlightRepository.instance;

  AirportSummary? _from;
  AirportSummary? _to;
  DateTime _date = DateTime.now();

  List<FlightSummary> _flights = const [];
  FlightSummary? _picked;
  FlightError? _error;
  String? _stale;
  bool _loading = false;
  bool _asked = false;

  bool get _ready => _from != null && _to != null;

  @override
  void initState() {
    super.initState();
    _from = widget.from;
    _to = widget.to;
    if (_ready) _load();
  }

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('link_pick_title', 'Uçuş seç'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('link_pick_hero', 'Elanın üçün uçuş seç'),
          message: ft(
            'link_pick_hero_message',
            'Şəhəri və tarixi göstər — həmin günün uçuşlarını gətirək. Uçuş '
                'nömrəsini bilmək şərt deyil.',
          ),
        ),
      ),
      stale: _stale,
      slivers: [
        FlightBody(
          gap: 14,
          children: [
            Column(
              children: [
                FFieldRow(
                  icon: PhosphorIconsFill.airplaneTakeoff,
                  label: ft('link_pick_from', 'Haradan'),
                  value: _from == null
                      ? ft('link_pick_choose', 'Seç')
                      : '${_from!.code} · ${_from!.city ?? _from!.name}',
                  hint: _from?.name,
                  filled: _from != null,
                  onTap: () => _pickAirport(departure: true),
                ),
                const SizedBox(height: 8),
                FFieldRow(
                  icon: PhosphorIconsFill.airplaneLanding,
                  label: ft('link_pick_to', 'Haraya'),
                  value: _to == null
                      ? ft('link_pick_choose', 'Seç')
                      : '${_to!.code} · ${_to!.city ?? _to!.name}',
                  hint: _to?.name,
                  filled: _to != null,
                  onTap: () => _pickAirport(departure: false),
                ),
                const SizedBox(height: 8),
                FFieldRow(
                  icon: PhosphorIconsFill.calendarDot,
                  label: ft('link_pick_date', 'Tarix'),
                  value: fDateLong(_date),
                  hint: fWeekday(_date),
                  onTap: _pickDate,
                ),
              ],
            ),
            ..._list(),
          ],
        ),
      ],
      bottom: FPrimaryButton(
        label: ft('continue', 'Davam et'),
        icon: PhosphorIconsBold.arrowRight,
        onTap: _picked == null ? null : _continue,
      ),
    );
  }

  List<Widget> _list() {
    final d = fDark(context);
    if (!_ready) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.airplaneTilt,
          title: ft('link_pick_need_route', 'Marşrutu göstər'),
          message: ft(
            'link_pick_need_route_message',
            'Gediş və çatma limanını seç — həmin günün uçuşlarını gətirək.',
          ),
        ),
      ];
    }
    if (_loading) return const [FListSkeleton(rows: 4)];
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: () => _load(force: true))];
    }
    if (!_asked) return const [];
    if (_flights.isEmpty) {
      return [
        FEmptyResult(
          icon: PhosphorIconsFill.calendarX,
          title: ft('link_pick_empty', 'Bu gün üçün uçuş yoxdur'),
          message: ft(
            'link_pick_empty_message',
            'Başqa tarix seç — qalan günlərdə uçuş ola bilər.',
          ),
          actions: [
            FSecondaryButton(
              label: ft('link_pick_other_date', 'Başqa tarix'),
              icon: PhosphorIconsBold.calendarDot,
              onTap: _pickDate,
            ),
          ],
        ),
      ];
    }
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${fDateShort(_date)} · ${_from!.code} → ${_to!.code}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cText(d),
                    ),
                  ),
                ),
                FBadge(
                  ft('link_pick_count', '{n} UÇUŞ', {'n': '${_flights.length}'}),
                  fontSize: 9,
                ),
              ],
            ),
          ),
          for (var i = 0; i < _flights.length; i++) ...[
            if (i != 0) const SizedBox(height: 8),
            _flightRow(_flights[i]),
          ],
        ],
      ),
    ];
  }

  Widget _flightRow(FlightSummary flight) {
    final d = fDark(context);
    final visual = fStatusVisual(flight.status);
    final from = flight.departureLocal?.clock;
    final to = flight.arrivalLocal?.clock;
    final meta = [
      flight.airline?.name,
      flight.aircraftModel,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' · ');
    return FPickRow(
      selected: _picked?.key == flight.key && _picked?.number == flight.number,
      onTap: () => setState(() => _picked = flight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  flight.displayNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FBadge(
                (flight.statusLabel ?? visual.label).toUpperCase(),
                tone: visual.tone,
                fontSize: 9,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            from == null || to == null ? '—' : '$from → $to',
            style: TextStyle(
              fontSize: 12.5,
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
    );
  }

  Future<void> _pickAirport({required bool departure}) async {
    final picked = await FlightNav.push<AirportSummary>(
      context,
      const AirportListScreen(picker: true),
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (departure) {
        _from = picked;
      } else {
        _to = picked;
      }
      _picked = null;
    });
    _load();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      // Прошедшая дата у объявления не проходит валидацию: `after_or_equal:today`.
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _date = picked;
      _picked = null;
    });
    _load();
  }

  Future<void> _load({bool force = false}) async {
    if (!_ready) return;
    setState(() {
      _loading = true;
      _error = null;
      _asked = true;
    });
    try {
      final result = await _repo.routeFlights(
        _from!.code,
        _to!.code,
        fApiDate(_date),
        force: force,
      );
      if (!mounted) return;
      setState(() {
        _flights = _upcoming(result.data ?? const []);
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

  /// Улетевшие рейсы из списка выбора убираются: объявление с таким временем
  /// сервер отклонит (`DepartureNotPassed`).
  List<FlightSummary> _upcoming(List<FlightSummary> all) {
    final now = DateTime.now().toUtc();
    final list = all.where((flight) {
      final at = flight.departureAt;
      if (at == null) return true;
      return at.isAfter(now);
    }).toList();
    list.sort((a, b) {
      final x = a.departureLocal?.minutesOfDay ?? 0;
      final y = b.departureLocal?.minutesOfDay ?? 0;
      return x.compareTo(y);
    });
    return list;
  }

  Future<void> _continue() async {
    final flight = _picked;
    final from = _from;
    final to = _to;
    if (flight == null || from == null || to == null) return;
    await FlightNav.push(
      context,
      LinkAttachScreen(flight: flight, from: from, to: to),
    );
  }
}
