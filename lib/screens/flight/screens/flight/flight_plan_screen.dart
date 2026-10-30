import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/models/flight.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `flight/plan` — полётный план.
///
/// Данные из `/detail`, блок `flight_plan`. Он приходит редко: у бакинских
/// рейсов его нет вовсе, поэтому на карточку рейса ссылка ставится только
/// когда есть маршрут — пустого экрана быть не должно.
///
/// Эшелон и скорость показываются в двух единицах сразу: план аэронавигации
/// живёт в футах и узлах, а приложение — в метрах и километрах.
class FlightPlanScreen extends StatelessWidget {
  const FlightPlanScreen({super.key, required this.detail});

  final FlightDetail detail;

  FlightPlan? get _plan => detail.flightPlan;

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final callSign = detail.callSign;
    final numbers = [detail.displayNumber, callSign]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' · ');

    return FlightScaffold(
      title: ft('plan_title', 'Uçuş planı'),
      subtitle: detail.displayNumber,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final badge in [plan?.status, plan?.rules, plan?.type]
                    .whereType<String>()
                    .where((e) => e.isNotEmpty))
                  FBadge(
                    badge,
                    background: Colors.white.withValues(alpha: .16),
                    foreground: Colors.white,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              numbers,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'monospace',
                fontFamilyFallback: ['Menlo', 'Courier'],
              ),
            ),
            if (plan?.revision != null || plan?.updatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  [
                    if (plan?.revision != null)
                      ft('plan_revision_short', 'Revizyon #{n}', {
                        'n': '${plan!.revision}',
                      }),
                    if (plan?.updatedAt != null)
                      ft('plan_updated_short', '{time}-də yeniləndi', {
                        'time': fClock(plan!.updatedAt),
                      }),
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: FT.onHero(.6),
                  ),
                ),
              ),
          ],
        ),
      ),
      slivers: [
        FlightBody(children: _body(context)),
      ],
    );
  }

  List<Widget> _body(BuildContext context) {
    final d = fDark(context);
    final plan = _plan;
    if (plan == null) {
      return [
        FInfoNote(
          ft(
            'plan_absent',
            'Bu uçuş üçün uçuş planı gəlmir. Bu normaldır: planı yalnız bəzi '
                'hava məkanları açıq göndərir.',
          ),
        ),
      ];
    }
    final waypoints = plan.waypoints;
    return [
      if (plan.hasRoute)
        FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FCardTitle(ft('plan_route', 'Marşrut')),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FT.chip(d),
                  borderRadius: FT.rSoft,
                  border: Border.all(color: FT.chipBorder(d)),
                ),
                child: Text(
                  plan.route!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                    color: cText(d),
                    fontFamily: 'monospace',
                    fontFamilyFallback: const ['Menlo', 'Courier'],
                  ),
                ),
              ),
              if (waypoints.length > 1) ...[
                const SizedBox(height: 11),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final point in waypoints)
                      FBadge(point, fontSize: 10),
                  ],
                ),
              ],
            ],
          ),
        ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FRow(ft('plan_rules', 'Uçuş qaydaları'), value: plan.rules),
            FRow(ft('plan_type', 'Uçuş tipi'), value: plan.type),
            FRow(
              ft('plan_level', 'Planlanan eşelon'),
              value: _level(plan.altitudeFt),
            ),
            FRow(
              ft('plan_speed', 'Planlanan sürət'),
              value: _speed(plan.airspeedKt),
            ),
            FRow(
              ft('plan_revision', 'Revizyon'),
              value: plan.revision == null ? null : '#${plan.revision}',
            ),
            FRow(
              ft('plan_updated', 'Son yenilənmə'),
              value: plan.updatedAt == null ? null : fClock(plan.updatedAt),
              last: true,
            ),
          ],
        ),
      ),
      FInfoNote(
        ft(
          'plan_note',
          'Plan uçuşa qədər bir neçə dəfə dəyişə bilər: hər dəyişiklik yeni '
              'revizyon nömrəsi alır.',
        ),
        icon: PhosphorIconsFill.listBullets,
      ),
    ];
  }

  /// `FL370 · 11 277 m`
  String? _level(int? feet) {
    if (feet == null) return null;
    return '${fFlightLevel(feet)} · ${fMeters((feet * 0.3048).round())}';
  }

  /// `458 kts · 848 km/s`
  String? _speed(int? knots) {
    if (knots == null) return null;
    return '${fNum(knots)} ${ft('unit_kt', 'kts')} · '
        '${fSpeed((knots * 1.852).round())}';
  }
}
