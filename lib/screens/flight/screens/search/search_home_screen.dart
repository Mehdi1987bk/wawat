import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/cache/cache_manager.dart';
import '../../../../main.dart';
import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_envelope.dart';
import '../../data/flight_error.dart';
import '../../data/flight_local_store.dart';
import '../../data/flight_repository.dart';
import '../../data/models/aircraft.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_watch.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../aircraft/aircraft_passport_screen.dart';
import '../airport/airport_card_screen.dart';
import '../airport/airport_list_screen.dart';
import '../flight/flight_card_screen.dart';
import '../flight/flight_instances_screen.dart';
import '../more/flight_health_screen.dart';
import '../watch/watch_center_screen.dart';
import '../watch/watch_route_new_screen.dart';
import 'search_empty_screen.dart';

/// `search/home` + `search/results` + `search/loading` + `search/throttled`
/// + `search/error` — один экран с состояниями.
///
/// Пока поле пустое, видны отслеживаемые рейсы и история поиска; как только
/// набрано два символа, то же место занимают результаты. Отдельных экранов
/// под «идёт загрузка» и «слишком часто» нет: это состояния того же списка —
/// иначе возврат «назад» уводил бы человека из поиска.
///
/// Три запроса (`/flights/search`, `/airports/search`, `/aircraft/search`)
/// уходят параллельно, не раньше двух символов и не чаще раза в 400 мс
/// (§4.4). Сбой одного не гасит два других: категории независимы.
///
/// Отличие от прототипа (§16): в найденной строке рейса нет маршрута,
/// авиакомпании и времени. `/flights/search` отдаёт **только строки
/// номеров**; маршрут и час требуют отдельного запроса `/flights/{number}/
/// {date}` на каждую строку, а минутный бюджет гостя — 15 запросов. Поэтому
/// запрос уходит по касанию, а не на каждую строку списка.
class SearchHomeScreen extends StatefulWidget {
  const SearchHomeScreen({super.key, this.autofocus = false});

  final bool autofocus;

  @override
  State<SearchHomeScreen> createState() => _SearchHomeScreenState();
}

class _SearchHomeScreenState extends State<SearchHomeScreen> {
  final _repo = FlightRepository.instance;
  final _store = FlightLocalStore.instance;
  final _controller = TextEditingController();

  Timer? _debounce;
  int _queryId = 0;

  String _query = '';
  bool _searching = false;

  List<String> _numbers = const [];
  List<AirportSummary> _airports = const [];
  List<FleetItem> _aircraft = const [];
  String? _stale;
  FlightError? _error;

  List<FlightWatch> _watches = const [];
  bool _signedIn = false;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
    _store.load();
    _loadWatches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _store.removeListener(_onStore);
    _controller.dispose();
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  /// Блок «İzlədiyim uçuşlar». Гостю запрос не отправляется вовсе: эндпоинт
  /// слежения единственный, который отвечает `401`.
  Future<void> _loadWatches() async {
    final token = await sl.get<CacheManager>().getToken();
    final signedIn = token != null && token.isNotEmpty;
    if (!mounted) return;
    setState(() => _signedIn = signedIn);
    if (!signedIn) return;
    try {
      final result = await _repo.watches();
      if (!mounted) return;
      setState(() => _watches = result.data ?? const []);
    } catch (_) {
      // Блок необязательный: без него экран поиска работает полностью.
    }
  }

  void _onQueryChanged(String raw) {
    final query = raw.trim();
    _debounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _query = query;
        _searching = false;
        _numbers = const [];
        _airports = const [];
        _aircraft = const [];
        _error = null;
        _stale = null;
      });
      return;
    }
    setState(() {
      _query = query;
      _searching = true;
      _error = null;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    final id = ++_queryId;
    final numbers = _repo.searchFlightNumbers(query, limit: 20).then<Object?>(
          (value) => value,
          onError: (Object error) => FlightError.from(error),
        );
    final airports = _repo.searchAirports(query, limit: 20).then<Object?>(
          (value) => value,
          onError: (Object error) => FlightError.from(error),
        );
    final aircraft = _repo.searchAircraft(query, limit: 20).then<Object?>(
          (value) => value,
          onError: (Object error) => FlightError.from(error),
        );
    final results = await Future.wait<Object?>([numbers, airports, aircraft]);
    if (!mounted || id != _queryId) return;

    FlightError? error;
    String? stale;
    var foundNumbers = const <String>[];
    var foundAirports = const <AirportSummary>[];
    var foundAircraft = const <FleetItem>[];

    for (final item in results) {
      if (item is FlightError) {
        // Хватит первой: показывать три одинаковых сообщения незачем.
        error ??= item;
        continue;
      }
      if (item is FlightEnvelope) {
        stale ??= fStaleLineText(item.meta);
        final data = item.data;
        if (data is List<String>) foundNumbers = data;
        if (data is List<AirportSummary>) foundAirports = data;
        if (data is List<FleetItem>) foundAircraft = data;
      }
    }

    setState(() {
      _numbers = foundNumbers;
      _airports = foundAirports;
      _aircraft = foundAircraft;
      _stale = stale;
      // Ошибка показывается только если не осталось ни одной категории:
      // один упавший запрос не должен прятать два удачных.
      _error = (foundNumbers.isEmpty &&
              foundAirports.isEmpty &&
              foundAircraft.isEmpty)
          ? error
          : null;
      _searching = false;
    });
  }

  int get _total => _numbers.length + _airports.length + _aircraft.length;

  int get _categories =>
      (_numbers.isEmpty ? 0 : 1) +
      (_airports.isEmpty ? 0 : 1) +
      (_aircraft.isEmpty ? 0 : 1);

  bool get _hasQuery => _query.length >= 2;

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('search_title', 'Axtarış'),
      section: FlightSection.search,
      stale: _hasQuery ? _stale : null,
      actions: [
        FSkyAction(
          icon: PhosphorIconsBold.bell,
          onTap: () => FlightNav.push(context, const WatchCenterScreen()),
        ),
      ],
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasQuery) ...[
              Text(
                ft('search_hero', 'Nə axtarırsan?'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ft(
                  'search_hero_message',
                  'Uçuş, təyyarə, hava limanı və ya marşrut — hamısı bir yerdə.',
                ),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: FT.onHero(.82),
                ),
              ),
              const SizedBox(height: 14),
            ],
            FHeroSearchField(
              controller: _controller,
              hint: ft('search_hint', 'J2 78 · 4K-AZ81 · GYD'),
              autofocus: widget.autofocus,
              uppercase: true,
              onChanged: _onQueryChanged,
              trailing: _hasQuery
                  ? InkWell(
                      onTap: () {
                        _controller.clear();
                        _onQueryChanged('');
                      },
                      child: Icon(
                        PhosphorIconsBold.xCircle,
                        size: 18,
                        color: FT.onHero(.8),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            if (_hasQuery)
              Text(
                _searching
                    ? ft('search_running', 'Axtarılır…')
                    : ft(
                        'search_found',
                        '{cats} kateqoriyada {n} nəticə',
                        {'cats': '$_categories', 'n': '$_total'},
                      ),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: FT.onHero(.78),
                ),
              )
            else
              _modes(),
          ],
        ),
      ),
      slivers: [FlightBody(children: _body())],
    );
  }

  /// Четыре подсказки прототипа. Это не фильтры поиска, а переходы: по полю
  /// ищутся все три категории сразу, а маршрут вообще ищется не поиском, а
  /// `GET /routes/{from}/{to}/{date}`.
  Widget _modes() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _mode(
            icon: PhosphorIconsFill.airplaneTilt,
            label: ft('search_mode_flight', 'Uçuş nömrəsi'),
            onTap: () => _controller.selection = TextSelection.collapsed(
              offset: _controller.text.length,
            ),
          ),
          const SizedBox(width: 6),
          _mode(
            icon: PhosphorIconsFill.airplane,
            label: ft('search_mode_aircraft', 'Təyyarə'),
            onTap: () => fToast(
              context,
              ft(
                'search_mode_aircraft_hint',
                'Qeydiyyat nişanını yaz: 4K-AZ81',
              ),
            ),
          ),
          const SizedBox(width: 6),
          _mode(
            icon: PhosphorIconsFill.buildings,
            label: ft('search_mode_airport', 'Hava limanı'),
            onTap: () =>
                FlightNav.push(context, const AirportListScreen()),
          ),
          const SizedBox(width: 6),
          _mode(
            icon: PhosphorIconsFill.path,
            label: ft('search_mode_route', 'Marşrut'),
            onTap: () =>
                FlightNav.push(context, const WatchRouteNewScreen()),
          ),
        ],
      ),
    );
  }

  Widget _mode({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .16),
          borderRadius: FT.rPill,
          border: Border.all(color: Colors.white.withValues(alpha: .2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body() {
    if (_hasQuery) return _results();
    return _start();
  }

  // ─────────────────────────── пустое поле ───────────────────────────

  List<Widget> _start() {
    final recents = _store.recents;
    return [
      if (_signedIn && _watches.isNotEmpty) _watchCard(),
      if (recents.isNotEmpty) _recentsCard(recents),
      if (recents.isEmpty)
        FInfoNote(
          ft(
            'search_history_note',
            'Axtarış tarixçəsi yalnız bu cihazda saxlanılır — serverə '
                'göndərilmir.',
          ),
        ),
      FBrandActionCard(
        icon: PhosphorIconsFill.bellRinging,
        title: ft('search_watch_card', 'İzlədiyim uçuşlar'),
        subtitle: _signedIn
            ? ft(
                'search_watch_card_hint',
                '{n} uçuş izlənir · bildirişlər açıqdır',
                {'n': '${_watches.length}'},
              )
            : ft(
                'search_watch_card_guest',
                'Daxil ol — uçuşun statusu özü gəlsin',
              ),
        onTap: () => FlightNav.push(context, const WatchCenterScreen()),
      ),
    ];
  }

  Widget _watchCard() {
    return FCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            ft('search_watched', 'İzlədiyim uçuşlar'),
            trailing: InkWell(
              onTap: () => FlightNav.push(context, const WatchCenterScreen()),
              child: Text(
                ft('all', 'Hamısı'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cBrandText(fDark(context)),
                ),
              ),
            ),
          ),
          for (final watch in _watches.take(4)) _watchRow(watch),
        ],
      ),
    );
  }

  Widget _watchRow(FlightWatch watch) {
    final d = fDark(context);
    final flight = watch.flight;
    final visual = fStatusVisual(flight?.status);
    return FListRow(
      flat: true,
      icon: visual.icon,
      iconBackground: visual.tone.bg(d),
      iconColor: visual.tone.fg(d),
      title: [
        flight?.displayNumber ?? '—',
        flight?.statusLabel ?? visual.label,
      ].join(' · '),
      subtitle: _watchLine(watch),
      onTap: () => _openWatch(watch),
    );
  }

  String? _watchLine(FlightWatch watch) {
    final flight = watch.flight;
    if (flight == null) return null;
    final route = [flight.departureCode, flight.arrivalCode]
        .whereType<String>()
        .join(' → ');
    final day = fDayWord(flight.flightDate);
    return route.isEmpty ? day : '$route · $day';
  }

  void _openWatch(FlightWatch watch) {
    final flight = watch.flight;
    if (flight == null) return;
    FlightNav.push(
      context,
      FlightCardScreen(
        flightKey: FlightKey(
          number: flight.number,
          flightDate: flight.flightDate ?? fApiDate(DateTime.now()),
          departureCode: flight.departureCode,
        ),
      ),
    );
  }

  Widget _recentsCard(List<FlightRecent> recents) {
    return FCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            ft('search_recents', 'Son axtarışlar'),
            trailing: InkWell(
              onTap: () => _store.clearRecents(),
              child: Text(
                ft('clear', 'Təmizlə'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cText3(fDark(context)),
                ),
              ),
            ),
          ),
          for (final recent in recents.take(8))
            FListRow(
              flat: true,
              icon: _recentIcon(recent.kind),
              title: recent.title,
              subtitle: recent.subtitle,
              onTap: () => _openRecent(recent),
            ),
        ],
      ),
    );
  }

  IconData _recentIcon(FlightRecentKind kind) => switch (kind) {
        FlightRecentKind.flight => PhosphorIconsFill.airplaneTilt,
        FlightRecentKind.airport => PhosphorIconsFill.buildings,
        FlightRecentKind.aircraft => PhosphorIconsFill.airplane,
        FlightRecentKind.route => PhosphorIconsFill.path,
      };

  void _openRecent(FlightRecent recent) {
    switch (recent.kind) {
      case FlightRecentKind.flight:
        if (recent.date != null) {
          FlightNav.push(
            context,
            FlightCardScreen(
              flightKey: FlightKey(
                number: recent.value,
                flightDate: recent.date!,
              ),
            ),
          );
        } else {
          _openNumber(recent.value);
        }
      case FlightRecentKind.airport:
        FlightNav.push(context, AirportCardScreen(code: recent.value));
      case FlightRecentKind.aircraft:
        FlightNav.push(
          context,
          AircraftPassportScreen(registration: recent.value),
        );
      case FlightRecentKind.route:
        FlightNav.push(context, const WatchRouteNewScreen());
    }
  }

  // ──────────────────────────── результаты ────────────────────────────

  List<Widget> _results() {
    if (_searching && _total == 0) return const [FListSkeleton(rows: 5)];
    if (_error != null) {
      return [
        FErrorView(
          error: _error!,
          onRetry: () => _search(_query),
          onBack: () {
            _controller.clear();
            _onQueryChanged('');
          },
          onFeeds: () =>
              FlightNav.push(context, const FlightHealthScreen()),
        ),
      ];
    }
    if (_total == 0) {
      return [
        FEmptyResult(
          title: ft('search_none', 'Nəticə yoxdur'),
          message: ft(
            'search_none_message',
            'Uçuş nömrəsini boşluqsuz yaz (J278), limanı IATA kodu ilə '
                '(GYD), təyyarəni qeydiyyat nişanı ilə (4K-AZ81).',
          ),
          actions: [
            FSecondaryButton(
              label: ft('search_mode_route', 'Marşrut'),
              icon: PhosphorIconsBold.path,
              onTap: () =>
                  FlightNav.push(context, const WatchRouteNewScreen()),
            ),
          ],
        ),
      ];
    }
    return [
      if (_airports.isNotEmpty)
        _group(
          title: ft('search_group_airports', 'Hava limanları'),
          count: _airports.length,
          children: [
            for (final airport in _airports)
              FListRow(
                flat: true,
                icon: PhosphorIconsFill.buildings,
                title: '${airport.code} — '
                    '${airport.name ?? airport.fullName ?? airport.code}',
                subtitle: [
                  airport.icao,
                  airport.city,
                  airport.country,
                ].whereType<String>().join(' · '),
                trailing: FBadge(
                  ft('search_badge_airport', 'Liman'),
                  fontSize: 9.5,
                ),
                showCaret: false,
                onTap: () => _openAirport(airport),
              ),
          ],
        ),
      if (_numbers.isNotEmpty)
        _group(
          title: ft('search_group_flights', 'Uçuşlar'),
          count: _numbers.length,
          children: [
            for (final number in _numbers)
              FListRow(
                flat: true,
                icon: PhosphorIconsFill.airplaneTilt,
                title: number.toUpperCase(),
                subtitle: ft(
                  'search_flight_hint',
                  'Toxun — bu günün uçuşlarını gətirsin',
                ),
                trailing: FBadge(
                  ft('search_badge_flight', 'Uçuş'),
                  fontSize: 9.5,
                ),
                showCaret: false,
                onTap: () => _openNumber(number),
              ),
          ],
        ),
      if (_aircraft.isNotEmpty)
        _group(
          title: ft('search_group_aircraft', 'Təyyarələr'),
          count: _aircraft.length,
          children: [
            for (final item in _aircraft)
              FListRow(
                flat: true,
                icon: PhosphorIconsFill.airplane,
                title: item.reg ?? '—',
                subtitle: [
                  item.model ?? item.typeName,
                  item.airlineName,
                ].whereType<String>().join(' · '),
                trailing: FBadge(
                  ft('search_badge_aircraft', 'Təyyarə'),
                  fontSize: 9.5,
                ),
                showCaret: false,
                onTap: () => _openAircraft(item),
              ),
          ],
        ),
    ];
  }

  Widget _group({
    required String title,
    required int count,
    required List<Widget> children,
  }) {
    return FCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            title,
            trailing: FBadge('$count', fontSize: 10),
          ),
          ...children,
        ],
      ),
    );
  }

  void _openAirport(AirportSummary airport) {
    _store.addRecent(
      FlightRecent(
        kind: FlightRecentKind.airport,
        value: airport.code,
        title: '${airport.code} — ${airport.name ?? airport.code}',
        subtitle: [airport.city, airport.country]
            .whereType<String>()
            .join(', '),
      ),
    );
    FlightNav.push(context, AirportCardScreen(code: airport.code));
  }

  void _openAircraft(FleetItem item) {
    final reg = item.reg;
    if (reg == null) return;
    _store.addRecent(
      FlightRecent(
        kind: FlightRecentKind.aircraft,
        value: reg,
        title: reg,
        subtitle: [item.model ?? item.typeName, item.airlineName]
            .whereType<String>()
            .join(' · '),
      ),
    );
    FlightNav.push(context, AircraftPassportScreen(registration: reg));
  }

  /// Один номер — это ещё не рейс (§4.1): у одного номера за день может быть
  /// два плеча. Поэтому по касанию уходит `/flights/{number}/{date}`, и
  /// дальше развилка: один рейс — карточка, несколько — выбор плеча, ноль —
  /// экран «такого рейса в этот день нет».
  Future<void> _openNumber(String number) async {
    if (_opening) return;
    setState(() => _opening = true);
    final date = fApiDate(DateTime.now());
    try {
      final result = await _repo.flights(number, date);
      if (!mounted) return;
      final flights = result.data ?? const <FlightSummary>[];
      // В ответе поиска `display_number` нет — приходят только сжатые
      // строки вроде «TK333». Где ставить пробел, знает лишь справочник
      // авиакомпаний (J2, 4U, 2B — код бывает из буквы и цифры), поэтому
      // красивую форму берём из первого же найденного рейса.
      final display = flights.isEmpty
          ? number.toUpperCase()
          : flights.first.displayNumber;
      _store.addRecent(
        FlightRecent(
          kind: FlightRecentKind.flight,
          value: number,
          title: display,
          subtitle: flights.isEmpty
              ? ft('search_none', 'Nəticə yoxdur')
              : flights
                  .map((f) => [f.departureCode, f.arrivalCode]
                      .whereType<String>()
                      .join(' → '))
                  .where((line) => line.isNotEmpty)
                  .join(', '),
        ),
      );
      if (flights.isEmpty) {
        // Второй запрос отличает «нет такого номера» от «не та дата».
        final dates = await _datesOf(number);
        if (!mounted) return;
        FlightNav.push(
          context,
          SearchEmptyScreen(
            number: number,
            displayNumber: display,
            date: date,
            dates: dates,
          ),
        );
        return;
      }
      if (flights.length == 1) {
        final flight = flights.first;
        FlightNav.push(
          context,
          FlightCardScreen(
            flightKey: FlightKey(
              number: flight.number,
              flightDate: flight.flightDate ?? date,
              departureCode: flight.departureCode,
            ),
          ),
        );
        return;
      }
      FlightNav.push(
        context,
        FlightInstancesScreen(
          number: number,
          date: date,
          displayNumber: display,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final error = FlightError.from(e);
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  /// `null` — второй запрос не прошёл: тогда утверждать, что номера не
  /// существует, оснований нет.
  Future<List<String>?> _datesOf(String number) async {
    try {
      final result = await _repo.flightDates(number);
      return result.data ?? const [];
    } catch (_) {
      return null;
    }
  }
}
