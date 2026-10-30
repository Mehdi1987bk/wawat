import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/models/aircraft.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `aircraft/registrations` — под какими номерами борт летал.
///
/// Запроса нет: `registrations[]` приходит внутри паспорта (§9.5). Отдельный
/// эндпоинт `/aircraft/{reg}/registrations` существует, но отдаёт **другой**
/// формат (camelCase провайдера) — смешивать их нельзя, и лишний запрос здесь
/// не нужен.
///
/// Конца периода («— 21 may 2020») в ответе нет: он берётся из даты
/// следующей, более новой регистрации. У самой новой конца нет — «indi».
class AircraftRegistrationsScreen extends StatelessWidget {
  const AircraftRegistrationsScreen({super.key, required this.aircraft});

  final Aircraft aircraft;

  @override
  Widget build(BuildContext context) {
    final rows = _sorted();
    return FlightScaffold(
      title:
          '${aircraft.registration} · ${ft('aircraft_regs', 'Qeydiyyat')}',
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: rows.isEmpty
              ? ft('regs_empty_title', 'Qeydiyyat zənciri yoxdur')
              : ft('regs_count', '{n} qeydiyyat', {'n': '${rows.length}'}),
          message: ft('regs_hero', 'Bu təyyarə hansı nömrələrlə uçub'),
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            if (rows.isEmpty)
              FCalmEmpty(
                icon: PhosphorIconsFill.identificationCard,
                title: ft('regs_empty', 'Qeydiyyat tarixçəsi göstərilmir'),
                message: ft(
                  'regs_empty_message',
                  'Kataloqda bu təyyarənin keçmiş nömrələri yoxdur.',
                ),
              )
            else
              FCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      _Row(
                        registration: rows[i],
                        // Конец периода — начало следующей, более новой
                        // записи. Для самой новой периода конца нет.
                        until: i == 0 ? null : rows[i - 1].registeredOn,
                        last: i == rows.length - 1,
                      ),
                  ],
                ),
              ),
            if (aircraft.modeS != null) _modeSNote(context),
          ],
        ),
      ],
    );
  }

  /// От новых к старым: в ответе порядок не обещан, а экран читается только
  /// сверху вниз по времени.
  List<AircraftRegistration> _sorted() {
    final rows = [...aircraft.registrations];
    rows.sort((a, b) {
      final left = a.registeredOn;
      final right = b.registeredOn;
      if (left == null && right == null) return 0;
      if (left == null) return 1;
      if (right == null) return -1;
      return right.compareTo(left);
    });
    return rows;
  }

  /// Пояснение из прототипа: номер меняется при продаже, Mode-S — нет.
  Widget _modeSNote(BuildContext context) {
    final d = fDark(context);
    return FCard(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FIconChip(
            icon: PhosphorIconsRegular.info,
            size: 30,
            iconSize: 14,
            color: cText2(d),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ft(
                      'regs_note_1',
                      'Təyyarə başqa şirkətə satılanda qeydiyyat nişanı '
                          'dəyişir. Mode-S kodu (',
                    ),
                  ),
                  TextSpan(
                    text: aircraft.modeS,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontFamilyFallback: ['Menlo', 'Courier'],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ft(
                      'regs_note_2',
                      ') isə ömür boyu sabit qalır.',
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: cText2(d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.registration,
    required this.until,
    required this.last,
  });

  final AircraftRegistration registration;

  /// Дата следующей регистрации — конец этого периода. `null` — «indi».
  final String? until;

  final bool last;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final active = registration.active;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: last
          ? null
          : BoxDecoration(border: Border(bottom: BorderSide(color: cLine(d)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FIconChip(
            icon: active
                ? PhosphorIconsFill.checkCircle
                : PhosphorIconsFill.clockCounterClockwise,
            size: 30,
            iconSize: 14,
            color: active ? FTone.ok.fg(d) : cText2(d),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        registration.reg ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .3,
                          color: cText(d),
                          fontFamily: 'monospace',
                          fontFamilyFallback: const ['Menlo', 'Courier'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    FBadge(
                      active
                          ? ft('regs_active', 'AKTİV')
                          : ft('regs_past', 'KEÇMİŞ'),
                      tone: active ? FTone.ok : FTone.mute,
                      fontSize: 9,
                    ),
                  ],
                ),
                if (registration.airlineName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      registration.airlineName!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: cText2(d),
                      ),
                    ),
                  ),
                if (_period() != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _period()!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: cText3(d),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// «21 may 2020 — indi». Без начальной даты период не пишется: конец без
  /// начала ничего не говорит.
  String? _period() {
    final from = registration.registeredOn;
    if (from == null || from.isEmpty) return null;
    final end = until == null || until!.isEmpty
        ? (registration.active ? ft('regs_now', 'indi') : null)
        : fDateStringLong(until);
    final start = fDateStringLong(from);
    return end == null ? start : '$start — $end';
  }
}
