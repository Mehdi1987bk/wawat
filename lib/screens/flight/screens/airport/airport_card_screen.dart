import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/flight_error.dart';
import '../../data/flight_local_store.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'airport_board_screen.dart';
import 'airport_delays_screen.dart';
import 'airport_feeds_screen.dart';
import 'airport_routes_screen.dart';
import 'airport_runways_screen.dart';
import 'airport_solar_screen.dart';

/// `airport/card` — личность аэропорта и переходы.
///
/// Код может быть как IATA (3 буквы), так и ICAO (4). В ответе ровно два
/// числа: `runway_count` и `listings_count` — поэтому подписи плиток
/// статические. «48 uçuş», «11 dəq», «38 istiqamət» потребовали бы табло
/// дважды, задержек, маршрутов и солнца — пять лишних запросов на экран,
/// который человек открывает, чтобы просто перейти дальше.
///
/// Живой/расписание тут не показывается: этого в ответе нет, за ним — плитка
/// «Mənbələr».
class AirportCardScreen extends StatefulWidget {
  const AirportCardScreen({super.key, required this.code});

  final String code;

  @override
  State<AirportCardScreen> createState() => _AirportCardScreenState();
}

class _AirportCardScreenState extends State<AirportCardScreen> {
  final _repo = FlightRepository.instance;
  final _local = FlightLocalStore.instance;

  Airport? _airport;
  FlightError? _error;
  bool _loading = true;
  bool _saved = false;

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
    await _local.load();
    try {
      final result = await _repo.airport(widget.code);
      if (!mounted) return;
      setState(() {
        _airport = result.data;
        _saved = _local.isSaved(widget.code);
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

  @override
  Widget build(BuildContext context) {
    final airport = _airport;
    final title = airport == null
        ? widget.code
        : '${airport.summary.code} · ${airport.name ?? ''}'.trim();
    return FlightScaffold(
      title: title,
      actions: [
        FSkyAction(
          icon: _saved ? PhosphorIconsFill.star : PhosphorIconsBold.star,
          active: _saved,
          onTap: _toggleSaved,
        ),
      ],
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        child: _hero(airport),
      ),
      slivers: [
        FlightBody(children: _body(airport)),
      ],
    );
  }

  Widget _hero(Airport? airport) {
    if (airport == null) {
      return FHeroIntro(
        title: widget.code,
        message: _loading ? ft('loading', 'Yüklənir…') : null,
      );
    }
    final summary = airport.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              summary.iata ?? summary.code,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: -.5,
                color: Colors.white,
              ),
            ),
            if (summary.icao != null) ...[
              const SizedBox(width: 10),
              Text(
                summary.icao!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: FT.onHero(.7),
                ),
              ),
            ],
          ],
        ),
        if (summary.fullName != null || summary.name != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              summary.fullName ?? summary.name!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FT.onHero(.92),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            [summary.city, summary.country]
                .whereType<String>()
                .where((e) => e.isNotEmpty)
                .join(' · '),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FT.onHero(.66),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (airport.localTime != null)
                FBadge(
                  ft('airport_local_time', '{time} yerli', {
                    'time': _localClock(airport.localTime!),
                  }),
                  background: FT.heroBadgeBg(FTone.info),
                  foreground: FT.heroBadgeFg(FTone.info),
                  fontSize: 9.5,
                ),
              if (airport.timeZone != null)
                FBadge(
                  airport.timeZone!,
                  background: FT.heroBadgeBg(FTone.info),
                  foreground: FT.heroBadgeFg(FTone.info),
                  fontSize: 9.5,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// `local_time` считается на сервере и приходит строкой — берём из неё часы
  /// и минуты, а не пересчитываем зону на телефоне.
  String _localClock(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) return value;
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  List<Widget> _body(Airport? airport) {
    if (_loading) return const [FCardSkeleton(rows: 4), FCardSkeleton(rows: 5)];
    if (_error != null) {
      return [
        FErrorView(
          error: _error!,
          onRetry: () => _load(force: true),
          onFeeds: () => FlightNav.push(
            context,
            AirportFeedsScreen(code: widget.code),
          ),
          notFoundTitle: ft('airport_not_found', 'Bu liman tapılmadı'),
          notFoundMessage: ft(
            'airport_not_found_message',
            'Kodu yoxla — IATA (3 hərf) və ya ICAO (4 hərf) olmalıdır.',
          ),
        ),
      ];
    }
    if (airport == null) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.buildings,
          title: ft('airport_empty', 'Liman məlumatı gəlmir'),
          onFeeds: () => FlightNav.push(
            context,
            AirportFeedsScreen(code: widget.code),
          ),
        ),
      ];
    }
    final code = airport.summary.code;
    return [
      FTileGrid(
        tiles: [
          FTile(
            icon: PhosphorIconsFill.airplaneTakeoff,
            title: ft('airport_departures', 'Gedişlər'),
            subtitle: ft('airport_board_hint', 'lövhəyə bax'),
            onTap: () => FlightNav.push(
              context,
              AirportBoardScreen(code: code, airport: airport),
            ),
          ),
          FTile(
            icon: PhosphorIconsFill.airplaneLanding,
            title: ft('airport_arrivals', 'Gəlişlər'),
            subtitle: ft('airport_board_hint', 'lövhəyə bax'),
            onTap: () => FlightNav.push(
              context,
              AirportBoardScreen(
                code: code,
                airport: airport,
                arrivals: true,
              ),
            ),
          ),
          FTile(
            icon: PhosphorIconsFill.roadHorizon,
            title: ft('airport_runways', 'Zolaqlar'),
            subtitle: airport.runwayCount == null
                ? ft('airport_runways_hint', 'uçuş-enmə zolaqları')
                : ft('airport_runways_count', '{n} ədəd', {
                    'n': '${airport.runwayCount}',
                  }),
            onTap: () => FlightNav.push(
              context,
              AirportRunwaysScreen(airport: airport),
            ),
          ),
          FTile(
            icon: PhosphorIconsFill.sunHorizon,
            title: ft('airport_solar', 'Günəş'),
            subtitle: ft('airport_solar_hint', 'gün vaxtı'),
            onTap: () => FlightNav.push(
              context,
              AirportSolarScreen(airport: airport),
            ),
          ),
          FTile(
            icon: PhosphorIconsFill.clockCountdown,
            title: ft('airport_delays', 'Gecikmə'),
            subtitle: ft('airport_delays_hint', 'statistika'),
            onTap: () => FlightNav.push(
              context,
              AirportDelaysScreen(code: code, airport: airport),
            ),
          ),
          FTile(
            icon: PhosphorIconsFill.path,
            title: ft('airport_routes', 'Marşrutlar'),
            subtitle: ft('airport_routes_hint', 'istiqamətlər'),
            onTap: () => FlightNav.push(
              context,
              AirportRoutesScreen(code: code),
            ),
          ),
          FTile(
            icon: PhosphorIconsFill.pulse,
            title: ft('airport_feeds', 'Mənbələr'),
            subtitle: ft('airport_feeds_hint', 'nə işləyir'),
            wide: true,
            onTap: () => FlightNav.push(
              context,
              AirportFeedsScreen(code: code),
            ),
          ),
        ],
      ),
      _identityCard(airport),
      if (airport.urls.isNotEmpty) _linksCard(airport),
    ];
  }

  Widget _identityCard(Airport airport) {
    final summary = airport.summary;
    final country = summary.country;
    final countryCode = summary.countryCode;
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(ft('airport_identity', 'Kimlik')),
          FRow(
            ft('airport_codes', 'IATA / ICAO'),
            value: [summary.iata, summary.icao]
                .whereType<String>()
                .join(' / '),
            mono: true,
          ),
          if (airport.localCode != null)
            FRow(
              ft('airport_local_code', 'Yerli kod'),
              value: airport.localCode,
              mono: true,
            ),
          if (summary.city != null)
            FRow(ft('airport_city', 'Şəhər'), value: summary.city),
          if (country != null)
            FRow(
              ft('airport_country', 'Ölkə'),
              value: countryCode == null
                  ? country
                  : '${fFlag(countryCode)} $country ($countryCode)',
            ),
          if (airport.continent != null)
            FRow(
              ft('airport_continent', 'Kontinent'),
              value: _continent(airport.continent!),
            ),
          if (airport.elevationM != null)
            FRow(
              ft('airport_elevation', 'Hündürlük'),
              value: '${fMeters(airport.elevationM)} · '
                  '${fNum(airport.elevationFt ?? 0)} ${ft('unit_ft', 'ft')}',
            ),
          FRow(
            ft('airport_listings', 'Wawatair elanları'),
            value: airport.listingsCount == null
                ? '—'
                : ft('airport_listings_count', '{n} aktiv', {
                    'n': '${airport.listingsCount}',
                  }),
            last: true,
          ),
        ],
      ),
    );
  }

  /// Код континента приходит двумя буквами.
  String _continent(String code) => switch (code.toUpperCase()) {
        'AS' => ft('continent_as', 'Asiya'),
        'EU' => ft('continent_eu', 'Avropa'),
        'AF' => ft('continent_af', 'Afrika'),
        'NA' => ft('continent_na', 'Şimali Amerika'),
        'SA' => ft('continent_sa', 'Cənubi Amerika'),
        'OC' => ft('continent_oc', 'Okeaniya'),
        'AN' => ft('continent_an', 'Antarktida'),
        _ => code,
      };

  /// Пустые ссылки из ответа выпадают целиком — отсутствие ключа нормально,
  /// строка просто не показывается. Все четыре ведут наружу, не внутрь.
  Widget _linksCard(Airport airport) {
    final rows = <Widget>[];
    void add(IconData icon, String title, String? hint, String? url) {
      if (url == null || url.isEmpty) return;
      rows.add(FListRow(
        icon: icon,
        title: title,
        subtitle: hint,
        onTap: () => _open(url),
      ));
    }

    add(
      PhosphorIconsBold.globe,
      ft('airport_website', 'Rəsmi sayt'),
      _host(airport.website),
      airport.website,
    );
    add(
      PhosphorIconsBold.bookOpenText,
      ft('airport_wikipedia', 'Vikipediya'),
      ft('airport_wikipedia_hint', 'limanın səhifəsi'),
      airport.wikipedia,
    );
    add(
      PhosphorIconsBold.mapPin,
      ft('airport_maps', 'Google Maps'),
      ft('airport_maps_hint', 'xəritədə aç'),
      airport.googleMaps,
    );
    add(
      PhosphorIconsBold.radio,
      ft('airport_live_atc', 'LiveATC'),
      ft('airport_live_atc_hint', 'radio kanalı'),
      airport.liveAtc,
    );
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FSectionTitle(ft('airport_links', 'Keçidlər')),
        const SizedBox(height: 9),
        FGroupCard(children: rows),
      ],
    );
  }

  String? _host(String? url) {
    if (url == null) return null;
    return Uri.tryParse(url)?.host.replaceFirst('www.', '');
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      fToast(context, ft('airport_link_failed', 'Keçid açılmadı'));
    }
  }

  Future<void> _toggleSaved() async {
    await _local.toggleAirport(widget.code);
    if (!mounted) return;
    final saved = _local.isSaved(widget.code);
    setState(() => _saved = saved);
    fToast(
      context,
      saved
          ? ft('airport_saved', 'Seçilmişlərə əlavə olundu')
          : ft('airport_unsaved', 'Seçilmişlərdən çıxarıldı'),
    );
  }
}
