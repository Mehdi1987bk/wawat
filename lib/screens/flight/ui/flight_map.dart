import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../presentation/resourses/theme_colors.dart';
import '../flight_text.dart';
import 'flight_tokens.dart';
import 'flight_widgets.dart';

/// Маршрут на карте: вся линия пунктиром, пройденная часть — сплошной.
class FMapRoute {
  const FMapRoute({required this.all, this.done = const []});

  final List<LatLng> all;
  final List<LatLng> done;
}

/// Самолёт: точка и курс в градусах.
class FMapPlane {
  const FMapPlane({
    required this.point,
    this.track,
    this.label,
    this.live = true,
    this.onTap,
  });

  final LatLng point;
  final double? track;
  final String? label;

  /// Живая позиция или расчётная: расчётная рисуется приглушённой.
  final bool live;

  final VoidCallback? onTap;
}

/// Аэропорт: точка и код рядом.
class FMapAirport {
  const FMapAirport({
    required this.point,
    this.code,
    this.muted = false,
    this.onTap,
  });

  final LatLng point;
  final String? code;
  final bool muted;
  final VoidCallback? onTap;
}

/// Пятно задержек на карте мира.
class FMapHeat {
  const FMapHeat({
    required this.point,
    required this.radius,
    required this.color,
    this.onTap,
  });

  final LatLng point;
  final double radius;
  final Color color;
  final VoidCallback? onTap;
}

/// Кольцо радара вокруг точки — накладка «Radar dairəsi» в настройках слоёв.
class FMapRing {
  const FMapRing({required this.point, required this.radiusKm});

  final LatLng point;
  final double radiusKm;
}

/// Карта раздела. Плитки — Esri Gray Canvas, те же, что в прототипе: ключа не
/// требуют, подпись источника обязательна и выводится в углу.
///
/// Если плитки не пришли (четыре ошибки подряд), подложка скрывается и
/// появляется строка «изображение карты не загрузилось» — маршрут и позиция
/// остаются видимыми, потому что они из нашего ответа, а не из плиток.
class FFlightMap extends StatefulWidget {
  const FFlightMap({
    super.key,
    this.routes = const [],
    this.planes = const [],
    this.airports = const [],
    this.heat = const [],
    this.center,
    this.zoom = 4,
    this.interactive = false,
    this.fitPoints = true,
    this.padding = const EdgeInsets.all(28),
    this.controller,
    this.minZoom = 2,
    this.maxZoom = 12,
    this.tiles = FMapTiles.plain,
    this.rings = const [],
    this.labels = true,
  });

  final List<FMapRoute> routes;
  final List<FMapPlane> planes;
  final List<FMapAirport> airports;
  final List<FMapHeat> heat;
  final LatLng? center;
  final double zoom;
  final bool interactive;

  /// Подогнать камеру под все точки. Выключается, когда центр и масштаб
  /// задаёт экран (полноэкранный радар).
  final bool fitPoints;

  final EdgeInsets padding;
  final MapController? controller;
  final double minZoom;
  final double maxZoom;

  /// Подложка: простая, спутник или ночная.
  final FMapTiles tiles;

  /// Кольца радара — накладка, которую можно выключить.
  final List<FMapRing> rings;

  /// Подписи кодов рядом с аэропортами. Выключаются накладкой «Hava limanları».
  final bool labels;

  @override
  State<FFlightMap> createState() => _FFlightMapState();
}

class _FFlightMapState extends State<FFlightMap> {
  int _tileErrors = 0;
  bool _tilesDown = false;

  /// Свой контроллер, если экран не дал своего: он нужен, чтобы подогнать
  /// кадр заново.
  MapController? _own;

  MapController get _map => widget.controller ?? (_own ??= MapController());

  /// Человек подвинул карту сам — дальше кадр не трогаем.
  bool _userMoved = false;

  /// Точки, под которые кадр уже подогнан.
  List<LatLng> _fitted = const [];

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  /// Часть точек приезжает позже первой отрисовки: названия и координаты
  /// аэропортов дорезолвливаются запросами. `initialCameraFit` срабатывает
  /// один раз, поэтому без этого на карте глобальных задержек оставался
  /// виден только тот порт, что успел к первому кадру.
  @override
  void didUpdateWidget(covariant FFlightMap old) {
    super.didUpdateWidget(old);
    if (!widget.fitPoints || _userMoved) return;
    final points = _allPoints;
    if (points.length < 2 || _samePoints(points, _fitted)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _map.fitCamera(CameraFit.coordinates(
        coordinates: points,
        padding: widget.padding,
        maxZoom: 7,
      ));
    });
  }

  static bool _samePoints(List<LatLng> a, List<LatLng> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude || a[i].longitude != b[i].longitude) {
        return false;
      }
    }
    return true;
  }

  List<LatLng> get _allPoints => [
        for (final r in widget.routes) ...r.all,
        for (final p in widget.planes) p.point,
        for (final a in widget.airports) a.point,
        for (final h in widget.heat) h.point,
        for (final r in widget.rings) r.point,
      ];

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final points = _allPoints;
    final fit = widget.fitPoints && points.length > 1
        ? CameraFit.coordinates(
            coordinates: points,
            padding: widget.padding,
            maxZoom: 7,
          )
        : null;
    _fitted = points;

    return Container(
      color: FT.mapSeaFor(widget.tiles, d),
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                onPositionChanged: (_, hasGesture) {
                  if (hasGesture) _userMoved = true;
                },
                initialCenter: widget.center ??
                    (points.isEmpty ? const LatLng(40.41, 49.87) : points.first),
                initialZoom: widget.zoom,
                initialCameraFit: fit,
                minZoom: widget.minZoom,
                maxZoom: widget.maxZoom,
                backgroundColor: FT.mapSeaFor(widget.tiles, d),
                interactionOptions: InteractionOptions(
                  flags: widget.interactive
                      ? InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom |
                          InteractiveFlag.flingAnimation
                      : InteractiveFlag.none,
                ),
              ),
              children: [
                if (!_tilesDown)
                  TileLayer(
                    urlTemplate: FT.tileUrlFor(widget.tiles, d),
                    maxZoom: 16,
                    userAgentPackageName: 'com.wawat.app',
                    errorTileCallback: (_, __, ___) {
                      if (_tilesDown) return;
                      _tileErrors++;
                      if (_tileErrors < 4) return;
                      // Сбой подложки — не сбой данных: карта остаётся,
                      // исчезает только картинка.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _tilesDown = true);
                      });
                    },
                  ),
                if (widget.heat.isNotEmpty)
                  CircleLayer(
                    circles: [
                      for (final h in widget.heat)
                        CircleMarker(
                          point: h.point,
                          radius: h.radius,
                          color: h.color,
                          borderStrokeWidth: 0,
                        ),
                    ],
                  ),
                if (widget.rings.isNotEmpty)
                  CircleLayer(
                    circles: [
                      for (final ring in widget.rings)
                        CircleMarker(
                          point: ring.point,
                          radius: ring.radiusKm * 1000,
                          useRadiusInMeter: true,
                          color: FT.brand.withValues(alpha: .05),
                          borderStrokeWidth: 1,
                          borderColor: FT.brand.withValues(alpha: .35),
                        ),
                    ],
                  ),
                if (widget.routes.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      for (final r in widget.routes)
                        if (r.all.length > 1)
                          Polyline(
                            points: r.all,
                            color: FT.routeRest(d).withValues(alpha: .55),
                            strokeWidth: 2,
                            pattern:
                                StrokePattern.dashed(segments: const [5, 5]),
                          ),
                      for (final r in widget.routes)
                        if (r.done.length > 1)
                          Polyline(
                            points: r.done,
                            color: FT.routeDone.withValues(alpha: .95),
                            strokeWidth: 2.5,
                          ),
                    ],
                  ),
                if (widget.airports.isNotEmpty)
                  CircleLayer(
                    circles: [
                      for (final a in widget.airports)
                        CircleMarker(
                          point: a.point,
                          radius: 4.5,
                          color: cCard(d),
                          borderStrokeWidth: 2,
                          borderColor: a.muted ? cMuted(d) : FT.brand,
                        ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    for (final a in widget.airports)
                      if (a.code != null && widget.labels)
                        Marker(
                          point: a.point,
                          width: 54,
                          height: 16,
                          alignment: const Alignment(.55, 1.9),
                          child: _AirportLabel(code: a.code!, dark: d),
                        ),
                    for (final p in widget.planes)
                      Marker(
                        point: p.point,
                        width: 26,
                        height: 26,
                        child: _Plane(plane: p, dark: d),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_tilesDown)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: cCard(d),
                  borderRadius: FT.rIcon,
                  border: Border.all(color: cLine(d)),
                  boxShadow: FT.cardShadow(d),
                ),
                child: Text(
                  ft(
                    'map_tiles_down',
                    'Xəritə təsviri yüklənmədi — marşrut və mövqe göstərilir.',
                  ),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: cText3(d),
                  ),
                ),
              ),
            )
          else
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: cCard(d),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(999),
                  ),
                ),
                child: Text(
                  FT.tileAttributionFor(widget.tiles),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: cMuted(d),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AirportLabel extends StatelessWidget {
  const _AirportLabel({required this.code, required this.dark});

  final String code;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final sea = FT.mapSea(dark);
    return Text(
      code,
      textAlign: TextAlign.left,
      maxLines: 1,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: cText(dark),
        shadows: [
          Shadow(color: sea, blurRadius: 2, offset: const Offset(0, 1)),
          Shadow(color: sea, blurRadius: 4),
        ],
      ),
    );
  }
}

class _Plane extends StatelessWidget {
  const _Plane({required this.plane, required this.dark});

  final FMapPlane plane;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final icon = Transform.rotate(
      angle: ((plane.track ?? 0) - 45) * math.pi / 180,
      child: Icon(
        PhosphorIconsFill.airplaneTilt,
        size: 19,
        color: plane.live ? FT.brand : cMuted(dark),
        shadows: const [
          Shadow(color: Color(0x73000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
    if (plane.onTap == null) return Center(child: icon);
    return GestureDetector(
      onTap: plane.onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(child: icon),
    );
  }
}

/// Карта в рамке: радиус, граница и углы для бейджей и кнопок.
class FMapFrame extends StatelessWidget {
  const FMapFrame({
    super.key,
    required this.map,
    this.height = 168,
    this.radius = FT.rTile,
    this.corners = const [],
  });

  final FFlightMap map;
  final double height;
  final BorderRadius radius;

  /// Накладки: «Canlı», «Tam ekran» и прочее.
  final List<Widget> corners;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: cLine(d)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [Positioned.fill(child: map), ...corners]),
    );
  }
}

/// Маленькая кнопка на карте: «Tam ekran», «Layerlər», «Filtrlər».
class FMapChip extends StatelessWidget {
  const FMapChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cCard(d),
          borderRadius: FT.rPill,
          border: Border.all(color: cLine(d)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: cText3(d)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: cText3(d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Дуга большого круга между двумя точками — как на карте прототипа.
/// Делится на [segments] отрезков по сферической интерполяции.
List<LatLng> fGreatCircle(LatLng from, LatLng to, {int segments = 48}) {
  const deg = math.pi / 180;
  final lat1 = from.latitude * deg;
  final lon1 = from.longitude * deg;
  final lat2 = to.latitude * deg;
  final lon2 = to.longitude * deg;

  final dLat = lat2 - lat1;
  final dLon = lon2 - lon1;
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
  final delta = 2 * math.asin(math.min(1, math.sqrt(a)));
  if (delta == 0) return [from, to];

  final out = <LatLng>[];
  for (var i = 0; i <= segments; i++) {
    final f = i / segments;
    final A = math.sin((1 - f) * delta) / math.sin(delta);
    final B = math.sin(f * delta) / math.sin(delta);
    final x = A * math.cos(lat1) * math.cos(lon1) +
        B * math.cos(lat2) * math.cos(lon2);
    final y = A * math.cos(lat1) * math.sin(lon1) +
        B * math.cos(lat2) * math.sin(lon2);
    final z = A * math.sin(lat1) + B * math.sin(lat2);
    out.add(LatLng(
      math.atan2(z, math.sqrt(x * x + y * y)) / deg,
      math.atan2(y, x) / deg,
    ));
  }
  return out;
}

/// Часть дуги до самолёта — по доле пути, которую дал сервер.
List<LatLng> fRouteDone(List<LatLng> all, double? percent) {
  if (percent == null || all.length < 2) return const [];
  final p = percent.clamp(0, 100) / 100;
  final count = (all.length * p).round();
  if (count < 2) return const [];
  return all.sublist(0, count > all.length ? all.length : count);
}
