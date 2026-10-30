import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/aircraft.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'aircraft_fleet_screen.dart';
import 'aircraft_gallery_screen.dart';
import 'aircraft_registrations_screen.dart';
import 'aircraft_timeline_screen.dart';

/// `aircraft/passport` — паспорт борта.
///
/// Один запрос `GET /aircraft/{reg}` отдаёт всё: кто это, чем летает, фото,
/// даты производства и цепочку регистраций. Поэтому остальные четыре экрана
/// раздела своих запросов не делают — им передаётся этот же объект.
///
/// Чего в этом ответе нет (§9.5): ключа `meta`. Значит и полоски «данные
/// на …» здесь быть не должно — ответ идёт из нашего каталога, а не от
/// поставщика. Пустые поля из ответа выпадают целиком, поэтому каждая строка
/// проверяется на наличие.
///
/// Отличия от прототипа (§16):
/// • Нет звёздочки «в избранное»: избранных самолётов нет ни в API, ни на
///   телефоне, и показывать их было бы негде.
/// • «Şirkətin filosu» открывается только когда код авиакомпании известен из
///   рейса, откуда пришли: в ответе по борту есть `airline_name`, но не код,
///   а `/airlines/{kod}/fleet` просит именно код.
class AircraftPassportScreen extends StatefulWidget {
  const AircraftPassportScreen({
    super.key,
    required this.registration,
    this.airlineCode,
    this.airlineName,
  });

  final String registration;

  /// IATA или ICAO авиакомпании — приходит с карточки рейса.
  final String? airlineCode;
  final String? airlineName;

  @override
  State<AircraftPassportScreen> createState() => _AircraftPassportScreenState();
}

class _AircraftPassportScreenState extends State<AircraftPassportScreen> {
  final _repo = FlightRepository.instance;

  Aircraft? _aircraft;
  FlightError? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final envelope = await _repo.aircraft(widget.registration);
      if (!mounted) return;
      setState(() {
        _aircraft = envelope.data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _loading = false;
      });
    }
  }

  String? get _airlineName => _aircraft?.airlineName ?? widget.airlineName;

  @override
  Widget build(BuildContext context) {
    final aircraft = _aircraft;
    return FlightScaffold(
      title: widget.registration.toUpperCase(),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              aircraft?.registration.isNotEmpty == true
                  ? aircraft!.registration
                  : widget.registration.toUpperCase(),
              style: const TextStyle(
                fontSize: 27,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _subtitle(aircraft),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: FT.onHero(.82),
              ),
            ),
            if (aircraft != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  FBadge(
                    aircraft.active
                        ? ft('aircraft_active', 'Aktiv')
                        : ft('aircraft_inactive', 'Qeyri-aktiv'),
                    icon: aircraft.active
                        ? PhosphorIconsFill.checkCircle
                        : PhosphorIconsFill.pauseCircle,
                    background: FT.heroBadgeBg(
                      aircraft.active ? FTone.ok : FTone.mute,
                    ),
                    foreground: FT.heroBadgeFg(
                      aircraft.active ? FTone.ok : FTone.mute,
                    ),
                  ),
                  if (aircraft.verified)
                    FBadge(
                      ft('aircraft_verified', 'Təsdiqlənmiş'),
                      icon: PhosphorIconsFill.sealCheck,
                      background: FT.heroBadgeBg(FTone.info),
                      foreground: FT.heroBadgeFg(FTone.info),
                    ),
                  if (aircraft.ageYears != null)
                    FBadge(
                      ft('aircraft_age', '{n} yaş', {
                        'n': _age(aircraft.ageYears!),
                      }),
                      background: FT.heroBadgeBg(FTone.mute),
                      foreground: FT.heroBadgeFg(FTone.mute),
                    ),
                  if (aircraft.isFreighter)
                    FBadge(
                      ft('aircraft_freighter', 'Yük təyyarəsi'),
                      icon: PhosphorIconsFill.package,
                      background: FT.heroBadgeBg(FTone.warn),
                      foreground: FT.heroBadgeFg(FTone.warn),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      slivers: [
        FlightBody(children: _body(aircraft)),
      ],
    );
  }

  String _subtitle(Aircraft? aircraft) {
    if (aircraft == null) {
      return _airlineName ?? ft('aircraft_loading', 'Təyyarə kartı');
    }
    final parts = [
      aircraft.typeName ?? aircraft.model,
      aircraft.airlineName,
    ].whereType<String>().where((value) => value.isNotEmpty).toList();
    return parts.isEmpty
        ? ft('aircraft_unknown_model', 'Model bilinmir')
        : parts.join(' · ');
  }

  /// `6.4` → `6.4`, но целое показывается без хвоста: «6 yaş», а не «6.0».
  String _age(double years) => years == years.roundToDouble()
      ? '${years.round()}'
      : years.toStringAsFixed(1);

  List<Widget> _body(Aircraft? aircraft) {
    if (_loading) {
      return const [FCardSkeleton(rows: 4), FCardSkeleton(rows: 5)];
    }
    final error = _error;
    if (error != null) {
      return [
        FErrorView(
          error: error,
          onRetry: _load,
          notFoundTitle: ft('aircraft_not_found', 'Belə təyyarə yoxdur'),
          notFoundMessage: ft(
            'aircraft_not_found_message',
            'Bu qeydiyyat nişanı kataloqumuzda tapılmadı. Nişanı yoxla — '
                'məsələn 4K-AZ81.',
          ),
        ),
      ];
    }
    if (aircraft == null) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.airplaneTilt,
          title: ft('aircraft_empty', 'Təyyarə haqqında məlumat yoxdur'),
        ),
      ];
    }

    return [
      if (aircraft.image?.url != null) _photo(aircraft),
      _identity(aircraft),
      _technical(aircraft),
      _more(aircraft),
    ];
  }

  // ───────────────────────────── Фото ─────────────────────────────

  /// Фото показывается только вместе с подписью об авторстве — это условие
  /// лицензии (§4.5), а не украшение.
  Widget _photo(Aircraft aircraft) {
    final d = fDark(context);
    final image = aircraft.image!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: FT.rTile,
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.network(
              image.url!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _photoFallback(d, loading: true),
              errorBuilder: (_, __, ___) => _photoFallback(d),
            ),
          ),
        ),
        if (fAttributionText(image) != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 7, 2, 0),
            child: Text(
              fAttributionText(image)!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: cText3(d),
              ),
            ),
          ),
      ],
    );
  }

  Widget _photoFallback(bool d, {bool loading = false}) => Container(
        color: FT.chip(d),
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(cMuted(d)),
                ),
              )
            : Icon(
                PhosphorIconsFill.airplaneTilt,
                size: 30,
                color: cMuted(d),
              ),
      );

  // ───────────────────────────── Карточки ─────────────────────────────

  Widget _identity(Aircraft aircraft) {
    final rows = <FRow>[
      _row(ft('aircraft_reg', 'Qeydiyyat nişanı'), aircraft.registration,
          mono: true),
      if (aircraft.modeS != null)
        _row(ft('aircraft_mode_s', 'Mode-S / hex'), aircraft.modeS,
            mono: true),
      if (aircraft.serial != null)
        _row(ft('aircraft_serial', 'Seriya nömrəsi'), aircraft.serial),
      if (aircraft.airlineName != null)
        _row(ft('aircraft_operator', 'Operator'), aircraft.airlineName),
    ];
    return _card(ft('aircraft_identity', 'Kimlik'), rows);
  }

  Widget _technical(Aircraft aircraft) {
    final rows = <FRow>[
      if (aircraft.model != null)
        _row(ft('aircraft_model', 'Model'), aircraft.model),
      if (aircraft.typeLine != null)
        _row(ft('aircraft_type', 'Tip'), aircraft.typeLine),
      if (aircraft.productionLine != null)
        _row(ft('aircraft_line', 'İstehsal xətti'), aircraft.productionLine),
      if (aircraft.seats != null)
        _row(ft('aircraft_seats', 'Oturacaq sayı'), '${aircraft.seats}'),
      if (aircraft.engines != null || aircraft.engineType != null)
        _row(ft('aircraft_engines', 'Mühərrik'), _engines(aircraft)),
      _row(
        ft('aircraft_is_freighter', 'Yük təyyarəsi'),
        aircraft.isFreighter ? ft('yes', 'Bəli') : ft('no', 'Xeyr'),
      ),
    ];
    return _card(ft('aircraft_technical', 'Texniki'), rows);
  }

  /// «2 × Jet». Слово двигателя приходит от поставщика (Unknown · Jet ·
  /// Turboprop · Piston), человеческий текст собирается здесь.
  String _engines(Aircraft aircraft) {
    final type = fEngineType(aircraft.engineType);
    final count = aircraft.engines;
    if (count == null) return type ?? '—';
    return type == null ? '$count' : '$count × $type';
  }

  Widget _more(Aircraft aircraft) {
    final fleetCode = widget.airlineCode;
    return FCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(ft('aircraft_more', 'Bu təyyarə haqqında')),
          const SizedBox(height: 6),
          if (aircraft.rolloutDate != null ||
              aircraft.firstFlightDate != null ||
              aircraft.deliveryDate != null ||
              aircraft.registrationDate != null)
            FListRow(
              flat: true,
              icon: PhosphorIconsRegular.gitCommit,
              title: ft('aircraft_timeline_row', 'İstehsal tarix xətti'),
              subtitle: ft(
                'aircraft_timeline_sub',
                'zavoddan ilk uçuşa qədər',
              ),
              onTap: () => FlightNav.push(
                context,
                AircraftTimelineScreen(aircraft: aircraft),
              ),
            ),
          if (aircraft.registrations.isNotEmpty)
            FListRow(
              flat: true,
              icon: PhosphorIconsRegular.identificationCard,
              title: ft('aircraft_registrations_row', 'Qeydiyyat zənciri'),
              subtitle: ft(
                'aircraft_registrations_sub',
                'hansı şirkətlərdə olub',
              ),
              onTap: () => FlightNav.push(
                context,
                AircraftRegistrationsScreen(aircraft: aircraft),
              ),
            ),
          FListRow(
            flat: true,
            icon: PhosphorIconsRegular.images,
            title: ft('aircraft_gallery_row', 'Şəkil'),
            subtitle: aircraft.image == null
                ? ft('aircraft_gallery_none', 'bu təyyarə üçün şəkil yoxdur')
                : ft('aircraft_gallery_sub', 'müəllif və lisenziya ilə'),
            onTap: () => FlightNav.push(
              context,
              AircraftGalleryScreen(aircraft: aircraft),
            ),
          ),
          if (fleetCode != null)
            FListRow(
              flat: true,
              icon: PhosphorIconsRegular.airplaneInFlight,
              title: ft('aircraft_fleet_row', 'Şirkətin filosu'),
              subtitle: [
                _airlineName,
                ft('aircraft_fleet_sub', 'model üzrə'),
              ].whereType<String>().join(' · '),
              onTap: () => FlightNav.push(
                context,
                AircraftFleetScreen(
                  airlineCode: fleetCode,
                  airlineName: _airlineName,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(String title, List<FRow> rows) => FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(title),
            const SizedBox(height: 2),
            // Последняя строка карточки идёт без разделителя.
            for (var i = 0; i < rows.length; i++)
              FRow(
                rows[i].label,
                value: rows[i].value,
                mono: rows[i].mono,
                last: i == rows.length - 1,
              ),
          ],
        ),
      );

  FRow _row(String label, String? value, {bool mono = false}) =>
      FRow(label, value: value ?? '—', mono: mono);
}

/// Слово поставщика о двигателе → человеческое. `Unknown` на экран не идёт.
String? fEngineType(String? raw) {
  switch (raw) {
    case 'Jet':
      return ft('engine_jet', 'Jet');
    case 'Turboprop':
      return ft('engine_turboprop', 'Turboprop');
    case 'Piston':
      return ft('engine_piston', 'Piston');
    case 'Electric':
      return ft('engine_electric', 'Elektrik');
    case 'Unknown':
    case null:
      return null;
    default:
      return raw;
  }
}
