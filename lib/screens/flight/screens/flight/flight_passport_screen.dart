import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `flight/passport` — паспорт рейса.
///
/// Всё из `/detail`, своего запроса нет: позывной, код-шеринг, грузовой ли
/// рейс и расстояние по большой дуге. Мили берутся из километров
/// (1 NM = 1,852 км) — отдельного поля в ответе нет.
class FlightPassportScreen extends StatelessWidget {
  const FlightPassportScreen({super.key, required this.detail});

  final FlightDetail detail;

  @override
  Widget build(BuildContext context) {
    final summary = detail.summary;
    final airline = summary.airline;
    final airlineLine = [airline?.name, detail.callSign]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' · ');

    return FlightScaffold(
      title: ft('passport_title', 'Uçuş pasportu'),
      subtitle: detail.displayNumber,
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.displayNumber,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            if (airlineLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  airlineLine,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: FT.onHero(.7),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                FBadge(
                  summary.isCargo
                      ? ft('passport_cargo', 'Yük uçuşu')
                      : ft('passport_passenger', 'Sərnişin'),
                  icon: summary.isCargo
                      ? PhosphorIconsFill.package
                      : PhosphorIconsFill.users,
                  background: Colors.white.withValues(alpha: .16),
                  foreground: Colors.white,
                ),
                if (_codeshareLabel != null)
                  FBadge(
                    _codeshareLabel!,
                    background: Colors.white.withValues(alpha: .16),
                    foreground: Colors.white,
                  ),
              ],
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FRow(
                    ft('passport_number', 'Uçuş nömrəsi'),
                    value: detail.displayNumber,
                  ),
                  FRow(
                    ft('passport_callsign', 'Çağırış kodu'),
                    value: detail.callSign,
                    mono: true,
                  ),
                  FRow(
                    ft('card_airline', 'Aviaşirkət'),
                    value: airline?.name,
                  ),
                  FRow(
                    ft('passport_codes', 'IATA / ICAO'),
                    value: _airlineCodes,
                    mono: true,
                  ),
                  FRow(
                    ft('passport_cargo_row', 'Yük uçuşu'),
                    value: summary.isCargo
                        ? ft('yes', 'Bəli')
                        : ft('no', 'Xeyr'),
                  ),
                  FRow(
                    ft('passport_distance', 'Böyük dairə məsafəsi'),
                    value: _distance,
                    last: true,
                  ),
                ],
              ),
            ),
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FCardTitle(ft('passport_codeshare', 'Kodşerinq')),
                  FRow(
                    ft('passport_codeshare_row', 'Status'),
                    value: _codeshareLabel ??
                        ft('passport_codeshare_unknown', 'Bilinmir'),
                    last: true,
                  ),
                  const SizedBox(height: 11),
                  FInfoNote(_codeshareHint),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? get _airlineCodes {
    final airline = detail.summary.airline;
    final iata = airline?.iata;
    final icao = airline?.icao;
    if (iata == null && icao == null) return null;
    return '${iata ?? '—'} / ${icao ?? '—'}';
  }

  /// `1 892 km · 1 022 NM`
  String? get _distance {
    final km = detail.greatCircleKm;
    if (km == null) return null;
    final nm = km / 1.852;
    return '${fKm(km)} · ${fNum(nm)} ${ft('unit_nm', 'NM')}';
  }

  String? get _codeshareLabel => switch (detail.codeshareStatus) {
        CodeshareStatus.operator => ft('passport_operator', 'Operator uçuşu'),
        CodeshareStatus.codeshared => ft('passport_codeshared', 'Kodşerinq'),
        _ => null,
      };

  String get _codeshareHint => switch (detail.codeshareStatus) {
        CodeshareStatus.operator => ft(
            'passport_operator_hint',
            'Təyyarəni bu aviaşirkət özü uçurur. Başqa şirkətlər həmin uçuşu '
                'öz nömrəsi ilə sata bilər.',
          ),
        CodeshareStatus.codeshared => ft(
            'passport_codeshared_hint',
            'Bu nömrə başqa şirkətin uçuşuna qoyulub: təyyarəni başqa '
                'aviaşirkət uçurur.',
          ),
        _ => ft(
            'passport_codeshare_hint',
            'Uçuşu kimin uçurduğu mənbədə göstərilməyib.',
          ),
      };
}
