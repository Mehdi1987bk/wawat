import 'package:flutter/material.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_widgets.dart';

/// `more/about` — откуда берутся данные.
///
/// Запросов нет: экран статический. Он закрывает условие поставщиков —
/// данные о рейсах подписаны AeroDataBox, подложка карты — Esri и
/// OpenStreetMap (§9.9).
class MoreAboutScreen extends StatelessWidget {
  const MoreAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('about_title', 'Mənbə və lisenziyalar'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('about_hero', 'Məlumat haradan gəlir?'),
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            _block(
              context,
              title: ft('about_data', 'Uçuş məlumatı'),
              text: ft(
                'about_data_text',
                'Uçuş cədvəlləri, statuslar, təyyarə mövqeyi və hava limanı '
                    'məlumatı AeroDataBox-dan gəlir.',
              ),
            ),
            _block(
              context,
              title: ft('about_map', 'Xəritə'),
              text: ft(
                'about_map_text',
                'Xəritə təsviri Esri və OpenStreetMap iştirakçılarının '
                    'töhfəsidir.',
              ),
            ),
            _block(
              context,
              text: ft(
                'about_disclaimer',
                'Uçuş vaxtları hava limanlarının öz məlumatına əsaslanır və '
                    'dəyişə bilər. Rəsmi məlumat üçün aviaşirkətə müraciət et.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _block(BuildContext context, {String? title, required String text}) {
    final d = fDark(context);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            FCardTitle(title),
            const SizedBox(height: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.55,
              color: cText2(d),
            ),
          ),
        ],
      ),
    );
  }
}
