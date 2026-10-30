import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_map_prefs.dart';
import '../../data/flight_radar.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `map/filters` — что показывать на радаре.
///
/// Экран не делает запросов (§9.2): рейсы уже загружены радаром и передаются
/// сюда, фильтр применяется на телефоне. Счётчик сверху показывает, сколько
/// из них останется.
///
/// Отличие от прототипа (§16): список авиакомпаний не вписан заранее, а
/// собирается из загруженных рейсов — иначе чип «Turkish» стоял бы и там, где
/// турецких рейсов нет. «Hansı uçuşlar» тоже честный: радар строится только
/// из подписок и отмеченных рейсов, поэтому «Bizim marşrutlar» это подписки с
/// привязанным объявлением, а «İzlədiyim» — подписки без отметок с телефона.
class MapFiltersScreen extends StatefulWidget {
  const MapFiltersScreen({super.key, this.flights = const []});

  final List<RadarFlight> flights;

  @override
  State<MapFiltersScreen> createState() => _MapFiltersScreenState();
}

class _MapFiltersScreenState extends State<MapFiltersScreen> {
  final _prefs = FlightMapPrefs.instance;

  @override
  void initState() {
    super.initState();
    _prefs.addListener(_onPrefs);
    _prefs.load();
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPrefs);
    super.dispose();
  }

  void _onPrefs() {
    if (mounted) setState(() {});
  }

  int get _total => widget.flights.length;
  int get _shown => fRadarFiltered(widget.flights, _prefs).length;

  @override
  Widget build(BuildContext context) {
    final airlines = fRadarAirlines(widget.flights);
    return FlightScaffold(
      title: ft('filters_title', 'Süzgəclər'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('filters_hero', 'Radarda nə görünsün?'),
          message: _total == 0
              ? ft(
                  'filters_hero_empty',
                  'Radarda hələ uçuş yoxdur — süzgəc də boş işləyir.',
                )
              : ft('filters_hero_count', 'Hazırda {n} uçuşdan {m}-i göstərilir', {
                  'n': '$_total',
                  'm': '$_shown',
                }),
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            _card(
              title: ft('filters_which', 'Hansı uçuşlar'),
              children: [
                _pill(
                  label: ft('filters_which_all', 'Hamısı'),
                  selected: _prefs.scope == FMapScope.all,
                  onTap: () => _prefs.setScope(FMapScope.all),
                ),
                _pill(
                  label: ft('filters_which_ours', 'Bizim marşrutlar'),
                  selected: _prefs.scope == FMapScope.ourRoutes,
                  onTap: () => _prefs.setScope(FMapScope.ourRoutes),
                ),
                _pill(
                  label: ft('filters_which_watched', 'İzlədiyim'),
                  selected: _prefs.scope == FMapScope.watched,
                  onTap: () => _prefs.setScope(FMapScope.watched),
                ),
              ],
            ),
            _card(
              title: ft('filters_altitude', 'Hündürlük'),
              children: [
                _pill(
                  label: ft('filters_altitude_any', 'Fərq etməz'),
                  selected: _prefs.altitude == FMapAltitude.any,
                  onTap: () => _prefs.setAltitude(FMapAltitude.any),
                ),
                _pill(
                  label: ft('filters_altitude_high', '10 000 m+'),
                  selected: _prefs.altitude == FMapAltitude.high,
                  onTap: () => _prefs.setAltitude(FMapAltitude.high),
                ),
                _pill(
                  label: ft('filters_altitude_down', 'Enir'),
                  selected: _prefs.altitude == FMapAltitude.descending,
                  onTap: () => _prefs.setAltitude(FMapAltitude.descending),
                ),
              ],
              note: _prefs.altitude == FMapAltitude.any
                  ? null
                  : ft(
                      'filters_altitude_note',
                      'Hündürlük və enmə yalnız mövqeyi gələn uçuşlarda '
                          'bilinir — qalanları bu süzgəclə görünmür.',
                    ),
            ),
            _card(
              title: ft('filters_airline', 'Aviaşirkət'),
              children: [
                _pill(
                  label: ft('filters_airline_all', 'Hamısı'),
                  selected: _prefs.airline == null,
                  onTap: () => _prefs.setAirline(null),
                ),
                for (final airline in airlines)
                  _pill(
                    label: airline.name,
                    selected: _prefs.airline == airline.key,
                    onTap: () => _prefs.setAirline(airline.key),
                  ),
              ],
              note: airlines.isEmpty
                  ? ft(
                      'filters_airline_empty',
                      'Radardaki uçuşlarda aviaşirkət adı gəlmədi.',
                    )
                  : null,
            ),
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FCardTitle(ft('filters_extra', 'Əlavə')),
                  const SizedBox(height: 2),
                  FToggleRow(
                    icon: PhosphorIconsFill.airplaneTilt,
                    title: ft('filters_airborne', 'Yalnız havada olanlar'),
                    subtitle: ft('filters_airborne_sub', 'Yerdəkiləri gizlət'),
                    value: _prefs.airborneOnly,
                    onChanged: _prefs.setAirborneOnly,
                  ),
                  FToggleRow(
                    icon: PhosphorIconsFill.package,
                    title: ft('filters_cargo', 'Yük uçuşları'),
                    subtitle: ft('filters_cargo_sub', 'Kargo təyyarələri'),
                    value: _prefs.showCargo,
                    onChanged: _prefs.setCargo,
                  ),
                  FToggleRow(
                    icon: PhosphorIconsFill.crosshair,
                    title: ft('filters_position', 'Yalnız mövqesi olanlar'),
                    subtitle: ft(
                      'filters_position_sub',
                      'ADS-B siqnalı gələnlər',
                    ),
                    value: _prefs.positionOnly,
                    onChanged: _prefs.setPositionOnly,
                    last: true,
                  ),
                ],
              ),
            ),
            if (_total > 0 && _shown == 0)
              FNoticeCard(
                icon: PhosphorIconsFill.funnel,
                title: ft('filters_none_title', 'Süzgəc heç nə saxlamadı'),
                message: ft(
                  'filters_none_message',
                  'Seçilmiş şərtlərə uyğun uçuş yoxdur. Süzgəci sıfırlasan, '
                      '{n} uçuş yenə görünəcək.',
                  {'n': '$_total'},
                ),
                onTap: _prefs.resetFilters,
              ),
            if (_prefs.filtered)
              FGhostButton(
                label: ft('filters_reset', 'Süzgəcləri sıfırla'),
                icon: PhosphorIconsBold.arrowCounterClockwise,
                onTap: _prefs.resetFilters,
              ),
            FInfoNote(
              ft(
                'filters_note',
                'Süzgəc yalnız bu cihazda tətbiq olunur — əlavə sorğu getmir.',
              ),
            ),
          ],
        ),
      ],
      bottom: FPrimaryButton(
        label: ft('filters_apply', 'Göstər'),
        icon: PhosphorIconsBold.check,
        onTap: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  Widget _card({
    required String title,
    required List<Widget> children,
    String? note,
  }) {
    final d = fDark(context);
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(title),
          const SizedBox(height: 10),
          Wrap(spacing: 7, runSpacing: 7, children: children),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                note,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: cText3(d),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final d = fDark(context);
    return FBadge(
      label,
      fontSize: 11.5,
      background: selected ? FT.brand : FT.chip(d),
      foreground: selected ? Colors.white : cText2(d),
      onTap: onTap,
    );
  }
}
