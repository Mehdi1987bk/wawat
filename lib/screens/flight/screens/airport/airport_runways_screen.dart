import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_feed_visual.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `airport/runways` — по карточке на каждый **конец** полосы.
///
/// В массиве один элемент — это один порог: `name` одиночное («16»), пары
/// «16/34» в API нет. Поэтому и заголовок говорит о головах полос, а не о
/// полосах, а число полос считается здесь — делением на два по парам
/// направлений.
///
/// Тот же массив приходит внутри карточки лимана (`runways[]`), так что
/// отдельный запрос нужен только когда экран открыли без карточки.
class AirportRunwaysScreen extends StatefulWidget {
  const AirportRunwaysScreen({super.key, this.airport, this.code});

  final Airport? airport;
  final String? code;

  @override
  State<AirportRunwaysScreen> createState() => _AirportRunwaysScreenState();
}

class _AirportRunwaysScreenState extends State<AirportRunwaysScreen> {
  final _repo = FlightRepository.instance;

  List<Runway> _runways = const [];
  FlightError? _error;
  bool _loading = false;

  String get _code => widget.airport?.summary.code ?? widget.code ?? '';

  @override
  void initState() {
    super.initState();
    final inline = widget.airport?.runways ?? const <Runway>[];
    if (inline.isNotEmpty) {
      _runways = inline;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    if (_code.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.runways(_code);
      if (!mounted) return;
      setState(() {
        _runways = result.data ?? const [];
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
    return FlightScaffold(
      title: ft('runways_title', '{code} · Zolaqlar', {'code': _code}),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('runways_hero', '{n} zolaq başı', {
            'n': '$_count',
          }),
          message: _heroMessage(),
        ),
      ),
      slivers: [
        FlightBody(gap: 10, children: _body()),
      ],
    );
  }

  /// Заголовок — прямо из `runway_count`, когда он есть: это измеренное
  /// число голов, а не наша догадка.
  int get _count => widget.airport?.runwayCount ?? _runways.length;

  String? _heroMessage() {
    final name = widget.airport?.summary.fullName ??
        widget.airport?.summary.name;
    final closed = _runways.where((r) => r.isClosed).length;
    final pairs = (_count / 2).ceil();
    final strips = pairs == 0
        ? null
        : ft('runways_strips', '{n} uçuş-enmə zolağı', {'n': '$pairs'});
    final state = _runways.isEmpty
        ? null
        : (closed == 0
            ? ft('runways_all_open', 'hamısı açıq')
            : ft('runways_closed', '{n} bağlı', {'n': '$closed'}));
    return [name, strips, state]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' · ');
  }

  List<Widget> _body() {
    if (_loading) return const [FCardSkeleton(rows: 3), FCardSkeleton(rows: 3)];
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: _load)];
    }
    if (_runways.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.roadHorizon,
          title: ft('runways_empty', 'Zolaq məlumatı gəlmir'),
          message: ft(
            'runways_empty_message',
            'Mənbə bu liman üçün zolaq ölçülərini vermir.',
          ),
        ),
      ];
    }
    return [for (final runway in _runways) _card(runway)];
  }

  Widget _card(Runway runway) {
    final d = fDark(context);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                runway.name ?? '—',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: cText(d),
                ),
              ),
              const SizedBox(width: 8),
              FBadge(
                runway.isClosed
                    ? ft('runway_closed', 'BAĞLI')
                    : ft('runway_open', 'AÇIQ'),
                tone: runway.isClosed ? FTone.bad : FTone.ok,
                fontSize: 9,
              ),
              const Spacer(),
              if (runway.trueHeading != null)
                Text(
                  '${runway.trueHeading}°',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cText3(d),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 11),
          _strip(runway),
          const SizedBox(height: 11),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (runway.lengthM != null)
                FBadge(fMeters(runway.lengthM), tone: FTone.mute, fontSize: 9.5),
              if (runway.widthM != null)
                FBadge(fMeters(runway.widthM), tone: FTone.mute, fontSize: 9.5),
              FBadge(
                fRunwaySurface(runway.surface),
                tone: FTone.mute,
                fontSize: 9.5,
              ),
              FBadge(
                runway.hasLighting
                    ? ft('runway_lit', 'İşıqlı')
                    : ft('runway_unlit', 'İşıqsız'),
                tone: runway.hasLighting ? FTone.ok : FTone.mute,
                icon: runway.hasLighting ? PhosphorIconsFill.lightbulb : null,
                fontSize: 9.5,
              ),
              if (runway.displacedThresholdM != null &&
                  runway.displacedThresholdM! > 0)
                FBadge(
                  ft('runway_displaced', 'astana {n} sürüşdürülüb', {
                    'n': fMeters(runway.displacedThresholdM),
                  }),
                  tone: FTone.warn,
                  fontSize: 9.5,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Полоса как картинка: направление головы показано стрелкой.
  Widget _strip(Runway runway) {
    final d = fDark(context);
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: FT.chip(d),
        borderRadius: FT.rSoft,
        border: Border.all(color: FT.chipBorder(d)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            runway.name ?? '',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: cText2(d),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    for (var i = 0; i < (constraints.maxWidth / 14).floor(); i++)
                      Container(
                        width: 8,
                        height: 2,
                        margin: const EdgeInsets.only(right: 6),
                        color: cFaint(d),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Icon(PhosphorIconsBold.arrowRight, size: 13, color: cText3(d)),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
