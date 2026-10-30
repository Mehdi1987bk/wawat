import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/models/flight.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../flight/flight_calendar_screen.dart';
import '../flight/flight_card_screen.dart';
import '../watch/watch_route_new_screen.dart';

/// `search/empty` — номер есть, рейса на эту дату нет.
///
/// Два пустых случая ответ сам не различает: `/flights/{number}/{date}`
/// возвращает `200` + `data: []` и в том случае, когда номера не существует
/// вовсе. Разделяет их второй запрос — `/flights/{number}/dates`: пустой
/// список означает «такого номера нет» (кнопка календаря скрыта), а
/// непустой — что ошиблись только датой, и тогда ближайшие даты
/// предлагаются прямо здесь.
///
/// Оба случая — не ошибка: `404` приходит только у `/detail`, а `204` в
/// модуле не бывает вообще.
class SearchEmptyScreen extends StatelessWidget {
  const SearchEmptyScreen({
    super.key,
    required this.number,
    required this.displayNumber,
    required this.date,
    this.dates,
  });

  /// Сжатый номер — тот, что уходит в запрос.
  final String number;

  /// Номер с пробелом — тот, что видит человек.
  final String displayNumber;

  final String date;

  /// Даты, в которые номер летает. Пусто — номера не существует вовсе,
  /// `null` — второй запрос не прошёл и различить два случая нечем.
  final List<String>? dates;

  bool get _unknownNumber => dates != null && dates!.isEmpty;

  bool get _hasDates => dates != null && dates!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('search_title', 'Axtarış'),
      slivers: [
        FlightBody(
          children: [
            FStateBlock(
              icon: _unknownNumber
                  ? PhosphorIconsFill.magnifyingGlassMinus
                  : PhosphorIconsFill.calendarX,
              title: _unknownNumber
                  ? ft('empty_number_title', 'Belə uçuş nömrəsi yoxdur')
                  : ft('empty_date_title', 'Bu tarixdə uçuş yoxdur'),
              message: _unknownNumber
                  ? ft(
                      'empty_number_message',
                      '{number} nömrəsi heç bir tarixdə tapılmadı. '
                          'Aviaşirkət kodunu və rəqəmləri yoxla.',
                      {'number': displayNumber},
                    )
                  : ft(
                      'empty_date_message',
                      '{number} nömrəsi üzrə {date} tarixində uçuş '
                          'tapılmadı. Bu nömrə hər gün uçmaya bilər.',
                      {
                        'number': displayNumber,
                        'date': fDateStringShort(date),
                      },
                    ),
              extra: _tips(context),
              actions: [
                if (!_unknownNumber)
                  FSecondaryButton(
                    label: ft('empty_calendar', 'Uçuş tarixlərinə bax'),
                    icon: PhosphorIconsBold.calendarBlank,
                    onTap: () => FlightNav.push(
                      context,
                      FlightCalendarScreen(
                        number: number,
                        displayNumber: displayNumber,
                        selected: date,
                      ),
                    ),
                  ),
                FGhostButton(
                  label: ft('empty_route', 'Marşrutla axtar'),
                  icon: PhosphorIconsBold.path,
                  onTap: () => FlightNav.push(
                    context,
                    const WatchRouteNewScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _tips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasDates) _datesCard(context),
        if (_hasDates) const SizedBox(height: 12),
        FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FCardTitle(ft('empty_tips', 'Nə sınaya bilərsən')),
              const SizedBox(height: 4),
              FCheckLine(
                ft(
                  'empty_tip_dates',
                  'Bu nömrənin uçduğu günlərə bax, ora yaxın tarix seç',
                ),
              ),
              const SizedBox(height: 8),
              FCheckLine(
                ft(
                  'empty_tip_airline',
                  'Aviaşirkət kodunu yoxla: J2, TK, SU',
                ),
              ),
              const SizedBox(height: 8),
              FCheckLine(
                ft(
                  'empty_tip_route',
                  'Nömrəni bilmirsənsə marşrut və tarixlə axtar',
                ),
              ),
              const SizedBox(height: 8),
              FCheckLine(
                ft('empty_tip_aircraft', 'Təyyarə nömrəsi ilə axtar: 4K-AZ81'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Ближайшие даты из `/dates` — чтобы не гонять человека в календарь за
  /// одним касанием.
  Widget _datesCard(BuildContext context) {
    final d = fDark(context);
    final nearest = (dates ?? const <String>[]).take(6).toList(growable: false);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(ft('empty_nearest', 'Bu nömrə bu tarixlərdə uçur')),
          const SizedBox(height: 4),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final day in nearest)
                InkWell(
                  onTap: () => FlightNav.push(
                    context,
                    FlightCardScreen(
                      flightKey: FlightKey(number: number, flightDate: day),
                    ),
                  ),
                  borderRadius: FT.rPill,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: FT.chip(d),
                      borderRadius: FT.rPill,
                      border: Border.all(color: FT.chipBorder(d)),
                    ),
                    child: Text(
                      fDateStringShort(day),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: cText2(d),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
