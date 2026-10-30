import 'package:flutter/material.dart';

import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_widgets.dart';

/// `flight/statuses` — словарь статусов.
///
/// Тринадцать значений `status` (§8) с иконкой, цветом и объяснением. В
/// прототипе часть строк ведёт на демонстрационные экраны; здесь это просто
/// справка: показывать живому человеку выдуманный рейс не нужно.
///
/// Подпись статуса на остальных экранах всегда приходит из `status_label` —
/// этот экран показывает и сырое значение, чтобы совпадало с логами и
/// уведомлениями.
class FlightStatusesScreen extends StatelessWidget {
  const FlightStatusesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('statuses_title', 'Uçuş statusları'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('statuses_hero', '{n} uçuş statusu', {
            'n': '${flightStatusOrder.length}',
          }),
          message: ft(
            'statuses_hero_message',
            'Hər statusun öz rəngi və ikonu var. Mətni server göndərir, rəng '
                'və ikon tətbiqdə seçilir.',
          ),
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            FGroupCard(
              children: [
                for (final status in flightStatusOrder) _row(status),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String status) {
    final visual = fStatusVisual(status);
    return FListRow(
      flat: true,
      icon: visual.icon,
      title: visual.label,
      subtitle: visual.hint,
      showCaret: false,
      trailing: FBadge(status, tone: visual.tone, fontSize: 9),
    );
  }
}
