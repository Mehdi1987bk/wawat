import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_map_prefs.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `map/layers` — подложка карты и накладки.
///
/// Экран не делает ни одного запроса (§9.2): выбор остаётся на телефоне и
/// применяется сразу, кнопка внизу только закрывает экран.
///
/// Отличие от прототипа (§16): строка «Hava şəraiti» показана выключенной и
/// без переключателя. Облака и дождь приходят отдельным поставщиком плиток, и
/// ключа от него у приложения нет — живой тумблер, который ничего не меняет,
/// хуже честной подписи.
class MapLayersScreen extends StatefulWidget {
  const MapLayersScreen({super.key});

  @override
  State<MapLayersScreen> createState() => _MapLayersScreenState();
}

class _MapLayersScreenState extends State<MapLayersScreen> {
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

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('layers_title', 'Xəritə qatları'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('layers_hero', 'Xəritə görünüşü'),
          message: ft(
            'layers_hero_message',
            'Seçim yalnız görünüşə aiddir — əlavə sorğu getmir.',
          ),
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FCardTitle(ft('layers_base', 'Əsas qat')),
                  const SizedBox(height: 4),
                  _base(
                    tiles: FMapTiles.plain,
                    icon: PhosphorIconsFill.mapTrifold,
                    title: ft('layers_plain', 'Sadə xəritə'),
                    subtitle: ft(
                      'layers_plain_sub',
                      'Boz fon, az detal — radar üçün ən oxunaqlı',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _base(
                    tiles: FMapTiles.satellite,
                    icon: PhosphorIconsFill.globeHemisphereEast,
                    title: ft('layers_satellite', 'Peyk'),
                    subtitle: ft('layers_satellite_sub', 'Həqiqi görüntü'),
                  ),
                  const SizedBox(height: 8),
                  _base(
                    tiles: FMapTiles.night,
                    icon: PhosphorIconsFill.moonStars,
                    title: ft('layers_night', 'Gecə'),
                    subtitle: ft('layers_night_sub', 'Tünd fon, işıqlar'),
                  ),
                ],
              ),
            ),
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FCardTitle(ft('layers_overlays', 'Üst qatlar')),
                  const SizedBox(height: 2),
                  FToggleRow(
                    icon: PhosphorIconsFill.path,
                    title: ft('layers_routes', 'Uçuş yolları'),
                    subtitle: ft(
                      'layers_routes_sub',
                      'Keçilmiş və qalan hissə',
                    ),
                    value: _prefs.showRoutes,
                    onChanged: _prefs.setRoutes,
                  ),
                  FToggleRow(
                    icon: PhosphorIconsFill.buildings,
                    title: ft('layers_airports', 'Hava limanları'),
                    subtitle: ft('layers_airports_sub', 'Kod və ad'),
                    value: _prefs.showAirports,
                    onChanged: _prefs.setAirports,
                  ),
                  FToggleRow(
                    icon: PhosphorIconsFill.target,
                    title: ft('layers_ring', 'Radar dairəsi'),
                    subtitle: ft('layers_ring_sub', 'Mərkəz: Bakı'),
                    value: _prefs.showRing,
                    onChanged: _prefs.setRing,
                  ),
                  FToggleRow(
                    icon: PhosphorIconsFill.cloudRain,
                    title: ft('layers_weather', 'Hava şəraiti'),
                    subtitle: ft(
                      'layers_weather_sub',
                      'Bulud və yağış qatı hələ qoşulmayıb',
                    ),
                    value: false,
                    last: true,
                  ),
                ],
              ),
            ),
            FInfoNote(
              ft(
                'layers_note',
                'Qatlar yalnız bu cihazda saxlanılır. Xəritə təsviri Esri '
                    'plitələrindən gəlir — mənbə adı xəritənin küncündə '
                    'göstərilir.',
              ),
            ),
          ],
        ),
      ],
      bottom: FPrimaryButton(
        label: ft('layers_apply', 'Tətbiq et'),
        icon: PhosphorIconsBold.check,
        onTap: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  Widget _base({
    required FMapTiles tiles,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final d = fDark(context);
    final selected = _prefs.tiles == tiles;
    return FPickRow(
      selected: selected,
      onTap: () => _prefs.setTiles(tiles),
      leading: FIconChip(
        icon: icon,
        background: selected ? FT.brand50(d) : FT.chip(d),
        color: selected ? FT.brand600(d) : cText2(d),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: cText(d),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: cText3(d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
