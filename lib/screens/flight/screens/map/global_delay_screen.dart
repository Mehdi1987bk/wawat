import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_city_names.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight_stats.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_map.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../airport/airport_delays_screen.dart';

/// `map/globaldelay` — где в мире сейчас задержки.
///
/// Главное правило этого экрана (§9.2): `delayIndex` и `medianDelay` приходят
/// только там, где есть рейсы с измеренным фактическим временем. В живом
/// ответе цифра есть у 523 аэропортов из 1728 — то есть её отсутствие это
/// основной случай, а не край. Поэтому список делится на два: измеренные
/// сортируются и красятся, остальные стоят отдельно и нейтрально, с числом
/// рейсов. Писать «задержек нет» нельзя — правда звучит «не измерено».
///
/// Ключ ответа — `airportIcao` (EGLL, OMDB), а не IATA. Код переводится нашим
/// каталогом: сначала одним общим списком аэропортов, и только для показанных
/// строк, которых в нём не оказалось, уходит точечный `/airports/{kod}`.
/// Отличие от прототипа (§16) здесь одно: у строки нет «севiddə» выдуманных
/// причин задержки — в ответе их нет.
class GlobalDelayScreen extends StatefulWidget {
  const GlobalDelayScreen({super.key});

  @override
  State<GlobalDelayScreen> createState() => _GlobalDelayScreenState();
}

class _GlobalDelayScreenState extends State<GlobalDelayScreen> {
  final _repo = FlightRepository.instance;

  /// Сколько строк показываем и сколько кодов разрешено доспросить. Экран
  /// не должен съедать минутный бюджет раздела (§4.4).
  static const _maxRows = 12;
  static const _maxLookups = 8;

  List<GlobalDelayItem> _items = const [];
  final Map<String, AirportSummary> _airports = {};
  FlightError? _error;
  bool _loading = true;
  String? _stale;

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
      final envelope = await _repo.globalDelays(force: force);
      final items = envelope.data ?? const <GlobalDelayItem>[];
      if (!mounted) return;
      setState(() {
        _items = items;
        _stale = fStaleLineText(envelope.meta);
        _loading = false;
      });
      await _resolveNames();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _loading = false;
      });
    }
  }

  /// Имена и координаты для показанных строк. Сначала общий каталог — он всё
  /// равно загружается для названий городов, — потом точечные запросы.
  Future<void> _resolveNames() async {
    try {
      final catalog = (await _repo.airports(limit: 200)).data ?? const [];
      FlightCityNames.remember(catalog);
      for (final airport in catalog) {
        for (final code in [airport.icao, airport.iata, airport.code]) {
          if (code != null && code.isNotEmpty) {
            _airports[code.toUpperCase()] = airport;
          }
        }
      }
    } catch (_) {
      // Каталог не пришёл — строки останутся с кодом ICAO, экран работает.
    }
    if (mounted) setState(() {});

    final wanted = <String>[];
    for (final item in [..._measured().take(_maxRows), ..._unmeasured()]) {
      final icao = item.airportIcao?.toUpperCase();
      if (icao == null || _airports.containsKey(icao)) continue;
      if (!wanted.contains(icao)) wanted.add(icao);
      if (wanted.length >= _maxLookups) break;
    }
    for (final icao in wanted) {
      try {
        final airport = (await _repo.airport(icao)).data?.summary;
        if (airport == null) continue;
        _airports[icao] = airport;
        if (!mounted) return;
        setState(() {});
      } catch (_) {
        // Нет такого кода в каталоге — строка останется с ICAO.
      }
    }
  }

  // ─────────────────────────── Разбор ответа ───────────────────────────

  /// Измеренные — только у них есть цифра, по ней и сортировка (§9.2).
  List<GlobalDelayItem> _measured() {
    final out = _items.where((item) => item.worstMedian != null).toList();
    out.sort((a, b) =>
        b.worstMedian!.value.compareTo(a.worstMedian!.value));
    return out;
  }

  List<GlobalDelayItem> _unmeasured() =>
      _items.where((item) => item.worstMedian == null).toList(growable: false);

  int _minutesOf(GlobalDelayItem item) =>
      item.worstMedian?.value.inMinutes ?? 0;

  /// Порог «ciddi» и «orta» считается на телефоне: готового деления API не
  /// отдаёт.
  FTone _tone(int minutes) {
    if (minutes >= 45) return FTone.bad;
    if (minutes >= 20) return FTone.warn;
    return FTone.ok;
  }

  String _toneLabel(int minutes) {
    if (minutes >= 45) return ft('gdelay_severe', 'Ciddi');
    if (minutes >= 20) return ft('gdelay_moderate', 'Orta');
    return ft('gdelay_normal', 'Normal');
  }

  AirportSummary? _airportOf(GlobalDelayItem item) {
    final icao = item.airportIcao?.toUpperCase();
    return icao == null ? null : _airports[icao];
  }

  String _code(GlobalDelayItem item) {
    final airport = _airportOf(item);
    return airport?.iata ?? airport?.code ?? item.airportIcao ?? '—';
  }

  String _name(GlobalDelayItem item) {
    final airport = _airportOf(item);
    final city = airport?.city ?? airport?.name;
    if (city != null && city.isNotEmpty) return city;
    return item.airportIcao ?? '—';
  }

  // ───────────────────────────── Экран ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    final measured = _measured();
    final severe = measured.where((item) => _minutesOf(item) >= 45).length;
    return FlightScaffold(
      title: ft('gdelay_title', 'Qlobal gecikmələr'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _loading ? '—' : '$severe',
                  style: const TextStyle(
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    ft('gdelay_hero', 'limanda ciddi gecikmə'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: FT.onHero(.82),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _momentLine(measured.length),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: FT.onHero(.7),
              ),
            ),
          ],
        ),
      ),
      stale: _stale,
      slivers: [
        FlightBody(children: _body(measured)),
      ],
    );
  }

  /// «21 oktyabr 22:34 UTC · dünya üzrə» — время ответа, а не телефона:
  /// экран про весь мир, местного времени у него нет.
  String _momentLine(int measured) {
    final world = ft('gdelay_world', 'dünya üzrə');
    if (_loading) return world;
    final parts = <String>[
      ft('gdelay_measured', '{n} limanda ölçülmüş gecikmə', {
        'n': '$measured',
      }),
      world,
    ];
    return parts.join(' · ');
  }

  List<Widget> _body(List<GlobalDelayItem> measured) {
    if (_loading) {
      return const [FCardSkeleton(rows: 2), FListSkeleton(rows: 4)];
    }
    final error = _error;
    if (error != null) {
      return [FErrorView(error: error, onRetry: () => _load(force: true))];
    }
    if (_items.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.chartLineDown,
          title: ft('gdelay_empty', 'Gecikmə ölçüsü gəlmədi'),
          message: ft(
            'gdelay_empty_message',
            'Bu anda heç bir liman üçün gecikmə rəqəmi yoxdur. Bu nasazlıq '
                'deyil — faktiki vaxtı ölçülmüş uçuş olmayanda rəqəm gəlmir.',
          ),
        ),
      ];
    }

    final rows = measured.take(_maxRows).toList(growable: false);
    final top = rows.isEmpty ? 0 : _minutesOf(rows.first);
    final unmeasured = _unmeasured();

    return [
      if (_heat(rows).isNotEmpty) _map(rows),
      if (rows.isEmpty)
        FCalmEmpty(
          icon: PhosphorIconsFill.chartLineDown,
          title: ft('gdelay_none_measured', 'Ölçülmüş gecikmə yoxdur'),
          message: ft(
            'gdelay_none_measured_message',
            'Cavabda {n} liman var, lakin heç birində faktiki vaxt '
                'ölçülməyib — rəqəm gəlmir.',
            {'n': '${_items.length}'},
          ),
        )
      else
        FCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FCardTitle(ft('gdelay_worst', 'Ən problemli limanlar')),
              const SizedBox(height: 6),
              for (var i = 0; i < rows.length; i++)
                _row(rows[i], top: top, last: i == rows.length - 1),
            ],
          ),
        ),
      if (unmeasured.isNotEmpty) _unmeasuredCard(unmeasured),
      FInfoNote(
        ft(
          'gdelay_note',
          'Sıra yalnız gecikməsi ölçülmüş limanlardan qurulur. Qalan '
              'limanlar cavabda var, amma uçuşlarının faktiki vaxtı '
              'bilinmədiyi üçün rəqəm gəlmir — «ölçülməyib» kimi göstərilir.',
        ),
      ),
    ];
  }

  // ───────────────────────────── Карта ─────────────────────────────

  List<FMapHeat> _heat(List<GlobalDelayItem> rows) {
    final out = <FMapHeat>[];
    for (final item in rows) {
      final airport = _airportOf(item);
      if (airport?.lat == null || airport?.lon == null) continue;
      final minutes = _minutesOf(item);
      final tone = _tone(minutes);
      out.add(FMapHeat(
        point: LatLng(airport!.lat!, airport.lon!),
        radius: minutes >= 45 ? 16 : (minutes >= 20 ? 12 : 9),
        color: tone.fg(fDark(context)).withValues(alpha: .35),
        onTap: () => _open(item),
      ));
    }
    return out;
  }

  Widget _map(List<GlobalDelayItem> rows) => FMapFrame(
        height: 180,
        map: FFlightMap(
          heat: _heat(rows),
          airports: [
            for (final item in rows)
              if (_airportOf(item)?.lat != null)
                FMapAirport(
                  point: LatLng(
                    _airportOf(item)!.lat!,
                    _airportOf(item)!.lon!,
                  ),
                  code: _code(item),
                  muted: _minutesOf(item) < 20,
                  onTap: () => _open(item),
                ),
          ],
          zoom: 1.6,
          minZoom: 1,
          maxZoom: 6,
          interactive: true,
          padding: const EdgeInsets.all(34),
        ),
      );

  // ───────────────────────────── Строки ─────────────────────────────

  Widget _row(
    GlobalDelayItem item, {
    required int top,
    required bool last,
  }) {
    final d = fDark(context);
    final minutes = _minutesOf(item);
    final tone = _tone(minutes);
    final share = top <= 0 ? 0.0 : (minutes / top * 100).clamp(2, 100);
    return InkWell(
      onTap: () => _open(item),
      borderRadius: FT.rSoft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: last
            ? null
            : BoxDecoration(
                border: Border(bottom: BorderSide(color: cLine(d))),
              ),
        child: Row(
          children: [
            _codeChip(_code(item), tone: tone),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _name(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cText(d),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fMinutesShort(minutes),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: tone.fg(d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: FT.rPill,
                    child: LinearProgressIndicator(
                      value: share / 100,
                      minHeight: 5,
                      backgroundColor: FT.chip(d),
                      valueColor: AlwaysStoppedAnimation(tone.fg(d)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _flightsLine(item),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cText3(d),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FBadge(_toneLabel(minutes), tone: tone, fontSize: 10),
          ],
        ),
      ),
    );
  }

  Widget _unmeasuredCard(List<GlobalDelayItem> items) {
    final d = fDark(context);
    final known = items
        .where((item) => _airportOf(item) != null)
        .take(6)
        .toList(growable: false);
    return FCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            ft('gdelay_unmeasured', 'Ölçülməyən limanlar'),
            trailing: FBadge('${items.length}', fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            ft(
              'gdelay_unmeasured_message',
              'Bu limanlar cavabda var, rəqəmi yoxdur: uçuşlarının faktiki '
                  'vaxtı ölçülməyib.',
            ),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: cText3(d),
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < known.length; i++)
            _mutedRow(known[i], last: i == known.length - 1),
        ],
      ),
    );
  }

  Widget _mutedRow(GlobalDelayItem item, {required bool last}) {
    final d = fDark(context);
    return InkWell(
      onTap: () => _open(item),
      borderRadius: FT.rSoft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: last
            ? null
            : BoxDecoration(
                border: Border(bottom: BorderSide(color: cLine(d))),
              ),
        child: Row(
          children: [
            _codeChip(_code(item), tone: FTone.mute),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cText(d),
                    ),
                  ),
                  Text(
                    _flightsLine(item),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cText3(d),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FBadge(
              ft('gdelay_unknown', 'ölçülməyib'),
              fontSize: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeChip(String code, {required FTone tone}) {
    final d = fDark(context);
    return Container(
      height: 34,
      width: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone == FTone.mute ? FT.chip(d) : tone.bg(d),
        borderRadius: FT.rSoft,
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
          fontFamily: 'monospace',
          fontFamilyFallback: const ['Menlo', 'Courier'],
          color: tone == FTone.mute ? cText2(d) : tone.fg(d),
        ),
      ),
    );
  }

  /// «2 gediş · 9 gəliş» — то немногое, что известно и про неизмеренные.
  String _flightsLine(GlobalDelayItem item) {
    final parts = <String>[];
    final departures = item.departures?.numTotal;
    final arrivals = item.arrivals?.numTotal;
    if (departures != null) {
      parts.add(ft('gdelay_departures', '{n} gediş', {'n': '$departures'}));
    }
    if (arrivals != null) {
      parts.add(ft('gdelay_arrivals', '{n} gəliş', {'n': '$arrivals'}));
    }
    if (parts.isEmpty) return ft('gdelay_no_counts', 'uçuş sayı bilinmir');
    return parts.join(' · ');
  }

  void _open(GlobalDelayItem item) {
    final airport = _airportOf(item);
    final code = airport?.iata ?? airport?.code ?? item.airportIcao;
    if (code == null) return;
    FlightNav.push(context, AirportDelaysScreen(code: code));
  }
}
