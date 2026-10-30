import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
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
import '../search/nearby_screen.dart';
import 'airport_card_screen.dart';

/// Список аэропортов. Он же выбор аэропорта: с `picker: true` экран
/// возвращает выбранный аэропорт, а не открывает его карточку.
///
/// Поиск живёт здесь же: `/airports/search` зовётся не раньше двух символов
/// и не чаще раза в 400 мс (§4.4). Пустой запрос показывает подборку
/// `/airports` — её можно долистывать, но запрос при этом не повторяется:
/// у эндпоинта есть только `limit`, страниц нет.
class AirportListScreen extends StatefulWidget {
  const AirportListScreen({
    super.key,
    this.picker = false,
    this.title,
  });

  final bool picker;
  final String? title;

  @override
  State<AirportListScreen> createState() => _AirportListScreenState();
}

enum _Scope { all, saved }

class _AirportListScreenState extends State<AirportListScreen> {
  static const _pageStep = 10;
  static const _fetchLimit = 60;

  final _repo = FlightRepository.instance;
  final _store = FlightLocalStore.instance;
  final _controller = TextEditingController();

  Timer? _debounce;
  int _queryId = 0;

  List<AirportSummary> _all = const [];
  List<AirportSummary> _found = const [];
  String _query = '';
  _Scope _scope = _Scope.all;
  int _shown = _pageStep;
  bool _loading = true;
  bool _searching = false;
  FlightError? _error;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
    _store.load();
    _load();
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

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.airports(limit: _fetchLimit, force: force);
      if (!mounted) return;
      setState(() {
        _all = result.data ?? const [];
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

  void _onQueryChanged(String raw) {
    final query = raw.trim();
    _debounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _query = query;
        _found = const [];
        _searching = false;
      });
      return;
    }
    setState(() {
      _query = query;
      _searching = true;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    final id = ++_queryId;
    try {
      final result = await _repo.searchAirports(query, limit: 25);
      if (!mounted || id != _queryId) return;
      setState(() {
        _found = result.data ?? const [];
        _searching = false;
      });
    } catch (e) {
      if (!mounted || id != _queryId) return;
      setState(() {
        _searching = false;
        _error = FlightError.from(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return FlightScaffold(
      title: widget.title ?? ft('airports_title', 'Hava limanları'),
      section: widget.picker ? null : FlightSection.airports,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: FHeroSearchField(
          controller: _controller,
          hint: ft('airports_search_hint', 'Liman adı və ya kodu'),
          onChanged: _onQueryChanged,
          autofocus: widget.picker,
        ),
      ),
      slivers: [
        FlightBody(
          gap: 0,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FBadge(
                    ft('airports_nearby', 'Yaxınlıqda'),
                    icon: PhosphorIconsFill.crosshair,
                    onTap: () => FlightNav.push(
                      context,
                      NearbyScreen(picker: widget.picker),
                    ).then(_handlePicked),
                  ),
                  const SizedBox(width: 6),
                  _scopeChip(_Scope.all, ft('airports_scope_all', 'Hamısı')),
                  const SizedBox(width: 6),
                  _scopeChip(
                    _Scope.saved,
                    ft('airports_scope_saved', 'Seçilmiş'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._list(d),
          ],
        ),
      ],
    );
  }

  Widget _scopeChip(_Scope scope, String label) {
    final d = fDark(context);
    final on = _scope == scope;
    return InkWell(
      onTap: () => setState(() {
        _scope = scope;
        _shown = _pageStep;
      }),
      borderRadius: FT.rPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: on ? FT.brand : FT.chip(d),
          borderRadius: FT.rPill,
          border: Border.all(color: on ? FT.brand : FT.chipBorder(d)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: on ? Colors.white : cText2(d),
          ),
        ),
      ),
    );
  }

  List<Widget> _list(bool d) {
    if (_loading) return const [FListSkeleton()];
    if (_error != null && _all.isEmpty) {
      return [
        FErrorView(error: _error!, onRetry: () => _load(force: true)),
      ];
    }

    final searching = _query.length >= 2;
    if (searching && _searching && _found.isEmpty) {
      return const [FListSkeleton(rows: 3)];
    }

    final items = searching
        ? _found
        : (_scope == _Scope.saved
            ? _all
                .where((a) => _store.isSaved(a.code))
                .toList()
            : _all);

    if (items.isEmpty) {
      if (searching) {
        return [
          FEmptyResult(
            title: ft('airports_empty', 'Belə liman tapılmadı'),
            message: ft(
              'airports_empty_message',
              'Adı başqa cür yaz və ya IATA kodunu sına: GYD, IST, DXB.',
            ),
          ),
        ];
      }
      if (_scope == _Scope.saved) {
        return [
          FEmptyResult(
            icon: PhosphorIconsFill.bookmarkSimple,
            title: ft('airports_saved_empty', 'Seçilmiş liman yoxdur'),
            message: ft(
              'airports_saved_empty_message',
              'Siyahıdakı ulduza toxun — liman burada saxlanacaq. '
                  'Yalnız bu cihazda.',
            ),
            actions: [
              FSecondaryButton(
                label: ft('airports_scope_all', 'Hamısı'),
                onTap: () => setState(() => _scope = _Scope.all),
              ),
            ],
          ),
        ];
      }
      return [
        FCalmEmpty(
          title: ft('airports_none', 'Liman siyahısı boşdur'),
          message: ft(
            'airports_none_message',
            'Mənbə bu dəfə siyahı vermədi. Axtarışla tap: GYD, IST, DXB.',
          ),
        ),
      ];
    }

    final limit = searching ? items.length : _shown.clamp(0, items.length);
    final shown = items.take(limit).toList();
    return [
      Row(
        children: [
          Expanded(
            child: Text(
              searching
                  ? ft('airports_found', 'Tapıldı')
                  : ft('airports_title_short', 'Limanlar'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cText(d),
              ),
            ),
          ),
          Text(
            ft('shown_count', '{n} göstərilir', {'n': '${shown.length}'}),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: cText3(d),
            ),
          ),
        ],
      ),
      const SizedBox(height: 9),
      for (var i = 0; i < shown.length; i++) ...[
        if (i != 0) const SizedBox(height: 9),
        AirportRow(
          airport: shown[i],
          saved: _store.isSaved(shown[i].code),
          onStar: () => _store.toggleAirport(shown[i].code),
          onTap: () => _openAirport(shown[i]),
        ),
      ],
      if (!searching && limit < items.length)
        InkWell(
          onTap: () => setState(() => _shown += _pageStep),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsRegular.dotsThreeOutline,
                  size: 15,
                  color: cText3(d),
                ),
                const SizedBox(width: 7),
                Text(
                  ft('load_more', 'Daha çox yüklə'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cText3(d),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  void _openAirport(AirportSummary airport) {
    if (widget.picker) {
      Navigator.of(context).pop(airport);
      return;
    }
    FlightNav.push(context, AirportCardScreen(code: airport.code));
  }

  /// Выбор мог случиться на экране «Yaxınlıqda» — тогда он возвращается
  /// дальше, вызывавшему.
  void _handlePicked(Object? picked) {
    if (!mounted || !widget.picker || picked is! AirportSummary) return;
    Navigator.of(context).pop(picked);
  }
}

/// Строка аэропорта: код, название, флаг с городом и ICAO.
class AirportRow extends StatelessWidget {
  const AirportRow({
    super.key,
    required this.airport,
    required this.onTap,
    this.saved = false,
    this.onStar,
    this.trailing,
  });

  final AirportSummary airport;
  final VoidCallback onTap;
  final bool saved;
  final VoidCallback? onStar;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final place = [
      if ((airport.city ?? '').isNotEmpty) airport.city,
      if ((airport.country ?? '').isNotEmpty) airport.country,
    ].whereType<String>().join(', ');
    final flag = fFlag(airport.countryCode);
    return FCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          AirportCodeChip(code: airport.iata ?? airport.code),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        airport.name ?? airport.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: cText(d),
                        ),
                      ),
                    ),
                    if (onStar != null) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onStar,
                        borderRadius: FT.rPill,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            saved
                                ? PhosphorIconsFill.star
                                : PhosphorIconsRegular.star,
                            size: 13,
                            color: saved ? FT.accent : cText3(d),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (flag.isNotEmpty) ...[
                      Text(flag, style: const TextStyle(fontSize: 11.5)),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        airport.icao == null
                            ? place
                            : '$place · ${airport.icao}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: cText3(d),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              Icon(PhosphorIconsBold.caretRight, size: 14, color: cText3(d)),
        ],
      ),
    );
  }
}

/// Квадрат с кодом аэропорта — он же аватар аэропорта во всём разделе.
class AirportCodeChip extends StatelessWidget {
  const AirportCodeChip({super.key, required this.code, this.size = 44});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: FT.brand50(d),
        borderRadius: FT.rIcon,
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: TextStyle(
          fontSize: size <= 36 ? 11 : 13,
          fontWeight: FontWeight.w700,
          color: FT.brand600(d),
        ),
      ),
    );
  }
}
