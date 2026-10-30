import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_local_store.dart';
import '../../data/flight_location.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../airport/airport_card_screen.dart';
import '../airport/airport_list_screen.dart';

/// `GET /airports/nearby` — ближайшие аэропорты по координатам телефона.
///
/// Поиска по IP у провайдера нет (§15), поэтому без разрешения на место
/// экрану показывать нечего: он честно говорит об этом и предлагает список
/// аэропортов.
class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key, this.picker = false});

  final bool picker;

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final _repo = FlightRepository.instance;
  final _store = FlightLocalStore.instance;

  FlightPlace? _place;
  List<AirportSummary> _airports = const [];
  FlightError? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _store.load();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final place = await FlightGeo.current();
    if (!mounted) return;
    if (!place.hasPlace) {
      setState(() {
        _place = place;
        _airports = const [];
        _loading = false;
      });
      return;
    }
    try {
      final result = await _repo.nearbyAirports(
        lat: place.lat!,
        lon: place.lon!,
        radiusKm: 400,
        limit: 12,
        force: force,
      );
      if (!mounted) return;
      setState(() {
        _place = place;
        _airports = result.data ?? const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _place = place;
        _error = FlightError.from(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = _place;
    final found = place?.hasPlace == true;
    return FlightScaffold(
      title: ft('nearby_title', 'Yaxınlıqda'),
      actions: [
        FSkyAction(
          icon: PhosphorIconsBold.crosshair,
          onTap: () => _load(force: true),
        ),
      ],
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FBadge(
              found
                  ? ft('nearby_found', 'Mövqe tapıldı')
                  : ft('nearby_waiting', 'Mövqe gözlənilir'),
              ping: found,
              background: found
                  ? const Color(0x3A10B981)
                  : Colors.white.withValues(alpha: .16),
              foreground: found ? const Color(0xFFA7F3D0) : Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              _heroTitle(),
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _heroMessage(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: FT.onHero(.62),
              ),
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(
          gap: 0,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          children: _content(),
        ),
      ],
    );
  }

  String _heroTitle() {
    if (_loading) return ft('nearby_looking', 'Mövqe axtarılır…');
    final place = _place;
    if (place == null || !place.hasPlace) {
      return ft('nearby_no_place', 'Mövqe bilinmir');
    }
    final nearest = _airports.isEmpty ? null : _airports.first;
    final city = nearest?.city;
    final country = nearest?.country;
    if (city == null) return ft('nearby_title', 'Yaxınlıqda');
    return country == null ? city : '$city, $country';
  }

  String _heroMessage() {
    final place = _place;
    if (place == null || !place.hasPlace) {
      return switch (place?.problem) {
        FlightPlaceProblem.serviceOff => ft(
            'nearby_service_off',
            'Telefonda mövqe xidməti sönülüdür. Ayarlarda aç və yenidən sına.',
          ),
        FlightPlaceProblem.blocked => ft(
            'nearby_blocked',
            'Mövqe icazəsi bağlıdır. Ayarlar → icazələr bölməsindən aça '
                'bilərsən.',
          ),
        FlightPlaceProblem.denied => ft(
            'nearby_denied',
            'İcazə verilmədi. Yaxın limanları göstərmək üçün mövqe lazımdır.',
          ),
        _ => ft(
            'nearby_no_fix',
            'Mövqe tapılmadı. Açıq havada və ya pəncərə yanında yenidən sına.',
          ),
      };
    }
    final accuracy = place.accuracyM;
    final coords = fCoordinates(place.lat, place.lon);
    if (accuracy == null) return coords;
    return '$coords · '
        '${ft('nearby_accuracy', 'GPS dəqiqliyi ±{n} m', {
              'n': '${accuracy.round()}',
            })}';
  }

  List<Widget> _content() {
    final d = fDark(context);
    if (_loading) return const [FListSkeleton(rows: 4)];

    final place = _place;
    final blocked = place == null || !place.hasPlace;

    return [
      if (_error != null)
        FErrorView(error: _error!, onRetry: () => _load(force: true))
      else if (blocked)
        FStateBlock(
          icon: PhosphorIconsFill.crosshair,
          title: ft('nearby_no_place', 'Mövqe bilinmir'),
          message: ft(
            'nearby_no_place_message',
            'Yaxın limanları yalnız mövqe ilə tapmaq olur — mənbədə IP üzrə '
                'axtarış yoxdur.',
          ),
          actions: [
            FPrimaryButton(
              label: ft('nearby_retry', 'Yenidən sına'),
              icon: PhosphorIconsBold.crosshair,
              onTap: () => _load(force: true),
            ),
          ],
        )
      else if (_airports.isEmpty)
        FEmptyResult(
          icon: PhosphorIconsFill.buildings,
          title: ft('nearby_empty', 'Yaxınlıqda liman yoxdur'),
          message: ft(
            'nearby_empty_message',
            '400 km radiusunda liman tapılmadı.',
          ),
        )
      else
        for (var i = 0; i < _airports.length; i++) ...[
          if (i != 0) const SizedBox(height: 8),
          AirportRow(
            airport: _airports[i],
            saved: _store.isSaved(_airports[i].code),
            onStar: () => _store.toggleAirport(_airports[i].code),
            onTap: () => _pick(_airports[i]),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fKm(_airports[i].distanceKm),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                Text(
                  ft('distance', 'məsafə'),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: cText3(d),
                  ),
                ),
              ],
            ),
          ),
        ],
      const SizedBox(height: 10),
      FListRow(
        icon: PhosphorIconsRegular.buildings,
        title: ft('nearby_all', 'Bütün hava limanları'),
        subtitle: ft(
          'nearby_all_hint',
          'GPS icazəsi verilməyibsə seçilmiş limanlar göstərilir',
        ),
        onTap: () async {
          final picked = await FlightNav.push<AirportSummary>(
            context,
            AirportListScreen(picker: widget.picker),
          );
          if (!mounted || picked == null) return;
          _pick(picked);
        },
      ),
    ];
  }

  void _pick(AirportSummary airport) {
    if (widget.picker) {
      Navigator.of(context).pop(airport);
      return;
    }
    FlightNav.push(context, AirportCardScreen(code: airport.code));
  }
}
