import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_envelope.dart';
import '../../data/flight_error.dart';
import '../../data/flight_location.dart';
import '../../data/flight_map_prefs.dart';
import '../../data/flight_radar.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_map.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../airport/airport_feeds_screen.dart';
import '../flight/flight_card_screen.dart';
import '../watch/watch_center_screen.dart';
import 'map_filters_screen.dart';
import 'map_layers_screen.dart';

/// `map/radar` и `map/radar-estimated` — отслеживаемые рейсы на карте.
///
/// Один экран на две страницы прототипа: отличие только в том, какие рейсы
/// в списке и какая подпись сверху. Запроса «все самолёты в районе» в нашем
/// API нет (§9.2), поэтому радар строится из подписок и отмеченных рейсов, а
/// позицию по каждому даёт `/detail`.
///
/// Чего здесь нет и не должно быть: опроса по таймеру. Подписанный рейс
/// сервер обновляет сам и присылает push (§4.4) — запрос уходит один раз на
/// вход, повторный вход в пределах 30 секунд берёт прошлый ответ.
///
/// Замеренная правда (§5): в бакинском трафике `location` не приходит ни у
/// одного рейса. Поэтому «мövqeli» почти всегда ноль, метка ставится по доле
/// пути, и это нормальная работа экрана, а не пустое состояние.
class MapRadarScreen extends StatefulWidget {
  const MapRadarScreen({
    super.key,
    this.estimatedOnly = false,
    this.focus,
  });

  /// Страница `map/radar-estimated`: в списке только рейсы без позиции.
  final bool estimatedOnly;

  /// Какой рейс показать в центре — переход с карточки рейса «Tam ekran».
  final FlightKey? focus;

  @override
  State<MapRadarScreen> createState() => _MapRadarScreenState();
}

class _MapRadarScreenState extends State<MapRadarScreen> {
  final _prefs = FlightMapPrefs.instance;
  final _map = MapController();

  FlightRadarData _data = const FlightRadarData();
  FlightError? _error;
  bool _loading = true;
  bool _locating = false;

  /// Центр и масштаб задаёт экран, как только человек тронул карту или
  /// нажал «к моему месту» — после этого автоподгонка под точки мешает.
  bool _cameraTaken = false;

  @override
  void initState() {
    super.initState();
    _prefs.addListener(_onPrefs);
    _prefs.load();
    _load();
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPrefs);
    _map.dispose();
    super.dispose();
  }

  void _onPrefs() {
    if (mounted) setState(() {});
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await FlightRadar.load(force: force);
      if (!mounted) return;
      setState(() {
        _data = data;
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

  // ─────────────────────────── Что на экране ───────────────────────────

  /// Рейсы после фильтров. На странице «təxmini» остаются только те, у кого
  /// позиции нет, — именно про них там и написано.
  List<RadarFlight> get _flights {
    final filtered = fRadarFiltered(_data.flights, _prefs);
    if (!widget.estimatedOnly) return filtered;
    return filtered.where((flight) => !flight.hasPosition).toList();
  }

  @override
  Widget build(BuildContext context) {
    final flights = _flights;
    return FlightScaffold(
      title: widget.estimatedOnly
          ? ft('radar_estimated_title', 'Təxmini radar')
          : ft('radar_title', 'Radar'),
      section: widget.estimatedOnly ? null : FlightSection.map,
      actions: [
        FSkyAction(
          icon: PhosphorIconsBold.funnel,
          active: _prefs.filtered,
          onTap: () => FlightNav.push(
            context,
            MapFiltersScreen(flights: _data.flights),
          ),
        ),
      ],
      stale: fStaleLineText(_data.meta ?? FlightMeta.empty),
      slivers: [
        FlightBody(children: _body(flights)),
      ],
    );
  }

  List<Widget> _body(List<RadarFlight> flights) {
    if (_loading) {
      return const [FCardSkeleton(rows: 2), FListSkeleton(rows: 3)];
    }
    final error = _error;
    if (error != null) {
      return [
        FErrorView(
          error: error,
          onRetry: () => _load(force: true),
          onFeeds: _openFeeds,
          onSignIn: () => FlightNav.push(context, const WatchCenterScreen()),
        ),
      ];
    }
    if (_data.flights.isEmpty) return [_empty()];

    return [
      if (widget.estimatedOnly) _estimatedNote(),
      _mapBlock(flights),
      if (_data.withoutDetail > 0)
        FInfoNote(
          ft(
            'radar_capped',
            'Xəritədə ilk {n} uçuş göstərilir — qalanları siyahıda '
                'mövqesiz qalır, sorğu büdcəsi bir dəfəyə bu qədərdir.',
            {'n': '${FlightRadar.maxDetails}'},
          ),
        ),
      _list(flights),
      if (!widget.estimatedOnly && _data.estimated > 0)
        FInfoNote(
          ft(
            'radar_estimated_note',
            'Mövqe gəlməyən uçuşların nişanı cədvəl vaxtına görə qövs '
                'üzərində qoyulur — bu nasazlıq deyil.',
          ),
        ),
    ];
  }

  Widget _empty() {
    final signedIn = _data.signedIn;
    return FStateBlock(
      icon: PhosphorIconsFill.airplaneTilt,
      title: signedIn
          ? ft('radar_empty', 'Radarda hələ uçuş yoxdur')
          : ft('radar_empty_guest', 'Radar izlənən uçuşlardan qurulur'),
      message: signedIn
          ? ft(
              'radar_empty_message',
              'Xəritə izlədiyin və işarələdiyin uçuşlardan qurulur. Bir '
                  'uçuşu izləməyə başla — nişanı burada görünəcək.',
            )
          : ft(
              'radar_empty_guest_message',
              'Giriş etsən, izlədiyin uçuşlar xəritədə görünəcək. Girişsiz '
                  'yalnız bu telefonda işarələnmiş uçuşlar düşür.',
            ),
      actions: [
        FSecondaryButton(
          label: ft('radar_to_watch', 'İzləməyə keç'),
          icon: PhosphorIconsBold.bellRinging,
          onTap: () => FlightNav.push(context, const WatchCenterScreen()),
        ),
      ],
    );
  }

  Widget _estimatedNote() => FNoticeCard(
        icon: PhosphorIconsFill.path,
        title: ft('radar_estimated_strip', 'Mövqe gəlmir'),
        message: ft(
          'radar_estimated_strip_message',
          'Bu uçuşlar üçün təyyarə mövqeyi gəlmir — yerləşmə cədvəl vaxtına '
              'görə hesablanır.',
        ),
        tone: FTone.info,
      );

  // ───────────────────────────── Карта ─────────────────────────────

  Widget _mapBlock(List<RadarFlight> flights) {
    final d = fDark(context);
    final routes = <FMapRoute>[];
    final planes = <FMapPlane>[];
    final airports = <String, FMapAirport>{};

    for (final flight in flights) {
      final from = flight.detail?.departure.airport;
      final to = flight.detail?.arrival.airport;
      List<LatLng> arc = const [];
      if (from != null && to != null && from.hasPosition && to.hasPosition) {
        arc = fGreatCircle(
          LatLng(from.lat!, from.lon!),
          LatLng(to.lat!, to.lon!),
        );
      }
      final done = fRouteDone(arc, flight.progress);
      if (_prefs.showRoutes && arc.length > 1) {
        routes.add(FMapRoute(all: arc, done: done));
      }
      for (final airport in [from, to]) {
        if (airport == null || !airport.hasPosition) continue;
        final code = airport.code;
        airports.putIfAbsent(
          code ?? '${airport.lat},${airport.lon}',
          () => FMapAirport(
            point: LatLng(airport.lat!, airport.lon!),
            code: code,
            onTap: code == null ? null : () => _openAirport(airport),
          ),
        );
      }

      final location = flight.location;
      final live = flight.hasPosition;
      // Позиции нет — метка ставится на дуге по доле пути. Нет и доли пути
      // (рейс закончился или нет расписания) — метки нет вовсе, остаётся дуга.
      final point = live
          ? LatLng(location!.lat!, location.lon!)
          : (done.isEmpty ? null : done.last);
      if (point != null && !flight.isCanceled) {
        planes.add(FMapPlane(
          point: point,
          track: live ? location!.trueTrack : null,
          label: flight.displayNumber,
          live: live,
          onTap: () => _openFlight(flight),
        ));
      }
    }

    final focus = widget.focus;
    final focused = focus == null
        ? null
        : flights.where((flight) => flight.key == focus).firstOrNull;
    final center = focused == null
        ? null
        : planes
            .where((plane) => plane.label == focused.displayNumber)
            .firstOrNull
            ?.point;

    return FMapFrame(
      height: 340,
      map: FFlightMap(
        controller: _map,
        routes: routes,
        planes: planes,
        airports: airports.values.toList(growable: false),
        rings: _prefs.showRing
            ? const [FMapRing(point: LatLng(40.41, 49.87), radiusKm: 400)]
            : const [],
        tiles: _prefs.tiles,
        labels: _prefs.showAirports,
        interactive: true,
        center: center,
        zoom: center == null ? 4 : 6,
        fitPoints: !_cameraTaken && center == null,
        minZoom: 2,
        maxZoom: 11,
      ),
      corners: [
        Positioned(
          right: 10,
          top: 10,
          child: Column(
            children: [
              _round(PhosphorIconsBold.plus, () => _zoom(1)),
              const SizedBox(height: 6),
              _round(PhosphorIconsBold.minus, () => _zoom(-1)),
              const SizedBox(height: 6),
              _round(
                PhosphorIconsBold.crosshair,
                _locate,
                busy: _locating,
              ),
              const SizedBox(height: 6),
              _round(
                PhosphorIconsBold.stack,
                () => FlightNav.push(context, const MapLayersScreen()),
              ),
            ],
          ),
        ),
        Positioned(
          left: 10,
          bottom: 9,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FBadge(
                ft('radar_watched_badge', '{n} uçuş izlənir', {
                  'n': '${_data.total}',
                }),
                icon: PhosphorIconsFill.airplaneTilt,
              ),
              if (_data.estimated > 0)
                FBadge(
                  ft('radar_estimated_badge', '{n} mövqe təxmini', {
                    'n': '${_data.estimated}',
                  }),
                  icon: PhosphorIconsFill.path,
                  background: widget.estimatedOnly ? FT.brand50(d) : null,
                  foreground: widget.estimatedOnly ? FT.brand600(d) : null,
                  onTap: widget.estimatedOnly
                      ? null
                      : () => FlightNav.push(
                            context,
                            const MapRadarScreen(estimatedOnly: true),
                          ),
                ),
              if (widget.estimatedOnly)
                FBadge(
                  ft('radar_feeds', 'Mənbələr'),
                  icon: PhosphorIconsFill.pulse,
                  onTap: _openFeeds,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _round(IconData icon, VoidCallback onTap, {bool busy = false}) {
    final d = fDark(context);
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: FT.rPill,
      child: Container(
        height: 32,
        width: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cCard(d),
          shape: BoxShape.circle,
          border: Border.all(color: cLine(d)),
          boxShadow: FT.cardShadow(d),
        ),
        child: busy
            ? SizedBox(
                height: 13,
                width: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  valueColor: AlwaysStoppedAnimation(cText3(d)),
                ),
              )
            : Icon(icon, size: 15, color: cText2(d)),
      ),
    );
  }

  void _zoom(double delta) {
    final camera = _map.camera;
    final next = (camera.zoom + delta).clamp(2.0, 11.0);
    _cameraTaken = true;
    _map.move(camera.center, next);
  }

  /// «Mövqeyimə gətirildi» — камера к телефону. Своей позиции в ответах нет,
  /// она берётся у телефона и никуда не отправляется.
  Future<void> _locate() async {
    setState(() => _locating = true);
    final place = await FlightGeo.current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (!place.hasPlace) {
      fToast(context, _placeProblem(place.problem));
      return;
    }
    _cameraTaken = true;
    _map.move(LatLng(place.lat!, place.lon!), 6);
  }

  String _placeProblem(FlightPlaceProblem? problem) => switch (problem) {
        FlightPlaceProblem.serviceOff => ft(
            'nearby_service_off',
            'Telefonda mövqe xidməti sönülüdür. Ayarlarda aç və yenidən sına.',
          ),
        FlightPlaceProblem.blocked => ft(
            'nearby_blocked',
            'Mövqe icazəsi bağlıdır. Ayarlar → icazələr bölməsindən aça '
                'bilərsən.',
          ),
        FlightPlaceProblem.denied => ft(
            'radar_locate_denied',
            'İcazə verilmədi. Xəritəni mövqeyinə gətirmək üçün mövqe lazımdır.',
          ),
        _ => ft(
            'nearby_no_fix',
            'Mövqe tapılmadı. Açıq havada və ya pəncərə yanında yenidən sına.',
          ),
      };

  // ───────────────────────────── Список ─────────────────────────────

  Widget _list(List<RadarFlight> flights) {
    final d = fDark(context);
    if (flights.isEmpty) {
      return FNoticeCard(
        icon: PhosphorIconsFill.funnel,
        title: widget.estimatedOnly
            ? ft('radar_all_positioned', 'Mövqesiz uçuş qalmadı')
            : ft('radar_filter_empty', 'Süzgəc heç nə saxlamadı'),
        message: widget.estimatedOnly
            ? ft(
                'radar_all_positioned_message',
                'Bu anda izlənən uçuşların hamısında mövqe var.',
              )
            : ft(
                'radar_filter_empty_message',
                'Seçilmiş şərtlərə uyğun uçuş yoxdur. Süzgəci sıfırla — '
                    '{n} uçuş yenə görünəcək.',
                {'n': '${_data.total}'},
              ),
        onTap: widget.estimatedOnly ? null : _prefs.resetFilters,
      );
    }

    return FCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            widget.estimatedOnly
                ? ft('radar_list_estimated', 'Mövqesi gəlməyən uçuşlar')
                : ft('radar_list', 'İzlənən uçuşlar'),
            trailing: FBadge(
              widget.estimatedOnly
                  ? '${flights.length}'
                  : ft('radar_counts', '{n} izlənir · {m} mövqeli', {
                      'n': '${_data.total}',
                      'm': '${_data.positioned}',
                    }),
              fontSize: 10,
            ),
          ),
          if (!widget.estimatedOnly) ...[
            const SizedBox(height: 10),
            _quickChips(),
          ],
          const SizedBox(height: 4),
          for (var i = 0; i < flights.length; i++)
            _row(flights[i], last: i == flights.length - 1, dark: d),
        ],
      ),
    );
  }

  /// Быстрые чипы — те же настройки, что на экране фильтров, просто под
  /// рукой. Второго механизма фильтрации здесь нет.
  Widget _quickChips() {
    final d = fDark(context);
    final airlines = fRadarAirlines(_data.flights);
    final first = airlines.isEmpty ? null : airlines.first;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _chip(
          label: ft('filters_which_all', 'Hamısı'),
          selected: !_prefs.filtered,
          icon: PhosphorIconsFill.check,
          onTap: _prefs.resetFilters,
          dark: d,
        ),
        _chip(
          label: ft('filters_which_ours', 'Bizim marşrutlar'),
          selected: _prefs.scope == FMapScope.ourRoutes,
          onTap: () => _prefs.setScope(
            _prefs.scope == FMapScope.ourRoutes
                ? FMapScope.all
                : FMapScope.ourRoutes,
          ),
          dark: d,
        ),
        if (first != null)
          _chip(
            label: first.name,
            selected: _prefs.airline == first.key,
            onTap: () => _prefs.setAirline(
              _prefs.airline == first.key ? null : first.key,
            ),
            dark: d,
          ),
        _chip(
          label: ft('radar_chip_position', 'Mövqesi var'),
          selected: _prefs.positionOnly,
          onTap: () => _prefs.setPositionOnly(!_prefs.positionOnly),
          dark: d,
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool dark,
    IconData? icon,
  }) =>
      FBadge(
        label,
        fontSize: 11,
        icon: selected ? (icon ?? PhosphorIconsFill.check) : null,
        background: selected ? FT.brand : FT.chip(dark),
        foreground: selected ? Colors.white : cText2(dark),
        onTap: onTap,
      );

  Widget _row(RadarFlight flight, {required bool last, required bool dark}) {
    final visual = fStatusVisual(flight.status);
    final live = flight.hasPosition;
    final parts = <String>[
      if (flight.departureCode != null && flight.arrivalCode != null)
        '${flight.departureCode} → ${flight.arrivalCode}',
      if (flight.progress != null)
        ft('radar_progress', '{n}% keçilib', {
          'n': '${flight.progress!.round()}',
        }),
      if (live && flight.altitudeM != null) fMeters(flight.altitudeM),
      if (live && flight.speedKmh != null) fSpeed(flight.speedKmh),
      if (!live) ft('radar_position_estimated', 'mövqe təxminidir'),
    ];

    return FFlightRow(
      number: flight.displayNumber,
      statusLabel: flight.statusLabel ?? visual.label,
      statusTone: visual.tone,
      meta: parts.join(' · '),
      trailing: Icon(
        live ? PhosphorIconsFill.airplaneTilt : PhosphorIconsFill.path,
        size: 15,
        color: live ? FT.brand600(dark) : cMuted(dark),
      ),
      onTap: () => _openFlight(flight),
    );
  }

  // ───────────────────────────── Переходы ─────────────────────────────

  void _openFlight(RadarFlight flight) => FlightNav.push(
        context,
        FlightCardScreen(flightKey: flight.key),
      );

  void _openAirport(AirportRef airport) {
    final code = airport.code;
    if (code == null) return;
    FlightNav.push(context, AirportFeedsScreen(code: code));
  }

  /// «Mənbələr» — какой поток работает. Код берётся у первого рейса списка:
  /// отдельного «общего» экрана потоков у аэропортов нет, он всегда про
  /// конкретный аэропорт.
  void _openFeeds() {
    final code = _flights
        .map((flight) => flight.departureCode ?? flight.arrivalCode)
        .whereType<String>()
        .firstOrNull;
    if (code == null) {
      fToast(
        context,
        ft('radar_feeds_unknown', 'Hansı limanın mənbəyi — hələ bilinmir.'),
      );
      return;
    }
    FlightNav.push(context, AirportFeedsScreen(code: code));
  }
}
