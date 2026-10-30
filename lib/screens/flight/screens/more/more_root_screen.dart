import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_auth.dart';
import '../../data/flight_local_store.dart';
import '../../data/flight_repository.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../watch/watch_settings_screen.dart';
import 'more_about_screen.dart';

/// `more/root` — корневой экран раздела.
///
/// Отдельной кнопки «выйти из радара» здесь нет (§9.9): назад ведёт стрелка
/// в шапке, а в основное приложение человек возвращается нижним меню.
///
/// История поиска и выбранные аэропорты живут **только на телефоне**: на
/// сервере таких списков нет — `/saved-searches` относится к объявлениям, а
/// `is_featured` у аэропорта это наша редакционная метка, а не выбор
/// человека. Поэтому их счётчики читаются из локального хранилища, без
/// запроса.
class MoreRootScreen extends StatefulWidget {
  const MoreRootScreen({super.key});

  @override
  State<MoreRootScreen> createState() => _MoreRootScreenState();
}

class _MoreRootScreenState extends State<MoreRootScreen> {
  /// Версия самого раздела, а не приложения: он выходит отдельно от магазина.
  static const _version = '1.0';

  final _repo = FlightRepository.instance;
  final _store = FlightLocalStore.instance;

  int? _watches;
  bool _signedIn = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final signedIn = await FlightAuth.signedIn();
    await _store.load();
    int? watches;
    if (signedIn) {
      try {
        // Один запрос на вход: число подписок — единственное, чего нет на
        // телефоне. Упал — строка просто останется без счётчика.
        watches = (await _repo.watches()).data?.length;
      } catch (_) {
        watches = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _signedIn = signedIn;
      _watches = watches;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return FlightScaffold(
      title: ft('more_title', 'Daha çox'),
      section: FlightSection.more,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FT.onHero(.16),
                borderRadius: FT.rIcon,
              ),
              child: const Icon(
                PhosphorIconsFill.globeHemisphereEast,
                size: 19,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ft('more_module', 'Uçuş radarı'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                Text(
                  ft('more_version', 'Versiya {v}', {'v': _version}),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: FT.onHero(.78),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            FGroupCard(
              children: [
                FListRow(
                  flat: true,
                  icon: PhosphorIconsFill.star,
                  title: ft('more_watches', 'İzlədiyim uçuşlar'),
                  subtitle: _watchesLine(),
                  onTap: () =>
                      FlightNav.toSection(context, FlightSection.watch),
                ),
                FListRow(
                  flat: true,
                  icon: PhosphorIconsFill.clockCounterClockwise,
                  title: ft('more_history', 'Axtarış tarixçəsi'),
                  subtitle: _historyLine(),
                  onTap: () =>
                      FlightNav.toSection(context, FlightSection.search),
                ),
                FListRow(
                  flat: true,
                  icon: PhosphorIconsFill.bookmarkSimple,
                  title: ft('more_saved_airports', 'Seçilmiş limanlar'),
                  subtitle: _airportsLine(),
                  onTap: () =>
                      FlightNav.toSection(context, FlightSection.airports),
                ),
              ],
            ),
            FGroupCard(
              children: [
                FListRow(
                  flat: true,
                  icon: PhosphorIconsFill.bellRinging,
                  title: ft('more_notifications', 'Bildiriş ayarları'),
                  subtitle: ft(
                    'more_notifications_sub',
                    'push, e-poçt, sakit saatlar',
                  ),
                  onTap: () => FlightNav.push(
                    context,
                    const WatchSettingsScreen(),
                  ),
                ),
                FListRow(
                  flat: true,
                  icon: PhosphorIconsFill.info,
                  title: ft('more_about', 'Mənbə və lisenziyalar'),
                  subtitle: ft(
                    'more_about_sub',
                    'AeroDataBox · Esri · OpenStreetMap',
                  ),
                  onTap: () => FlightNav.push(
                    context,
                    const MoreAboutScreen(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: Text(
                ft(
                  'more_footer',
                  'Uçuş məlumatı: AeroDataBox · xəritə: Esri, OpenStreetMap',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: cText3(d),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _watchesLine() {
    if (_loading) return ft('more_loading', 'yüklənir…');
    if (!_signedIn) {
      return ft('more_watches_guest', 'daxil olduqdan sonra görünür');
    }
    final count = _watches;
    if (count == null) return ft('more_watches_unknown', 'sayı alınmadı');
    if (count == 0) return ft('more_watches_empty', 'hələ boşdur');
    return ft('more_watches_count', '{n} aktiv', {'n': '$count'});
  }

  /// Только на телефоне — так и подписано: сервер этого списка не знает.
  String _historyLine() {
    final onDevice = ft('more_on_device', 'yalnız bu cihazda');
    final count = _store.recents.length;
    if (count == 0) {
      return '${ft('more_history_empty', 'hələ boşdur')} · $onDevice';
    }
    return '${ft('more_history_count', '{n} qeyd', {'n': '$count'})} · '
        '$onDevice';
  }

  String _airportsLine() {
    final onDevice = ft('more_on_device', 'yalnız bu cihazda');
    final codes = _store.savedAirports;
    if (codes.isEmpty) {
      return '${ft('more_airports_empty', 'seçilmiş liman yoxdur')} · '
          '$onDevice';
    }
    final shown = codes.take(3).join(' · ');
    final tail = codes.length > 3 ? ' …' : '';
    return '$shown$tail · $onDevice';
  }
}
