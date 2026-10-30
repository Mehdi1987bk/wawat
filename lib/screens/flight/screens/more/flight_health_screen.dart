import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight_watch.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_feed_visual.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// Что сейчас с потоками данных (`GET /flight-data/health`).
///
/// Открывается с полоски «Canlı məlumat məhdud işləyir» на домашнем экране
/// модуля: вместо общей фразы человек видит, какой именно поток лежит и
/// почему время показано по расписанию.
class FlightHealthScreen extends StatefulWidget {
  const FlightHealthScreen({super.key});

  @override
  State<FlightHealthScreen> createState() => _FlightHealthScreenState();
}

class _FlightHealthScreenState extends State<FlightHealthScreen> {
  final _repo = FlightRepository.instance;

  FlightDataHealth? _health;
  FlightError? _error;
  bool _loading = true;

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
      final result = await _repo.health(force: force);
      if (!mounted) return;
      setState(() {
        _health = result.data;
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
      title: ft('health_title', 'Məlumat mənbələri'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('health_hero', 'Canlı məlumat necə işləyir'),
          message: ft(
            'health_hero_message',
            'Cədvəl, canlı status və təyyarə mövqeyi ayrı-ayrı mənbələrdən '
                'gəlir. Biri işləməyəndə qalanı göstərilir.',
          ),
        ),
      ),
      slivers: [
        if (_loading)
          const FlightBody(children: [FCardSkeleton(rows: 3)])
        else if (_error != null)
          FlightBody(
            children: [
              FErrorView(error: _error!, onRetry: () => _load(force: true)),
            ],
          )
        else
          FlightBody(children: _content()),
      ],
    );
  }

  List<Widget> _content() {
    final health = _health;
    if (health == null) {
      return [
        FCalmEmpty(
          title: ft('health_empty', 'Mənbə vəziyyəti bilinmir'),
          message: ft(
            'health_empty_message',
            'Mənbə sorğusu cavab vermədi. Vaxtlar cədvəl üzrə göstərilir.',
          ),
        ),
      ];
    }
    return [
      if (health.degraded)
        _Strip(
          tone: FTone.warn,
          title: ft('health_degraded', 'Canlı məlumat məhdud işləyir'),
          message: ft(
            'health_degraded_message',
            'Vaxtlar cədvəl üzrə göstərilir. Status dəyişəndə bildiriş '
                'yenə gələcək.',
          ),
        )
      else
        _Strip(
          tone: FTone.ok,
          title: ft('health_ok', 'Bütün mənbələr işləyir'),
          message: ft(
            'health_ok_message',
            'Status və vaxtlar canlı mənbədən gəlir.',
          ),
        ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('health_feeds', 'Mənbələr')),
            const SizedBox(height: 6),
            _feed(
              icon: PhosphorIconsFill.calendarDot,
              name: ft('health_feed_schedules', 'Cədvəllər'),
              hint: ft(
                'health_feed_schedules_hint',
                'Uçuş saatları və marşrutlar',
              ),
              feed: health.schedules,
            ),
            _feed(
              icon: PhosphorIconsFill.broadcast,
              name: ft('health_feed_live', 'Canlı status'),
              hint: ft(
                'health_feed_live_hint',
                'Uçdu, endi, qapı və terminal',
              ),
              feed: health.live,
            ),
            _feed(
              icon: PhosphorIconsFill.airplaneTilt,
              name: ft('health_feed_adsb', 'Təyyarə mövqeyi'),
              hint: ft(
                'health_feed_adsb_hint',
                'Xəritədə canlı nişan — ADS-B',
              ),
              feed: health.adsb,
              last: true,
            ),
          ],
        ),
      ),
      FCard(
        child: Text(
          ft(
            'health_note',
            'Mövqe nişanı yalnız ADS-B siqnalı olan uçuşlarda görünür. '
                'Siqnal yoxdursa, marşrut cədvəl üzrə göstərilir — bu nasazlıq '
                'deyil.',
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.55,
            color: cText2(fDark(context)),
          ),
        ),
      ),
    ];
  }

  Widget _feed({
    required IconData icon,
    required String name,
    required String hint,
    required FeedState feed,
    bool last = false,
  }) {
    final d = fDark(context);
    final tone = fFeedVisual(feed.status).tone;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: cLine(d))),
            ),
      child: Row(
        children: [
          FIconChip(icon: icon, background: tone.bg(d), color: tone.fg(d)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                Text(
                  hint,
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
          FBadge(fFeedVisual(feed.status).label, tone: tone, fontSize: 10),
        ],
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.tone, required this.title, required this.message});

  final FTone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      decoration: BoxDecoration(
        color: tone.bg(d),
        borderRadius: FT.rField,
        border: Border.all(color: cLine(d)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.warningCircle, size: 17, color: tone.fg(d)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: cText2(d),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
