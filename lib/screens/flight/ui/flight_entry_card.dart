import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/flight_repository.dart';
import '../flight_routes.dart';
import '../flight_text.dart';
import 'flight_tokens.dart';
import 'flight_widgets.dart';

/// Вход в раздел рейсов с главной вкладки.
///
/// Счётчик отслеживаемых рейсов берётся **только из кэша**: карточка висит на
/// главной и своего запроса не делает — иначе каждый вход в приложение тратил
/// бы минутный бюджет раздела до того, как человек вообще туда собрался.
class FlightEntryCard extends StatelessWidget {
  const FlightEntryCard({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final watchCount = FlightRepository.instance.cachedWatchCount ?? 0;
    return Padding(
      padding: margin,
      child: InkWell(
        onTap: () => FlightNav.open(context),
        borderRadius: FT.rCard,
        child: ClipRRect(
          borderRadius: FT.rCard,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: FT.rCard,
              boxShadow: FT.brandShadow(d),
            ),
            child: FSky(
              background: FT.brand,
              rings: const [
                FSkyRing(170, -40, -50),
                FSkyRing(270, -90, -100),
              ],
              sweep: const FSkyRing(220, -60, -70),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FBadge(
                        ft('entry_new', 'YENİ'),
                        icon: PhosphorIconsFill.globeHemisphereEast,
                        background: Colors.white.withValues(alpha: .22),
                        foreground: Colors.white,
                      ),
                      if (watchCount > 0) ...[
                        const SizedBox(width: 7),
                        FBadge(
                          ft(
                            'home_watch_count',
                            '{n} izlədiyin uçuş',
                            {'n': '$watchCount'},
                          ),
                          icon: PhosphorIconsFill.bellRinging,
                          background: Colors.white.withValues(alpha: .22),
                          foreground: Colors.white,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ft('entry_title', 'Uçuş radarı'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ft(
                      'entry_message',
                      'Uçuşu izlə, gecikməni əvvəlcədən bil, elanını uçuşa '
                          'bağla.',
                    ),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      color: FT.onHero(.8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        ft('entry_action', 'Radarı aç'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Icon(
                        PhosphorIconsBold.arrowRight,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
