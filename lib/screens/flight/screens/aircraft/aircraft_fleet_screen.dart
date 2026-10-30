import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_envelope.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/aircraft.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'aircraft_passport_screen.dart';

/// `aircraft/fleet` — парк авиакомпании по моделям.
///
/// `GET /airlines/{kod}/fleet` отдаёт ответ провайдера как есть: camelCase,
/// `offset` вместо номера страницы и `hasNextPage` вместо общего числа
/// страниц. Разбивки по моделям и счёта «19 пассажирских / 2 грузовых» в
/// ответе нет — и то и другое считается здесь, по `items[]` (§9.5).
///
/// Поэтому страницы догружаются до `hasNextPage == false`: по половине парка
/// группы вышли бы неверными. Чтобы один вход на экран не съел минутный
/// бюджет (§4.4), за раз берётся [_maxPages] страниц по сто бортов, а
/// остаток человек догружает кнопкой — у AZAL весь парк умещается в первую
/// страницу.
///
/// Отличие от прототипа (§16): в макете строка модели ведёт сразу в паспорт
/// борта, хотя в группе их двенадцать и какой из них открыть — непонятно.
/// Здесь строка раскрывается на месте и показывает свои борта, каждый со
/// своим паспортом.
class AircraftFleetScreen extends StatefulWidget {
  const AircraftFleetScreen({
    super.key,
    required this.airlineCode,
    this.airlineName,
  });

  /// IATA или ICAO компании — эндпоинт принимает оба.
  final String airlineCode;
  final String? airlineName;

  @override
  State<AircraftFleetScreen> createState() => _AircraftFleetScreenState();
}

class _AircraftFleetScreenState extends State<AircraftFleetScreen> {
  /// Сколько страниц берётся за один заход. Сто бортов на страницу — верхний
  /// предел `per_page`.
  static const _perPage = 100;
  static const _maxPages = 6;

  final _repo = FlightRepository.instance;

  final _items = <FleetItem>[];
  int? _totalCount;
  int _offset = 0;
  bool _hasNext = false;
  FlightMeta _meta = FlightMeta.empty;

  FlightError? _error;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _items.clear();
      _offset = 0;
      _hasNext = false;
    });
    await _fetch(pages: _maxPages);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _more() async {
    setState(() => _loadingMore = true);
    await _fetch(pages: _maxPages);
    if (mounted) setState(() => _loadingMore = false);
  }

  /// Тянет страницы подряд, пока сервер говорит, что есть ещё, и пока не
  /// кончился разрешённый на один заход запас.
  Future<void> _fetch({required int pages}) async {
    for (var i = 0; i < pages; i++) {
      try {
        final envelope = await _repo.fleet(
          widget.airlineCode,
          perPage: _perPage,
          offset: _offset,
        );
        final page = envelope.data;
        if (!mounted) return;
        _meta = envelope.meta;
        if (page == null) {
          _hasNext = false;
          return;
        }
        _items.addAll(page.items);
        _totalCount = page.totalCount ?? _totalCount;
        _offset += page.items.isEmpty ? _perPage : page.items.length;
        _hasNext = page.hasNextPage && page.items.isNotEmpty;
        if (!_hasNext) return;
      } catch (e) {
        if (!mounted) return;
        // Уже загруженное на экране остаётся: половина парка полезнее
        // пустого экрана с ошибкой.
        if (_items.isEmpty) _error = FlightError.from(e);
        _hasNext = false;
        return;
      }
    }
  }

  String get _airline => widget.airlineName ?? widget.airlineCode;

  int get _passenger => _items.where((item) => !item.isFreighter).length;
  int get _cargo => _items.where((item) => item.isFreighter).length;

  @override
  Widget build(BuildContext context) {
    final groups = _groups();
    return FlightScaffold(
      title: ft('fleet_title', '{airline} filosu', {
        'airline': widget.airlineName ?? widget.airlineCode,
      }),
      stale: fStaleLineText(_meta),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _loading ? '—' : '${_totalCount ?? _items.length}',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                height: 1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ft('fleet_hero', '{airline} · filodakı təyyarə', {
                'airline': _airline,
              }),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: FT.onHero(.78),
              ),
            ),
            if (!_loading && _items.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  FBadge(
                    ft('fleet_loaded', '{n} / {total} yükləndi', {
                      'n': '${_items.length}',
                      'total': '${_totalCount ?? _items.length}',
                    }),
                    icon: _hasNext
                        ? PhosphorIconsFill.dotsThreeCircle
                        : PhosphorIconsFill.checkCircle,
                    background: FT.heroBadgeBg(
                      _hasNext ? FTone.warn : FTone.ok,
                    ),
                    foreground: FT.heroBadgeFg(
                      _hasNext ? FTone.warn : FTone.ok,
                    ),
                  ),
                  if (_passenger > 0)
                    FBadge(
                      ft('fleet_passenger', '{n} sərnişin', {
                        'n': '$_passenger',
                      }),
                      background: FT.heroBadgeBg(FTone.mute),
                      foreground: FT.heroBadgeFg(FTone.mute),
                    ),
                  if (_cargo > 0)
                    FBadge(
                      ft('fleet_cargo', '{n} yük', {'n': '$_cargo'}),
                      background: FT.heroBadgeBg(FTone.mute),
                      foreground: FT.heroBadgeFg(FTone.mute),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      slivers: [
        FlightBody(children: _body(groups)),
      ],
    );
  }

  List<Widget> _body(List<_Group> groups) {
    if (_loading) return const [FListSkeleton(rows: 5)];

    final error = _error;
    if (error != null) {
      return [
        FErrorView(
          error: error,
          onRetry: _load,
          notFoundTitle: ft('fleet_not_found', 'Belə aviaşirkət yoxdur'),
          notFoundMessage: ft(
            'fleet_not_found_message',
            'Bu kodla şirkət tapılmadı. IATA (J2) və ya ICAO (AHY) kodunu '
                'yoxla.',
          ),
        ),
      ];
    }

    if (groups.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.airplaneInFlight,
          title: ft('fleet_empty', 'Filo göstərilmir'),
          message: ft(
            'fleet_empty_message',
            'Bu şirkət üçün təyyarə siyahısı kataloqda yoxdur.',
          ),
        ),
      ];
    }

    return [
      for (final group in groups) _GroupCard(group: group, airline: _airline),
      if (_hasNext)
        FPrimaryButton(
          label: ft('fleet_more', 'Daha çox yüklə'),
          icon: PhosphorIconsBold.arrowDown,
          loading: _loadingMore,
          onTap: _loadingMore ? null : _more,
        )
      else
        FInfoNote(
          ft('fleet_all_loaded', 'Bütün filo yükləndi — {n} model', {
            'n': '${groups.length}',
          }),
          icon: PhosphorIconsFill.checkCircle,
        ),
    ];
  }

  /// Группировка по модели — её в ответе нет, считается здесь. Внутри группы
  /// борта идут по номеру, сами группы — от большой к малой.
  List<_Group> _groups() {
    final map = <String, List<FleetItem>>{};
    for (final item in _items) {
      final name = item.model ??
          item.typeName ??
          item.modelCode ??
          ft('aircraft_unknown_model', 'Model bilinmir');
      map.putIfAbsent(name, () => <FleetItem>[]).add(item);
    }
    final out = map.entries.map((entry) {
      final items = [...entry.value]..sort(
          (a, b) => (a.reg ?? '').compareTo(b.reg ?? ''),
        );
      return _Group(model: entry.key, items: items);
    }).toList();
    out.sort((a, b) {
      final byCount = b.items.length.compareTo(a.items.length);
      return byCount != 0 ? byCount : a.model.compareTo(b.model);
    });
    return out;
  }
}

class _Group {
  _Group({required this.model, required this.items});

  final String model;
  final List<FleetItem> items;

  bool get allCargo => items.every((item) => item.isFreighter);

  /// «4K-AZ81 · 4K-AZ82 · 4K-AZ83 …» — первые три номера группы.
  String get sample {
    final regs = items
        .map((item) => item.reg)
        .whereType<String>()
        .take(3)
        .toList();
    if (regs.isEmpty) return '';
    final line = regs.join(' · ');
    return items.length > regs.length ? '$line …' : line;
  }
}

/// Строка модели. Свёрнутая выглядит как в прототипе; раскрытая показывает
/// борта группы, потому что «открыть паспорт» без выбора борта смысла не
/// имеет.
class _GroupCard extends StatefulWidget {
  const _GroupCard({required this.group, required this.airline});

  final _Group group;
  final String airline;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final group = widget.group;
    final subtitle = [
      group.sample,
      if (group.allCargo) ft('fleet_cargo_mark', 'yük'),
    ].where((part) => part.isNotEmpty).join(' — ');

    return FCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: () => setState(() => _open = !_open),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FIconChip(
                icon: PhosphorIconsFill.airplane,
                size: 34,
                iconSize: 15,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.model,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: cText(d),
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: cText3(d),
                            fontFamily: 'monospace',
                            fontFamilyFallback: const ['Menlo', 'Courier'],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${group.items.length}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: cText(d),
                    ),
                  ),
                  Text(
                    ft('fleet_unit', 'ədəd'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cText3(d),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(
                _open
                    ? PhosphorIconsBold.caretUp
                    : PhosphorIconsBold.caretDown,
                size: 13,
                color: cMuted(d),
              ),
            ],
          ),
          if (_open) ...[
            const SizedBox(height: 8),
            Container(height: 1, color: cLine(d)),
            for (var i = 0; i < group.items.length; i++)
              _ItemRow(
                item: group.items[i],
                airline: widget.airline,
                last: i == group.items.length - 1,
              ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.airline,
    required this.last,
  });

  final FleetItem item;
  final String airline;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final reg = item.reg;
    final meta = [
      if (item.ageYears != null) fAircraftAge(item.ageYears!),
      if (item.numSeats != null)
        ft('fleet_seats', '{n} oturacaq', {'n': '${item.numSeats}'}),
      if (item.isFreighter) ft('aircraft_freighter', 'Yük təyyarəsi'),
      if (!item.active) ft('aircraft_inactive', 'Qeyri-aktiv'),
    ].join(' · ');

    return InkWell(
      onTap: reg == null
          ? null
          : () => FlightNav.push(
                context,
                AircraftPassportScreen(
                  registration: reg,
                  airlineName: item.airlineName ?? airline,
                ),
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: last
            ? null
            : BoxDecoration(
                border: Border(bottom: BorderSide(color: cLine(d))),
              ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reg ?? '—',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .3,
                      color: cText(d),
                      fontFamily: 'monospace',
                      fontFamilyFallback: const ['Menlo', 'Courier'],
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
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: cText3(d),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (reg != null)
              Icon(
                PhosphorIconsBold.caretRight,
                size: 13,
                color: cMuted(d),
              ),
          ],
        ),
      ),
    );
  }
}
