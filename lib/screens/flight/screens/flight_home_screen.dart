import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/cache/cache_manager.dart';
import '../../../main.dart';
import '../../../presentation/resourses/theme_colors.dart';
import '../../home/tabs/home_tab/widget/auth_modal_utils.dart';
import '../data/flight_error.dart';
import '../data/flight_notifications.dart';
import '../data/flight_repository.dart';
import '../data/models/flight.dart';
import '../data/models/flight_enums.dart';
import '../data/models/flight_watch.dart';
import '../flight_routes.dart';
import '../flight_shell.dart';
import '../flight_text.dart';
import '../ui/flight_states.dart';
import '../ui/flight_status_visual.dart';
import '../ui/flight_tokens.dart';
import '../ui/flight_widgets.dart';
import 'airport/airport_list_screen.dart';
import 'flight/flight_card_screen.dart';
import 'link/link_route_pick_screen.dart';
import 'map/airport_distance_screen.dart';
import 'map/global_delay_screen.dart';
import 'map/map_radar_screen.dart';
import 'more/flight_health_screen.dart';
import 'more/more_root_screen.dart';
import 'search/search_home_screen.dart';
import 'watch/watch_center_screen.dart';

/// Домашний экран раздела рейсов.
///
/// Стрелка назад ведёт в приложение: раздел — стек поверх вкладки «Kəşf», а
/// не отдельная вкладка. Панели разделов здесь нет — она появляется на пяти
/// корневых экранах, куда ведут плитки.
class FlightHomeScreen extends StatefulWidget {
  const FlightHomeScreen({super.key, this.asTab = false});

  /// Экран открыт вкладкой нижнего меню, а не толчком маршрута: возвращаться
  /// некуда, зато снизу лежит меню приложения.
  final bool asTab;

  @override
  State<FlightHomeScreen> createState() => _FlightHomeScreenState();
}

class _FlightHomeScreenState extends State<FlightHomeScreen> {
  final _repo = FlightRepository.instance;

  bool _signedIn = false;
  bool _loading = true;

  List<FlightWatch> _watches = const [];
  FlightError? _watchError;
  FlightDataHealth? _health;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Три запроса сразу: подписки, состояние потоков, непрочитанные
  /// уведомления. Ни один из них не обязателен — плитки на экране есть
  /// всегда, поэтому сбой любого куска гасит только свой блок.
  Future<void> _load({bool force = false}) async {
    final token = await sl.get<CacheManager>().getToken();
    final signedIn = token != null && token.isNotEmpty;
    if (!mounted) return;
    setState(() {
      _signedIn = signedIn;
      _loading = true;
      _watchError = null;
    });

    final health = _repo.health(force: force).then<FlightDataHealth?>(
      (value) => value.data,
      onError: (_) => null,
    );

    final watches = signedIn
        ? _repo.watches(force: force).then<Object?>(
            (value) => value.data ?? const <FlightWatch>[],
            onError: (Object error) => FlightError.from(error),
          )
        : Future<Object?>.value(const <FlightWatch>[]);

    final unread = signedIn
        ? FlightNotifications.unread(force: force)
            .then<int>((items) => items.length, onError: (_) => 0)
        : Future<int>.value(0);

    final results = await Future.wait<Object?>([health, watches, unread]);
    if (!mounted) return;
    setState(() {
      _health = results[0] as FlightDataHealth?;
      final w = results[1];
      if (w is FlightError) {
        _watchError = w;
        _watches = const [];
      } else {
        _watches = (w as List<FlightWatch>?) ?? const [];
      }
      _unread = results[2] as int? ?? 0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final watchCount = _watches.length;
    return FlightScaffold(
      title: ft('home_title', 'Uçuş radarı'),
      showBack: widget.asTab ? false : null,
      bottomInset: widget.asTab
          ? 64 + MediaQuery.of(context).padding.bottom
          : 0,
      actions: [
        FSkyAction(
          icon: PhosphorIconsBold.bell,
          onTap: () => _open(const WatchCenterScreen()),
        ),
      ],
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (watchCount > 0 || _unread > 0) ...[
              Row(
                children: [
                  if (watchCount > 0)
                    FBadge(
                      ft(
                        'home_watch_count',
                        '{n} izlədiyin uçuş',
                        {'n': '$watchCount'},
                      ),
                      icon: PhosphorIconsFill.bellRinging,
                      background: Colors.white.withValues(alpha: .22),
                      foreground: Colors.white,
                    ),
                  if (watchCount > 0 && _unread > 0) const SizedBox(width: 7),
                  if (_unread > 0)
                    FBadge(
                      ft(
                        'home_unread_count',
                        '{n} yeni bildiriş',
                        {'n': '$_unread'},
                      ),
                      background: Colors.white.withValues(alpha: .16),
                      foreground: Colors.white,
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Text(
              ft('home_hero', 'Uçuşu izlə, elanını bağla'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            _SearchField(
              onTap: () => _open(const SearchHomeScreen(autofocus: true)),
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(
          gap: 16,
          children: [
            Column(
              children: [
                FTileGrid(
                  tiles: [
                    FTile(
                      icon: PhosphorIconsFill.globeHemisphereEast,
                      title: ft('tile_map', 'Xəritə'),
                      subtitle: ft('tile_map_hint', 'Marşrutu izlə'),
                      badge: watchCount == 0
                          ? null
                          : FBadge(
                              ft(
                                'tile_map_badge',
                                '{n} İZLƏDİYİN',
                                {'n': '$watchCount'},
                              ),
                              tone: FTone.info,
                              fontSize: 9,
                            ),
                      onTap: () => _open(const MapRadarScreen()),
                    ),
                    FTile(
                      icon: PhosphorIconsFill.magnifyingGlass,
                      title: ft('tile_search', 'Uçuş axtar'),
                      subtitle: ft(
                        'tile_search_hint',
                        'Nömrə, marşrut, təyyarə',
                      ),
                      onTap: () => _open(const SearchHomeScreen()),
                    ),
                    FTile(
                      icon: PhosphorIconsFill.buildings,
                      title: ft('tile_airports', 'Hava limanları'),
                      subtitle: ft(
                        'tile_airports_hint',
                        'Gediş-gəliş lövhəsi',
                      ),
                      onTap: () => _open(const AirportListScreen()),
                    ),
                    FTile(
                      icon: PhosphorIconsFill.bellRinging,
                      title: ft('tile_watch', 'İzlədiklərim'),
                      subtitle: ft('tile_watch_hint', 'Bildirişlər'),
                      badge: _unread == 0
                          ? null
                          : FBadge(
                              ft('tile_watch_badge', '{n} YENİ', {
                                'n': '$_unread',
                              }),
                              tone: FTone.warn,
                              fontSize: 9,
                            ),
                      onTap: () => _open(const WatchCenterScreen()),
                    ),
                    FTile(
                      icon: PhosphorIconsFill.clockCountdown,
                      title: ft('tile_delays', 'Gecikmələr'),
                      subtitle: ft(
                        'tile_delays_hint',
                        'Dünya üzrə vəziyyət',
                      ),
                      onTap: () => _open(const GlobalDelayScreen()),
                    ),
                    FTile(
                      icon: PhosphorIconsFill.path,
                      title: ft('tile_distance', 'Məsafə'),
                      subtitle: ft('tile_distance_hint', 'İki liman arası'),
                      onTap: () => _open(const AirportDistanceScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FTile(
                  wide: true,
                  icon: PhosphorIconsFill.dotsThreeCircle,
                  title: ft('tile_more', 'Daha çox'),
                  subtitle: ft(
                    'tile_more_hint',
                    'Ayarlar, mənbə və lisenziyalar',
                  ),
                  onTap: () => _open(const MoreRootScreen()),
                ),
              ],
            ),
            if (_health?.degraded == true)
              _HealthStrip(onTap: () => _open(const FlightHealthScreen())),
            if (_loading)
              const FCardSkeleton(rows: 2)
            else
              ..._watchSection(d),
            FBrandActionCard(
              icon: PhosphorIconsFill.package,
              title: ft('home_link_title', 'Elanını uçuşa bağla'),
              subtitle: ft(
                'home_link_hint',
                'Marşrut və saat özü dolacaq',
              ),
              onTap: () => _open(const LinkRoutePickScreen()),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _watchSection(bool d) {
    if (!_signedIn) return const [];
    if (_watchError != null) {
      return [
        FErrorView(
          error: _watchError!,
          onRetry: () => _load(force: true),
          onSignIn: () => _signIn(),
        ),
      ];
    }
    if (_watches.isEmpty) return const [];
    final shown = _watches.length > 3 ? _watches.sublist(0, 3) : _watches;
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ft('home_watched', 'İzlədiyim uçuşlar'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cText(d),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _open(const WatchCenterScreen()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      ft('all', 'Hamısı'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FT.brand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < shown.length; i++) ...[
            if (i != 0) const SizedBox(height: 8),
            _WatchRow(
              watch: shown[i],
              onTap: () {
                final key = shown[i].key;
                if (key == null) return;
                _open(FlightCardScreen(flightKey: key));
              },
            ),
          ],
        ],
      ),
    ];
  }

  Future<void> _open(Widget screen) async {
    await FlightNav.push(context, screen);
    if (!mounted) return;
    // Возврат с экрана подписки или уведомлений меняет и счётчики, и список.
    _load();
  }

  void _signIn() => AuthModalUtils.showAuthRequiredModal(
        context,
        onLoginSuccess: () => _load(force: true),
        onRegisterSuccess: () => _load(force: true),
      );
}

/// Поле поиска на небе: только открывает экран поиска, ввода здесь нет.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rField,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: FT.rField,
          border: Border.all(color: Colors.white.withValues(alpha: .18)),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIconsBold.magnifyingGlass,
              size: 17,
              color: FT.onHero(.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ft('home_search_hint', 'Uçuş, təyyarə və ya liman'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FT.onHero(.72),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Полоска «живые данные работают ограниченно». Показывается только при
/// `degraded: true` — иначе её нет совсем.
class _HealthStrip extends StatelessWidget {
  const _HealthStrip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rField,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: FT.warnBg(d),
          borderRadius: FT.rField,
          border: Border.all(color: cLine(d)),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIconsFill.warningCircle,
              size: 17,
              color: FT.warn(d),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ft('home_degraded', 'Canlı məlumat məhdud işləyir'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: cText(d),
                    ),
                  ),
                  Text(
                    ft(
                      'home_degraded_hint',
                      'Vaxtlar cədvəl üzrə göstərilir',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cText2(d),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(PhosphorIconsBold.caretRight, size: 14, color: cText3(d)),
          ],
        ),
      ),
    );
  }
}

/// Строка отслеживаемого рейса: номер, статус и что сейчас происходит.
class _WatchRow extends StatelessWidget {
  const _WatchRow({required this.watch, required this.onTap});

  final FlightWatch watch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final flight = watch.flight;
    final visual = fStatusVisual(flight?.status);
    final tone = visual.tone;
    return FCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          FIconChip(
            icon: visual.icon,
            size: 38,
            iconSize: 17,
            background: tone.bg(d),
            color: tone.fg(d),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      flight?.displayNumber ?? '—',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cText(d),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FBadge(
                        _statusText(flight, visual.label),
                        tone: tone,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(flight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: cText3(d),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(PhosphorIconsBold.caretRight, size: 14, color: cText3(d)),
        ],
      ),
    );
  }

  /// У опоздания в значке стоит величина: «40 DƏQ GECİKİR». В остальных
  /// случаях — подпись сервера, она уже переведена.
  String _statusText(FlightSummary? flight, String fallback) {
    final delay = flight?.departureDelayMinutes;
    if (flight?.status == 'delayed' && delay != null && delay > 0) {
      return ft('home_delay_badge', '{n} DƏQ GECİKİR', {'n': '$delay'})
          .toUpperCase();
    }
    return (flight?.statusLabel ?? fallback).toUpperCase();
  }

  /// Вторая строка: маршрут и то, что сейчас важнее всего — сколько осталось
  /// лететь, новое время или дата.
  String _subtitle(FlightSummary? flight) {
    if (flight == null) return '—';
    final route = [
      flight.departureCode ?? '—',
      flight.arrivalCode ?? '—',
    ].join(' → ');

    final delay = flight.departureDelayMinutes;
    if (flight.status == 'delayed' && delay != null && delay > 0) {
      final clock = flight.departureLocal?.clock;
      if (clock != null) {
        return '$route · ${ft('home_new_time', 'yeni saat {t}', {'t': clock})}';
      }
    }

    final arrival = flight.arrivalAt;
    if (arrival != null && FlightStatus.isInAir(flight.status)) {
      final left = arrival.difference(DateTime.now().toUtc());
      if (!left.isNegative) {
        return '$route · '
            '${ft('home_time_left', '{t} qalıb', {
                  't': fMinutesShort(left.inMinutes),
                })}';
      }
    }

    final departure = flight.departureLocal?.clock;
    if (departure != null) return '$route · $departure';
    return '$route · ${fDateStringShort(flight.flightDate)}';
  }
}
