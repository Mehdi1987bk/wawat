import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../airport/airport_card_screen.dart';
import '../airport/airport_feeds_screen.dart';

/// `flight/details` и `flight/details-arrival` — четыре времени по сторонам.
///
/// Один экран с переключателем: поля у вылета и прилёта одни и те же
/// (`scheduled`, `revised`, `predicted`, `runway_time`), разница только в
/// подписях — у вылета стойка регистрации, у прилёта лента выдачи.
///
/// Пустая клетка остаётся пустой: «золаг» заполняется только после
/// фактического движения, и ставить туда расписание нельзя.
class FlightDetailsScreen extends StatefulWidget {
  const FlightDetailsScreen({
    super.key,
    required this.detail,
    this.arrival = false,
  });

  final FlightDetail detail;

  /// С какой стороны открыть экран.
  final bool arrival;

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  late int _index = widget.arrival ? 1 : 0;

  FlightDetail get _detail => widget.detail;
  bool get _isArrival => _index == 1;
  FlightEndpoint get _endpoint => _isArrival ? _detail.arrival : _detail.departure;

  @override
  Widget build(BuildContext context) {
    final endpoint = _endpoint;
    final airport = endpoint.airport;
    final code = airport?.code ??
        (_isArrival ? _detail.summary.arrivalCode : _detail.summary.departureCode) ??
        '—';
    final place = [airport?.municipality, airport?.name]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' · ');

    return FlightScaffold(
      title: ft('details_title', 'Gediş və gəliş'),
      subtitle: _detail.displayNumber,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FSegment(
              onHero: true,
              index: _index,
              items: [
                ft('details_departure', 'Gediş'),
                ft('details_arrival', 'Gəliş'),
              ],
              onChanged: (value) => setState(() => _index = value),
            ),
            const SizedBox(height: 16),
            Text(
              code,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            if (place.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  place,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: FT.onHero(.7),
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
    final endpoint = _endpoint;
    final airport = endpoint.airport;
    return [
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('details_four_times', 'Dörd vaxt')),
            const SizedBox(height: 4),
            FEqualRow(
              children: [
                Expanded(
                  child: FTimeTile(
                    label: ft('details_scheduled', 'Cədvəl'),
                    hint: ft('details_scheduled_hint', 'aviaşirkət cədvəli'),
                    value: endpoint.scheduled?.local?.clock,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FTimeTile(
                    label: ft('details_revised', 'Dəqiqləşdirilmiş'),
                    hint: ft('details_revised_hint', 'aviaşirkət dəqiqləşdirdi'),
                    value: endpoint.revised?.local?.clock,
                    valueColor: FT.warn(d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FEqualRow(
              children: [
                Expanded(
                  child: FTimeTile(
                    label: ft('details_predicted', 'Proqnoz'),
                    hint: ft('details_predicted_hint', 'hesablanmış proqnoz'),
                    value: endpoint.predicted?.local?.clock,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FTimeTile(
                    label: ft('details_runway', 'Zolaq'),
                    hint: endpoint.runwayTime == null
                        ? (_isArrival
                            ? ft('details_runway_wait_arrival',
                                'enmədən sonra dolur')
                            : ft('details_runway_wait_departure',
                                'uçuşdan sonra dolur'))
                        : ft('details_runway_hint', 'faktiki zolaq vaxtı'),
                    value: endpoint.runwayTime?.local?.clock,
                    valueColor: FT.ok(d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            FInfoNote(
              ft(
                'details_times_note',
                'Boş qalan vaxt yoxdur deyil — hələ gəlmədiyi deməkdir. '
                    'Zolaq vaxtı yalnız faktiki hərəkətdən sonra dolur.',
              ),
            ),
          ],
        ),
      ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('details_terminal_card', 'Terminalda')),
            FRow(ft('card_terminal', 'Terminal'), value: endpoint.terminal),
            if (!_isArrival)
              FRow(
                ft('card_check_in', 'Check-in masası'),
                value: endpoint.checkInDesk,
              ),
            FRow(ft('card_gate', 'Qapı'), value: endpoint.gate),
            if (_isArrival)
              FRow(
                ft('details_belt', 'Baqaj lenti'),
                value: endpoint.baggageBelt,
              ),
            FRow(
              ft('details_runway_row', 'Uçuş-enmə zolağı'),
              value: endpoint.runway,
              last: true,
            ),
          ],
        ),
      ),
      if (_isArrival)
        FBrandNoteCard(
          icon: PhosphorIconsFill.mapPinArea,
          title: ft('details_meeting', 'Görüş nöqtəsi'),
          message: endpoint.baggageBelt == null
              ? ft(
                  'details_meeting_wait',
                  'Baqaj lenti enmədən sonra bilinir. Gələnlər zalında '
                      'gözləmək daha rahatdır.',
                )
              : ft(
                  'details_meeting_belt',
                  'Baqaj lenti {belt}. Gələnlər zalı həmin lentin '
                      'çıxışındadır.',
                  {'belt': endpoint.baggageBelt!},
                ),
        ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('details_quality', 'Məlumatın keyfiyyəti')),
            FRow(
              ft('details_quality_departure', 'Gediş tərəfi'),
              valueWidget: _qualityBadge(_detail.departure),
            ),
            FRow(
              ft('details_quality_arrival', 'Gəliş tərəfi'),
              valueWidget: _qualityBadge(_detail.arrival),
              last: true,
            ),
            const SizedBox(height: 11),
            FInfoNote(
              ft(
                'details_quality_note',
                '«Cədvəl üzrə» — vaxtlar aviaşirkətin cədvəlindən. «Canlı» — '
                    'limanın öz yayımından. «Təxmini» — hesablanmış qiymət. '
                    'Hər tərəfin keyfiyyəti ayrıdır.',
              ),
            ),
            const SizedBox(height: 11),
            FSecondaryButton(
              label: ft('card_feeds', 'Data mənbələrinə bax'),
              icon: PhosphorIconsBold.pulse,
              onTap: () => _openFeeds(airport?.code),
            ),
          ],
        ),
      ),
      if (airport?.code != null)
        FSecondaryButton(
          label: ft('details_open_airport', '{code} limanına bax', {
            'code': airport!.code!,
          }),
          icon: PhosphorIconsBold.mapPin,
          onTap: () => FlightNav.push(
            context,
            AirportCardScreen(code: airport.code!),
          ),
        ),
    ];
  }

  Widget _qualityBadge(FlightEndpoint endpoint) {
    final quality = endpoint.quality;
    final String label;
    final FTone tone;
    if (quality.contains(FlightQuality.live)) {
      label = ft('quality_live', 'Canlı');
      tone = FTone.ok;
    } else if (quality.contains(FlightQuality.approximate)) {
      label = ft('quality_approximate', 'Təxmini');
      tone = FTone.info;
    } else if (quality.contains(FlightQuality.basic)) {
      label = ft('quality_basic', 'Cədvəl üzrə');
      tone = FTone.mute;
    } else {
      label = ft('quality_unknown', 'Bilinmir');
      tone = FTone.mute;
    }
    return FBadge(label.toUpperCase(), tone: tone, fontSize: 9);
  }

  void _openFeeds(String? code) {
    final target = code ??
        _detail.departure.airport?.code ??
        _detail.summary.departureCode;
    if (target == null) return;
    FlightNav.push(context, AirportFeedsScreen(code: target));
  }
}
