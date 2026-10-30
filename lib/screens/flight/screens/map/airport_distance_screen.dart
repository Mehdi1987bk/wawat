import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
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
import '../airport/airport_list_screen.dart';
import '../link/link_route_pick_screen.dart';

/// `map/distance` — расстояние и примерное время полёта между двумя
/// аэропортами.
///
/// Ответ идёт в формате поставщика, поэтому поля в camelCase:
/// `from · to · greatCircleDistance{meter, km, mile, nm} · approxFlightTime`
/// (§9.2). `approxFlightTime` мы не пересчитываем — значение показывается как
/// пришло; человеческая строка собирается только если формат разобрался.
///
/// Код ищется в нашем каталоге (IATA, ICAO, local_code). Не нашёлся — ответ
/// наш собственный 404 с готовым сообщением, и оно выводится как есть.
///
/// Отличие от прототипа (§16): кнопка внизу ведёт не прямо в привязку
/// объявления, а на выбор рейса этого маршрута. Привязать объявление можно
/// только к конкретному рейсу — расстояние само рейсом не является.
class AirportDistanceScreen extends StatefulWidget {
  /// Экран открывается и пустым — с домашней плитки «Məsafə», как
  /// калькулятор между двумя любыми кодами.
  const AirportDistanceScreen({super.key, this.from, this.to});

  final String? from;
  final String? to;

  @override
  State<AirportDistanceScreen> createState() => _AirportDistanceScreenState();
}

class _AirportDistanceScreenState extends State<AirportDistanceScreen> {
  final _repo = FlightRepository.instance;

  String? _from;
  String? _to;

  AirportDistance? _distance;
  FlightError? _error;
  String? _stale;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _from = widget.from?.toUpperCase();
    _to = widget.to?.toUpperCase();
    if (_ready) _load();
  }

  bool get _ready => _from != null && _to != null;

  Future<void> _load() async {
    final from = _from;
    final to = _to;
    if (from == null || to == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final envelope = await _repo.distance(from, to);
      if (!mounted) return;
      setState(() {
        _distance = envelope.data;
        _stale = fStaleLineText(envelope.meta);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _distance = null;
        _loading = false;
      });
    }
  }

  Future<void> _pick({required bool departure}) async {
    final picked = await FlightNav.push<AirportSummary>(
      context,
      const AirportListScreen(picker: true),
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (departure) {
        _from = picked.code.toUpperCase();
      } else {
        _to = picked.code.toUpperCase();
      }
      _distance = null;
    });
    if (_ready) _load();
  }

  void _swap() {
    if (!_ready) return;
    setState(() {
      final from = _from;
      _from = _to;
      _to = from;
      _distance = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('distance_title', 'Məsafə kalkulyatoru'),
      subtitle: _ready ? '$_from → $_to' : null,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: _heroCode(
                label: ft('distance_from', 'HARADAN'),
                code: _from,
                onTap: () => _pick(departure: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: _ready ? _swap : null,
                borderRadius: FT.rPill,
                child: Container(
                  height: 38,
                  width: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: _ready ? .18 : .08),
                  ),
                  child: Icon(
                    PhosphorIconsBold.arrowsLeftRight,
                    size: 16,
                    color: FT.onHero(_ready ? 1 : .5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _heroCode(
                label: ft('distance_to', 'HARAYA'),
                code: _to,
                onTap: () => _pick(departure: false),
              ),
            ),
          ],
        ),
      ),
      stale: _stale,
      slivers: [
        FlightBody(children: _body()),
      ],
      bottom: _distance == null
          ? null
          : FSecondaryButton(
              label: ft('distance_make_listing', 'Bu marşrutla elan yarat'),
              icon: PhosphorIconsBold.package,
              onTap: _openRoute,
            ),
    );
  }

  Widget _heroCode({
    required String label,
    required String? code,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rField,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: FT.rField,
          border: Border.all(color: Colors.white.withValues(alpha: .12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
                color: FT.onHero(.55),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              code ?? ft('distance_choose', 'Seç'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 21,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: .4,
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Menlo', 'Courier'],
                color: code == null ? FT.onHero(.6) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body() {
    if (!_ready) {
      return [
        FStateBlock(
          icon: PhosphorIconsFill.ruler,
          title: ft('distance_need_codes', 'İki liman seç'),
          message: ft(
            'distance_need_codes_message',
            'Yuxarıdan gediş və çatma limanını göstər — böyük dairə məsafəsi '
                'və təxmini uçuş vaxtını gətirək.',
          ),
          actions: [
            // Кнопка зовёт именно к тому порту, которого не хватает: после
            // выбора вылета она должна предлагать прилёт, а не повторять
            // первый шаг.
            if (_from == null)
              FSecondaryButton(
                label: ft('distance_pick_from', 'Gediş limanını seç'),
                icon: PhosphorIconsBold.airplaneTakeoff,
                onTap: () => _pick(departure: true),
              )
            else
              FSecondaryButton(
                label: ft('distance_pick_to', 'Çatma limanını seç'),
                icon: PhosphorIconsBold.airplaneLanding,
                onTap: () => _pick(departure: false),
              ),
          ],
        ),
      ];
    }
    if (_loading) return const [FCardSkeleton(rows: 4)];
    final error = _error;
    if (error != null) {
      return [
        FErrorView(
          error: error,
          onRetry: _load,
          notFoundTitle: ft('distance_not_found', 'Hava limanı tapılmadı'),
          notFoundActions: [
            FSecondaryButton(
              label: ft('distance_change', 'Limanı dəyiş'),
              icon: PhosphorIconsBold.buildings,
              onTap: () => _pick(departure: true),
            ),
          ],
        ),
      ];
    }
    final distance = _distance;
    if (distance == null) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.ruler,
          title: ft('distance_empty', 'Məsafə gəlmədi'),
          message: ft(
            'distance_empty_message',
            'Bu iki liman üçün ölçü gəlmir. Kodları yoxlayıb yenidən sına.',
          ),
        ),
      ];
    }

    return [
      if (_arc(distance) != null) _map(distance),
      FEqualRow(
        children: [
          Expanded(
            child: _stat(
              value: distance.km == null ? '—' : fNum(distance.km!),
              unit: ft('unit_km', 'km'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _stat(
              value: distance.nm == null ? '—' : fNum(distance.nm!),
              unit: ft('distance_nm', 'dəniz mili'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _stat(
              value: distance.approxFlightTime ?? '—',
              unit: ft('distance_time', 'uçuş vaxtı'),
            ),
          ),
        ],
      ),
      FCard(
        child: Column(
          children: [
            FRow(
              ft('distance_great_circle', 'Böyük dairə məsafəsi'),
              value: fKm(distance.km),
            ),
            FRow(
              ft('distance_miles', 'Mil ilə'),
              value: distance.mile == null
                  ? '—'
                  : '${fNum(distance.mile!)} ${ft('unit_mile', 'mil')}',
            ),
            FRow(
              ft('distance_approx', 'Təxmini uçuş vaxtı'),
              value: _flightTime(distance.approxFlightTime),
            ),
            FRow(
              ft('distance_from_row', 'Haradan'),
              value: _place(distance.from, _from),
            ),
            FRow(
              ft('distance_to_row', 'Haraya'),
              value: _place(distance.to, _to),
              last: true,
            ),
          ],
        ),
      ),
      FInfoNote(
        ft(
          'distance_note',
          'Böyük dairə məsafəsi — iki liman arasındaki ən qısa yol. Faktiki '
              'marşrut hava dəhlizlərinə görə uzun olur, uçuş vaxtı da '
              'təxminidir.',
        ),
      ),
    ];
  }

  Widget _stat({required String value, required String unit}) {
    final d = fDark(context);
    return FCard(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: cText(d),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            unit,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cText3(d),
            ),
          ),
        ],
      ),
    );
  }

  List<LatLng>? _arc(AirportDistance distance) {
    final from = distance.from;
    final to = distance.to;
    if (from == null || to == null) return null;
    if (!from.hasPosition || !to.hasPosition) return null;
    return fGreatCircle(
      LatLng(from.lat!, from.lon!),
      LatLng(to.lat!, to.lon!),
    );
  }

  Widget _map(AirportDistance distance) {
    final arc = _arc(distance)!;
    final from = distance.from!;
    final to = distance.to!;
    return FMapFrame(
      height: 170,
      map: FFlightMap(
        routes: [FMapRoute(all: arc)],
        airports: [
          FMapAirport(point: LatLng(from.lat!, from.lon!), code: from.code),
          FMapAirport(point: LatLng(to.lat!, to.lon!), code: to.code),
        ],
      ),
    );
  }

  /// `2:55` разбирается в «2 saat 55 dəqiqə», но если формат другой — строка
  /// показывается как пришла. Пересчёта здесь нет (§9.2).
  String _flightTime(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DelaySpan.parse(raw);
    if (parsed == null) return raw;
    return fMinutesLong(parsed.value.inMinutes);
  }

  /// «GYD · Bakı, Azərbaycan» — как в прототипе.
  String _place(AirportRef? ref, String? fallback) {
    if (ref == null) return fallback ?? '—';
    final code = ref.code ?? fallback ?? '—';
    final parts = [ref.municipality, ref.name]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList();
    final country = ref.countryCode;
    final where = parts.isEmpty ? null : parts.first;
    if (where == null) return code;
    return country == null ? '$code · $where' : '$code · $where, $country';
  }

  /// Привязка объявления работает по рейсу, а не по маршруту: отсюда путь
  /// идёт на выбор рейса этого направления, уже с заполненными лиманами.
  void _openRoute() {
    final distance = _distance;
    FlightNav.push(
      context,
      LinkRoutePickScreen(
        from: _summaryOf(distance?.from, _from),
        to: _summaryOf(distance?.to, _to),
      ),
    );
  }

  /// Ответ расстояния уже содержит имена и координаты — второго запроса за
  /// теми же данными не нужно.
  AirportSummary? _summaryOf(AirportRef? ref, String? code) {
    final value = ref?.code ?? code;
    if (value == null) return null;
    return AirportSummary(
      code: value,
      iata: ref?.iata,
      icao: ref?.icao,
      name: ref?.name,
      city: ref?.municipality,
      countryCode: ref?.countryCode,
      timeZone: ref?.timeZone,
      lat: ref?.lat,
      lon: ref?.lon,
    );
  }
}
