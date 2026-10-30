import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight_stats.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_feed_visual.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'airport_board_screen.dart';

/// `airport/feeds` — что именно работает у этого аэропорта.
///
/// Единственное место, где человеку объясняют, почему живых данных нет:
/// три потока (`flightSchedulesFeed`, `liveFlightUpdatesFeed`,
/// `adsbUpdatesFeed`) независимы, и у расписания в ответе есть ещё границы
/// доступных дат — их видно только здесь.
///
/// Общий экран состояния (`more/health`) говорит про сервис в целом; этот —
/// про один аэропорт. Слова в бейджах у них одни и те же, из `fFeedVisual`.
class AirportFeedsScreen extends StatefulWidget {
  const AirportFeedsScreen({super.key, required this.code});

  final String code;

  @override
  State<AirportFeedsScreen> createState() => _AirportFeedsScreenState();
}

class _AirportFeedsScreenState extends State<AirportFeedsScreen> {
  final _repo = FlightRepository.instance;

  AirportFeeds? _feeds;
  FlightError? _error;
  String? _stale;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.feeds(widget.code);
      if (!mounted) return;
      setState(() {
        _feeds = result.data;
        _stale = fStaleLineText(result.meta, place: widget.code);
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
      title: ft('airport_feeds_title', '{code} · Data mənbələri', {
        'code': widget.code,
      }),
      stale: _stale,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('feeds_hero', 'Bu limanda nə işləyir'),
          message: ft(
            'feeds_hero_message',
            'Üç axın bir-birindən asılı deyil. Biri sönük olanda digərləri '
                'işləməyə davam edir.',
          ),
        ),
      ),
      slivers: [FlightBody(children: _body())],
    );
  }

  List<Widget> _body() {
    if (_loading) return const [FCardSkeleton(rows: 3)];
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: _load)];
    }
    final feeds = _feeds;
    if (feeds == null) {
      return [
        FCalmEmpty(
          title: ft('feeds_empty', 'Mənbə vəziyyəti bilinmir'),
          message: ft(
            'feeds_empty_message',
            'Mənbə sorğusu cavab vermədi. Lövhə və cədvəl yenə də açılır.',
          ),
        ),
      ];
    }
    return [
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _feed(
              icon: PhosphorIconsFill.calendarDots,
              name: ft('feeds_schedules', 'Cədvəl məlumatı'),
              // У расписания вместо подписи — границы доступных дат: это
              // единственное место в разделе, где они видны.
              hint: _dateRange(feeds.schedules) ??
                  ft('feeds_schedules_hint', 'uçuş saatları və marşrutlar'),
              feed: feeds.schedules,
            ),
            _feed(
              icon: PhosphorIconsFill.broadcast,
              name: ft('feeds_live', 'Canlı yenilənmə'),
              hint: ft('feeds_live_hint', 'real saat, qapı, lent'),
              feed: feeds.live,
            ),
            _feed(
              icon: PhosphorIconsFill.radio,
              name: ft('feeds_adsb', 'ADS-B mövqe'),
              hint: ft('feeds_adsb_hint', 'təyyarənin koordinatı'),
              feed: feeds.adsb,
              last: true,
            ),
          ],
        ),
      ),
      FInfoNote(
        ft(
          'feeds_note',
          'Canlı yenilənmə işləməyəndə status və vaxtlar cədvəldən gəlir. '
              'Qarşı liman canlı veribsə, o tərəfin vaxtları dəqiq olur.',
        ),
      ),
      FSecondaryButton(
        label: ft('feeds_board', 'Lövhəyə keç'),
        icon: PhosphorIconsBold.airplaneTakeoff,
        onTap: () => FlightNav.push(
          context,
          AirportBoardScreen(code: widget.code),
        ),
      ),
    ];
  }

  /// `2025-10-29 → 2027-10-26` — только у расписания, у двух других потоков
  /// этих полей в ответе нет.
  String? _dateRange(FeedInfo feed) {
    final from = feed.minAvailableLocalDate;
    final to = feed.maxAvailableLocalDate;
    if (from == null && to == null) return null;
    return '${_day(from)} → ${_day(to)}';
  }

  String _day(String? raw) {
    if (raw == null) return '—';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? raw : fApiDate(parsed);
  }

  Widget _feed({
    required IconData icon,
    required String name,
    required String hint,
    required FeedInfo feed,
    bool last = false,
  }) {
    final d = fDark(context);
    final visual = fFeedVisual(feed.status);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: cLine(d))),
            ),
      child: Row(
        children: [
          FIconChip(
            icon: icon,
            background: visual.tone.bg(d),
            color: visual.tone.fg(d),
          ),
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
          FBadge(visual.label, tone: visual.tone, fontSize: 10),
        ],
      ),
    );
  }
}
