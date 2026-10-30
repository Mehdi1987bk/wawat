import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// Что человек выбрал на экране фильтра.
///
/// `hours` — готовое окно «от сейчас»; `from`/`to` — точный диапазон. У
/// эндпоинта всего три параметра (`direction`, `from`, `to`), и `to`
/// обязателен вместе с `from` (иначе 422), поэтому диапазон всегда парный.
///
/// «Yük uçuşları» и «Ləğv olunanlar» серверным фильтром не являются: они
/// всегда приходят в ответе и отбираются на телефоне по `is_cargo` и
/// `status`. Полей «только прямые» и «codeshare» в ответе табло нет —
/// поэтому таких переключателей тут тоже нет.
class BoardFilter {
  const BoardFilter({
    this.hours = 2,
    this.from,
    this.to,
    this.showCargo = false,
    this.showCanceled = true,
  });

  final int? hours;
  final DateTime? from;
  final DateTime? to;
  final bool showCargo;
  final bool showCanceled;

  bool get isExact => hours == null;

  BoardFilter copyWith({
    int? hours,
    bool clearHours = false,
    DateTime? from,
    DateTime? to,
    bool? showCargo,
    bool? showCanceled,
  }) =>
      BoardFilter(
        hours: clearHours ? null : (hours ?? this.hours),
        from: from ?? this.from,
        to: to ?? this.to,
        showCargo: showCargo ?? this.showCargo,
        showCanceled: showCanceled ?? this.showCanceled,
      );
}

/// `airport/filter` — окно времени и отбор списка.
class AirportBoardFilterScreen extends StatefulWidget {
  const AirportBoardFilterScreen({
    super.key,
    required this.filter,
    required this.localNow,
    this.timeZone,
  });

  final BoardFilter filter;

  /// Местное время лимана — окна считаются от него, а не от часов телефона.
  final DateTime localNow;

  final String? timeZone;

  @override
  State<AirportBoardFilterScreen> createState() =>
      _AirportBoardFilterScreenState();
}

class _AirportBoardFilterScreenState extends State<AirportBoardFilterScreen> {
  late BoardFilter _filter = widget.filter;
  late DateTime _from = widget.filter.from ?? widget.localNow;
  late DateTime _to =
      widget.filter.to ?? widget.localNow.add(const Duration(hours: 8));

  static const _presets = [2, 6, 12];

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('board_filter_title', 'Vaxt filtri'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('board_filter_hero', 'Hansı aralıq?'),
          message: ft(
            'board_filter_hero_message',
            'Lövhədə görünəcək vaxt pəncərəsi',
          ),
        ),
      ),
      slivers: [
        FlightBody(
          gap: 12,
          children: [
            Column(
              children: [
                for (final hours in _presets) ...[
                  _presetRow(hours),
                  const SizedBox(height: 8),
                ],
                _exactRow(),
              ],
            ),
            if (_filter.isExact)
              FCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FCardTitle(ft('board_filter_exact', 'Dəqiq aralıq')),
                    Row(
                      children: [
                        Expanded(
                          child: _stampField(
                            ft('board_filter_start', 'Başlanğıc'),
                            _from,
                            () => _pick(start: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _stampField(
                            ft('board_filter_end', 'Son'),
                            _to,
                            () => _pick(start: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FInfoNote(
                      widget.timeZone == null
                          ? ft(
                              'board_filter_tz_unknown',
                              'Vaxtlar limanın yerli vaxtı ilədir',
                            )
                          : ft('board_filter_tz', 'Vaxtlar limanın yerli '
                              'vaxtı ilədir ({tz})', {
                              'tz': widget.timeZone!,
                            }),
                      icon: PhosphorIconsBold.info,
                    ),
                  ],
                ),
              ),
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FCardTitle(ft('board_filter_list', 'Siyahını süz')),
                  FToggleRow(
                    icon: PhosphorIconsFill.package,
                    title: ft('board_filter_cargo', 'Yük uçuşlarını göstər'),
                    value: _filter.showCargo,
                    onChanged: (value) => setState(
                      () => _filter = _filter.copyWith(showCargo: value),
                    ),
                  ),
                  FToggleRow(
                    icon: PhosphorIconsFill.xCircle,
                    title: ft(
                      'board_filter_canceled',
                      'Ləğv olunanları göstər',
                    ),
                    value: _filter.showCanceled,
                    last: true,
                    onChanged: (value) => setState(
                      () => _filter = _filter.copyWith(showCanceled: value),
                    ),
                  ),
                ],
              ),
            ),
            FInfoNote(
              ft(
                'board_filter_note',
                'Daha uzun aralıq seçsən də olar — server pəncərəni özü 12 '
                    'saatlıq hissələrə bölür.',
              ),
              icon: PhosphorIconsBold.clockClockwise,
            ),
          ],
        ),
      ],
      bottom: FPrimaryButton(
        label: ft('apply', 'Tətbiq et'),
        icon: PhosphorIconsBold.check,
        onTap: _apply,
      ),
    );
  }

  Widget _presetRow(int hours) {
    final d = fDark(context);
    final end = widget.localNow.add(Duration(hours: hours));
    return FPickRow(
      selected: _filter.hours == hours,
      onTap: () => setState(() => _filter = _filter.copyWith(hours: hours)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ft('board_filter_next_hours', 'Növbəti {n} saat', {'n': '$hours'}),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: cText(d),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              ft('board_filter_until', 'indi → {time}', {
                'time': '${end.hour.toString().padLeft(2, '0')}:'
                    '${end.minute.toString().padLeft(2, '0')}',
              }),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: cText3(d),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exactRow() {
    final d = fDark(context);
    return FPickRow(
      selected: _filter.isExact,
      onTap: () => setState(() => _filter = _filter.copyWith(clearHours: true)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ft('board_filter_pick_exact', 'Dəqiq aralıq seç'),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: cText(d),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              ft('board_filter_pick_exact_hint', 'başlanğıc və son vaxt'),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: cText3(d),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stampField(String label, DateTime value, VoidCallback onTap) {
    final d = fDark(context);
    return InkWell(
      borderRadius: FT.rField,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: FT.chip(d),
          borderRadius: FT.rField,
          border: Border.all(color: FT.chipBorder(d)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
                color: cText3(d),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fApiLocalWindow(value).replaceFirst('T', ' '),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: cText(d),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick({required bool start}) async {
    final current = start ? _from : _to;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: widget.localNow.subtract(const Duration(days: 30)),
      lastDate: widget.localNow.add(const Duration(days: 30)),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (!mounted || time == null) return;
    final picked =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (start) {
        _from = picked;
        if (!_to.isAfter(_from)) _to = _from.add(const Duration(hours: 8));
      } else {
        _to = picked;
      }
      _filter = _filter.copyWith(clearHours: true);
    });
  }

  void _apply() {
    final result = _filter.isExact
        ? _filter.copyWith(from: _from, to: _to, clearHours: true)
        : _filter;
    Navigator.of(context).pop(result);
  }
}
