import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/models/aircraft.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `aircraft/timeline` — путь борта от завода до сегодня.
///
/// Своего запроса у экрана нет: все четыре даты уже лежат в паспорте
/// (§9.5), поэтому сюда приходит готовый объект.
///
/// Любая дата может отсутствовать — такой шаг **убирается целиком**, пустой
/// строки на экране не остаётся. Последний шаг собирается из `age_years`:
/// приходит дробное `6.4`, а человеку показывается «6 yaş 5 ay».
class AircraftTimelineScreen extends StatelessWidget {
  const AircraftTimelineScreen({super.key, required this.aircraft});

  final Aircraft aircraft;

  @override
  Widget build(BuildContext context) {
    final stages = _stages();
    return FlightScaffold(
      title: '${aircraft.registration} · ${ft('aircraft_history', 'Tarixçə')}',
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('timeline_title', 'İstehsal tarix xətti'),
          message: stages.isEmpty
              ? ft('timeline_empty_hero', 'Tarixlər bu təyyarə üçün yoxdur')
              : ft('timeline_hero', 'Zavoddan bu günə qədər {n} mərhələ', {
                  'n': '${stages.length}',
                }),
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            if (stages.isEmpty)
              FCalmEmpty(
                icon: PhosphorIconsFill.calendarBlank,
                title: ft(
                  'timeline_empty',
                  'İstehsal tarixləri göstərilmir',
                ),
                message: ft(
                  'timeline_empty_message',
                  'Bu təyyarə üçün kataloqda zavod tarixləri yoxdur.',
                ),
              )
            else
              FCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < stages.length; i++)
                      FEventRow(
                        icon: stages[i].icon,
                        title: stages[i].title,
                        subtitle: stages[i].value,
                        tone: stages[i].tone,
                        last: i == stages.length - 1,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Шаги в порядке жизни борта. Шага без даты в списке нет.
  List<_Stage> _stages() {
    final out = <_Stage>[];

    void add(String? isoDate, IconData icon, String title) {
      if (isoDate == null || isoDate.isEmpty) return;
      out.add(_Stage(icon: icon, title: title, value: fDateStringLong(isoDate)));
    }

    add(
      aircraft.rolloutDate,
      PhosphorIconsFill.factory,
      ft('timeline_rollout', 'Zavoddan çıxış'),
    );
    add(
      aircraft.firstFlightDate,
      PhosphorIconsFill.airplaneTakeoff,
      ft('timeline_first_flight', 'İlk uçuş'),
    );
    add(
      aircraft.deliveryDate,
      PhosphorIconsFill.handshake,
      ft('timeline_delivery', 'Təslim'),
    );
    add(
      aircraft.registrationDate,
      PhosphorIconsFill.identificationBadge,
      ft('timeline_registration', 'Qeydiyyat'),
    );

    final age = aircraft.ageYears;
    if (age != null) {
      out.add(_Stage(
        icon: PhosphorIconsFill.circleDashed,
        title: ft('timeline_today', 'Bu gün'),
        value: fAircraftAge(age),
        tone: FTone.info,
      ));
    }
    return out;
  }
}

class _Stage {
  const _Stage({
    required this.icon,
    required this.title,
    required this.value,
    this.tone = FTone.mute,
  });

  final IconData icon;
  final String title;
  final String value;
  final FTone tone;
}
