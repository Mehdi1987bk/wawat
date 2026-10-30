import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_auth.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../airport/airport_list_screen.dart';
import 'watch_center_screen.dart';
import 'watch_new_screen.dart';
import 'watch_signin_screen.dart';

/// `watch/new-route` — взять рейс под слежение, не зная номера.
///
/// Города и дата → `GET /routes/{from}/{to}/{date}` → человек выбирает рейс →
/// `POST /flights/{number}/{date}/watch` с кодом вылета выбранного рейса.
///
/// `events` здесь не передаётся: на этом экране тумблеров нет, а без ключа
/// сервер включает семь событий по умолчанию. Терминал и баггажную лен­ту
/// можно добавить потом на карточке подписки.
class WatchRouteNewScreen extends StatefulWidget {
  const WatchRouteNewScreen({super.key});

  @override
  State<WatchRouteNewScreen> createState() => _WatchRouteNewScreenState();
}

class _WatchRouteNewScreenState extends State<WatchRouteNewScreen> {
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
  bool _saving = false;
  bool _signedIn = true;

  bool get _ready => _from != null && _to != null;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final signedIn = await FlightAuth.signedIn();
    if (!mounted) return;
    setState(() => _signedIn = signedIn);
  }

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('watch_new_title', 'Uçuş izləməyə al'),
      stale: _stale,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FSegment(
              onHero: true,
              index: 1,
              items: [
                ft('watch_by_number', 'Uçuş nömrəsi'),
                ft('watch_by_route', 'Marşrut'),
              ],
              onChanged: (value) {
                if (value == 1) return;
                FlightNav.replace(context, const WatchNewScreen());
              },
            ),
            const SizedBox(height: 14),
            FEqualRow(
              children: [
                Expanded(
                  child: FHeroPickField(
                    label: ft('watch_route_from', 'Haradan'),
                    value: _from?.code ?? '—',
                    hint: _from?.city ?? _from?.name,
                    onTap: () => _pickAirport(departure: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    PhosphorIconsBold.arrowRight,
                    size: 15,
                    color: FT.onHero(.7),
                  ),
                ),
                Expanded(
                  child: FHeroPickField(
                    label: ft('watch_route_to', 'Haraya'),
                    value: _to?.code ?? '—',
                    hint: _to?.city ?? _to?.name,
                    onTap: () => _pickAirport(departure: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: FT.rSoft,
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsBold.calendarDot,
                      size: 14,
                      color: FT.onHero(.72),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ft('watch_route_date', 'Tarix: {date}, {weekday}', {
                          'date': fDateLong(_date),
                          'weekday': fWeekday(_date),
                        }),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FT.onHero(.82),
                        ),
                      ),
                    ),
                    Icon(
                      PhosphorIconsBold.caretDown,
                      size: 12,
                      color: FT.onHero(.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(gap: 12, children: _body()),
      ],
      bottom: _flights.isEmpty
          ? null
          : FPrimaryButton(
              label: ft('watch_route_save', 'Seçilmiş uçuşu izləməyə al'),
              icon: PhosphorIconsBold.check,
              loading: _saving,
              onTap: _picked == null ? null : _save,
            ),
    );
  }

  List<Widget> _body() {
    final d = fDark(context);
    if (!_ready) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.path,
          title: ft('watch_route_need', 'Marşrutu göstər'),
          message: ft(
            'watch_route_need_message',
            'Gediş və çatma limanını seç — həmin günün uçuşlarını gətirək.',
          ),
        ),
        _tipCard(),
      ];
    }
    if (_loading) return const [FListSkeleton(rows: 4)];
    if (_error != null) {
      return [
        FErrorView(
          error: _error!,
          onRetry: () => _load(force: true),
          onSignIn: () => FlightAuth.present(context, onDone: _checkAuth),
        ),
        _tipCard(),
      ];
    }
    if (!_asked) return [_tipCard()];
    if (_flights.isEmpty) {
      return [
        FEmptyResult(
          icon: PhosphorIconsFill.calendarX,
          title: ft('watch_route_empty', 'Bu gün üçün uçuş yoxdur'),
          message: ft(
            'watch_route_empty_message',
            'Başqa tarix seç — qalan günlərdə uçuş ola bilər.',
          ),
          actions: [
            FSecondaryButton(
              label: ft('other_date', 'Başqa tarix'),
              icon: PhosphorIconsBold.calendarDot,
              onTap: _pickDate,
            ),
          ],
        ),
        _tipCard(),
      ];
    }
    return [
      Text(
        ft('watch_route_count', 'O gün bu marşrutda {n} uçuş var', {
          'n': '${_flights.length}',
        }),
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: cText(d),
        ),
      ),
      Column(
        children: [
          for (var i = 0; i < _flights.length; i++) ...[
            if (i != 0) const SizedBox(height: 8),
            _flightRow(_flights[i]),
          ],
        ],
      ),
      if (!_signedIn)
        FGhostButton(
          label: ft('watch_signin_hint', 'Hesaba daxil olmamısan? Daxil ol'),
          onTap: () => FlightNav.push(
            context,
            WatchSignInScreen(onSignedIn: _checkAuth),
          ),
        ),
      _tipCard(),
    ];
  }

  Widget _tipCard() => FInfoNote(
        ft(
          'watch_route_tip',
          'Uçuş nömrəsini bilmirsənsə bu yol daha rahatdır — marşrut və tarix '
              'seçirsən, uçuşu siyahıdan tapırsan.',
        ),
        icon: PhosphorIconsBold.lightbulb,
      );

  Widget _flightRow(FlightSummary flight) {
    final d = fDark(context);
    final from = flight.departureLocal?.clock;
    final to = flight.arrivalLocal?.clock;
    final duration = _duration(flight);
    final line = [
      if (from != null && to != null) '$from → $to',
      if (duration != null) duration,
    ].join(' · ');
    final title = [
      flight.displayNumber,
      if (flight.airline?.name != null) flight.airline!.name!,
    ].join(' · ');
    return FPickRow(
      selected: _isPicked(flight),
      onTap: () => setState(() => _picked = flight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: cText(d),
            ),
          ),
          if (line.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: cText3(d),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// «2 s 25 dəq» — считается по разнице времён, своего поля у ответа нет.
  String? _duration(FlightSummary flight) {
    final from = flight.departureAt;
    final to = flight.arrivalAt;
    if (from == null || to == null) return null;
    final minutes = to.difference(from).inMinutes;
    if (minutes <= 0) return null;
    return fMinutesLong(minutes);
  }

  bool _isPicked(FlightSummary flight) {
    final picked = _picked;
    if (picked == null) return false;
    return picked.number == flight.number &&
        picked.departureCode == flight.departureCode &&
        picked.departureLocal?.clock == flight.departureLocal?.clock;
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
      firstDate: now.subtract(const Duration(days: 2)),
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
      _asked = true;
      _error = null;
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
        _flights = result.data ?? const [];
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

  Future<void> _save() async {
    final flight = _picked;
    if (flight == null) return;
    if (!await FlightAuth.signedIn()) {
      if (!mounted) return;
      FlightAuth.present(context, onDone: () {
        _checkAuth();
        _save();
      });
      return;
    }
    setState(() => _saving = true);
    try {
      // Рейс — это тройка «номер + дата + код вылета» (§4.1): код берётся у
      // выбранного рейса, иначе сервер подписал бы на другое плечо дня.
      await _repo.watch(
        FlightKey(
          number: flight.number,
          flightDate: flight.flightDate ?? fApiDate(_date),
          departureCode: flight.departureCode ?? _from?.code,
        ),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      fToast(context, ft('watch_saved', 'İzləməyə alındı'));
      FlightNav.replace(context, const WatchCenterScreen());
    } catch (e) {
      if (!mounted) return;
      final error = FlightError.from(e);
      setState(() => _saving = false);
      if (error.isUnauthenticated) {
        FlightAuth.present(context, onDone: _checkAuth);
        return;
      }
      fToast(
        context,
        error.display(ft('watch_save_failed', 'İzləmə qurulmadı')),
      );
    }
  }
}
