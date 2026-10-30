import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/network/response/notification_response.dart';
import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_auth.dart';
import '../../data/flight_error.dart';
import '../../data/flight_notifications.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_watch.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_event_visual.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'watch_item_screen.dart';
import 'watch_new_screen.dart';
import 'watch_route_new_screen.dart';
import 'watch_settings_screen.dart';

/// `watch/center` и `watch/empty` — всё, что человек отслеживает.
///
/// Рейс приходит **внутри** `GET /me/flight-watches`, поэтому на каждую
/// подписку отдельного запроса нет. И опрашивать подписанный рейс нельзя
/// (§4.4): сервер обновляет его сам — в воздухе каждые 90 секунд, за два
/// часа до вылета каждые 10 минут — и присылает push. Экран перезапрашивает
/// список только когда человек потянул вниз или вернулся с другого экрана.
///
/// Пустое состояние — не отдельный экран, а этот же: заголовок с нулём и
/// два пути завести первую подписку.
class WatchCenterScreen extends StatefulWidget {
  const WatchCenterScreen({super.key});

  @override
  State<WatchCenterScreen> createState() => _WatchCenterScreenState();
}

class _WatchCenterScreenState extends State<WatchCenterScreen> {
  final _repo = FlightRepository.instance;

  List<FlightWatch> _watches = const [];
  List<NotificationItem> _feed = const [];
  FlightError? _error;
  bool _loading = true;
  bool _signedIn = true;
  bool _reading = false;

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
    if (!await FlightAuth.signedIn()) {
      if (!mounted) return;
      setState(() {
        _signedIn = false;
        _loading = false;
        _watches = const [];
        _feed = const [];
      });
      return;
    }
    try {
      final watches = await _repo.watches(force: force);
      // Лента уведомлений к бюджету рейсовых данных не относится, но и
      // падать из-за неё список подписок не должен.
      List<NotificationItem> feed = const [];
      try {
        feed = await FlightNotifications.feed(force: force);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _watches = watches.data ?? const [];
        _feed = feed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final error = FlightError.from(e);
      setState(() {
        _error = error;
        _signedIn = !error.isUnauthenticated;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('watch_title', 'İzləmə'),
      section: FlightSection.watch,
      actions: [
        if (_signedIn)
          FSkyAction(
            icon: PhosphorIconsBold.gear,
            onTap: () => FlightNav.push(context, const WatchSettingsScreen()),
          ),
      ],
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
        child: _hero(),
      ),
      slivers: [
        FlightBody(gap: 12, children: _body()),
      ],
    );
  }

  Widget _hero() {
    if (!_signedIn) {
      return FHeroIntro(
        title: ft('watch_signin_title', 'Uçuşu izləmək üçün daxil ol'),
        message: ft(
          'watch_signin_message',
          'Uçuşlara və limanlara baxmaq üçün giriş lazım deyil — yalnız '
              'izləmə hesaba bağlıdır.',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${_watches.length}',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 1,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ft('watch_count_label', 'uçuş izləyirsən'),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: FT.onHero(.88),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _watches.isEmpty
              ? ft(
                  'watch_hero_empty',
                  'İlk uçuşu izləməyə al — dəyişiklikdən dərhal xəbər '
                      'göndərəcəyik',
                )
              : ft(
                  'watch_hero_message',
                  'Nəsə dəyişsə dərhal xəbər göndərəcəyik',
                ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.45,
            color: FT.onHero(.72),
          ),
        ),
      ],
    );
  }

  List<Widget> _body() {
    if (!_signedIn) {
      return [
        FSignInRequired(
          onSignIn: () => FlightAuth.present(context, onDone: () => _load()),
        ),
      ];
    }
    if (_loading) return const [FListSkeleton(rows: 3)];
    if (_error != null) {
      return [
        FErrorView(
          error: _error!,
          onRetry: () => _load(force: true),
          onSignIn: () => FlightAuth.present(context, onDone: () => _load()),
        ),
      ];
    }
    return [
      if (_watches.isEmpty) _empty() else ..._watchRows(),
      if (_watches.isNotEmpty)
        FSecondaryButton(
          label: ft('watch_add', 'Uçuş izləməyə al'),
          icon: PhosphorIconsBold.plus,
          onTap: _openNew,
        ),
      if (_feed.isNotEmpty) _feedCard(),
    ];
  }

  Widget _empty() {
    return FStateBlock(
      icon: PhosphorIconsFill.bellSlash,
      title: ft('watch_empty_title', 'Hələ uçuş izləmirsən'),
      message: ft(
        'watch_empty_message',
        'İzləməyə aldığın uçuşun statusu, vaxtı, qapısı və baqaj lenti '
            'dəyişəndə xəbər göndərəcəyik.',
      ),
      actions: [
        FPrimaryButton(
          label: ft('watch_empty_by_number', 'Uçuş nömrəsi ilə'),
          icon: PhosphorIconsBold.magnifyingGlass,
          onTap: _openNew,
        ),
        FSecondaryButton(
          label: ft('watch_empty_by_route', 'Marşrutla tap'),
          icon: PhosphorIconsBold.path,
          onTap: () async {
            await FlightNav.push(context, const WatchRouteNewScreen());
            if (mounted) _load(force: true);
          },
        ),
      ],
    );
  }

  List<Widget> _watchRows() {
    final now = DateTime.now();
    return [
      Column(
        children: [
          for (var i = 0; i < _watches.length; i++) ...[
            if (i != 0) const SizedBox(height: 8),
            _watchRow(_watches[i], now),
          ],
        ],
      ),
    ];
  }

  Widget _watchRow(FlightWatch watch, DateTime now) {
    final flight = watch.flight;
    final visual = fStatusVisual(flight?.status);
    final muted = watch.isMuted(now);
    return FFlightRow(
      number: flight?.displayNumber ?? ft('watch_unknown_flight', 'Uçuş'),
      statusLabel: flight == null
          ? null
          : (flight.statusLabel ?? visual.label).toUpperCase(),
      statusTone: visual.tone,
      route: _routeLine(flight),
      times: _subLine(watch, flight, now),
      meta: muted
          ? ft('watch_muted_until', 'səssizdir — {time}-dək', {
              'time': fClock(watch.mutedUntil),
            })
          : null,
      // Стрелку строка рисует сама; здесь только значок «без звука», иначе
      // у неподписанного на тишину рейса выходили две стрелки подряд.
      trailing: muted
          ? Icon(
              PhosphorIconsFill.bellSlash,
              size: 14,
              color: cFaint(fDark(context)),
            )
          : null,
      onTap: () => _openWatch(watch),
    );
  }

  String? _routeLine(FlightSummary? flight) {
    if (flight == null) return null;
    final route = '${flight.departureCode ?? '—'} → ${flight.arrivalCode ?? '—'}';
    final day = fDayWord(flight.flightDate);
    final clock = flight.departureLocal?.clock;
    if (clock == null) return '$route · $day';
    return '$route · $day $clock';
  }

  /// Третья строка — то, что человеку важно прямо сейчас: когда сядет, если
  /// рейс в воздухе, и новое время, если рейс сдвинули.
  String? _subLine(FlightWatch watch, FlightSummary? flight, DateTime now) {
    if (flight == null) return null;
    final arrival = flight.arrivalAt;
    if (flight.isLive && arrival != null && arrival.isAfter(now.toUtc())) {
      return ft('watch_lands_in', '{time} sonra enir', {
        'time': fMinutesLong(arrival.difference(now.toUtc()).inMinutes),
      });
    }
    final delay = flight.departureDelayMinutes ?? flight.arrivalDelayMinutes;
    if (delay != null && delay > 0) {
      final clock = flight.departureLocal?.clock ?? flight.arrivalLocal?.clock;
      if (clock != null) {
        return ft('watch_new_time', 'Yeni saat {time}', {'time': clock});
      }
    }
    return null;
  }

  Widget _feedCard() {
    final d = fDark(context);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            ft('watch_feed_title', 'Bildirişlər'),
            trailing: _feed.any((item) => item.isUnread)
                ? GestureDetector(
                    onTap: _reading ? null : _readAll,
                    child: Text(
                      ft('watch_feed_read_all', 'Hamısını oxu'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: cBrandText(d),
                      ),
                    ),
                  )
                : null,
          ),
          for (var i = 0; i < _feed.length; i++)
            _feedRow(_feed[i], last: i == _feed.length - 1),
        ],
      ),
    );
  }

  Widget _feedRow(NotificationItem item, {required bool last}) {
    final visual = fFlightNotificationVisual(item.type);
    return FEventRow(
      icon: visual.icon,
      title: item.title,
      subtitle: item.body,
      time: fAgo(DateTime.tryParse(item.createdAt)),
      tone: visual.tone,
      last: last,
    );
  }

  Future<void> _readAll() async {
    setState(() => _reading = true);
    try {
      await FlightNotifications.readAll();
      final feed = await FlightNotifications.feed(force: true);
      if (!mounted) return;
      setState(() {
        _feed = feed;
        _reading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _reading = false);
      fToast(
        context,
        FlightError.from(e).display(
          ft('watch_feed_read_failed', 'Bildirişlər oxunmuş sayılmadı'),
        ),
      );
    }
  }

  Future<void> _openNew() async {
    await FlightNav.push(context, const WatchNewScreen());
    if (mounted) _load(force: true);
  }

  Future<void> _openWatch(FlightWatch watch) async {
    final key = watch.key;
    if (key == null) {
      // Без рейса внутри подписки открывать нечего: ключ собрать не из чего.
      return;
    }
    final changed = await FlightNav.push<bool>(
      context,
      WatchItemScreen(watch: watch),
    );
    if (!mounted) return;
    if (changed == true) _load(force: true);
  }
}
