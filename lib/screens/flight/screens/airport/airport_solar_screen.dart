import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight_stats.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `airport/solar` — солнце и девять точек дня.
///
/// Ответ идёт от провайдера как есть, поля остаются в camelCase
/// (`sunElevation`, `sunAzimuth`, `dayTime`). Бейдж «GECƏ» и «до рассвета
/// столько-то» в ответе отсутствуют — считаются здесь по высоте солнца и
/// времени восхода.
class AirportSolarScreen extends StatefulWidget {
  const AirportSolarScreen({super.key, this.airport, this.code});

  final Airport? airport;
  final String? code;

  @override
  State<AirportSolarScreen> createState() => _AirportSolarScreenState();
}

class _AirportSolarScreenState extends State<AirportSolarScreen> {
  final _repo = FlightRepository.instance;

  SolarInfo? _solar;
  FlightError? _error;
  bool _loading = true;

  String get _code => widget.airport?.summary.code ?? widget.code ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_code.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.solar(_code);
      if (!mounted) return;
      setState(() {
        _solar = result.data;
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

  /// Местное время лимана считает сервер — от него и отсчитываем «сколько
  /// осталось до восхода».
  DateTime get _localNow {
    final raw = widget.airport?.localTime;
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    return parsed ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('solar_title', '{code} · Günəş', {'code': _code}),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        child: _hero(),
      ),
      slivers: [
        FlightBody(children: _body()),
      ],
    );
  }

  Widget _hero() {
    final solar = _solar;
    final night = solar?.isNight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            if (night != null)
              FBadge(
                night
                    ? ft('solar_night', 'GECƏ')
                    : ft('solar_day', 'GÜNDÜZ'),
                icon: night
                    ? PhosphorIconsFill.moonStars
                    : PhosphorIconsFill.sun,
                background: FT.heroBadgeBg(FTone.info),
                foreground: FT.heroBadgeFg(FTone.info),
                fontSize: 9.5,
              ),
            if (widget.airport?.localTime != null)
              FBadge(
                ft('airport_local_time', '{time} yerli', {
                  'time': '${_localNow.hour.toString().padLeft(2, '0')}:'
                      '${_localNow.minute.toString().padLeft(2, '0')}',
                }),
                background: FT.heroBadgeBg(FTone.info),
                foreground: FT.heroBadgeFg(FTone.info),
                fontSize: 9.5,
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _elevationLine(solar),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: Colors.white,
          ),
        ),
        if (_azimuthLine(solar) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _azimuthLine(solar)!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FT.onHero(.72),
              ),
            ),
          ),
      ],
    );
  }

  String _elevationLine(SolarInfo? solar) {
    final elevation = solar?.sunElevation;
    if (elevation == null) {
      return ft('solar_unknown', 'Günəşin vəziyyəti bilinmir');
    }
    final value = elevation.toStringAsFixed(1).replaceAll('.', ',');
    return elevation < 0
        ? ft('solar_below', 'Günəş {deg}° üfüqdən aşağı', {'deg': value})
        : ft('solar_above', 'Günəş {deg}° üfüqdən yuxarı', {
            'deg': value.replaceFirst('-', ''),
          });
  }

  String? _azimuthLine(SolarInfo? solar) {
    if (solar == null) return null;
    final parts = <String>[];
    final azimuth = solar.sunAzimuth;
    if (azimuth != null) {
      parts.add(ft('solar_azimuth', 'Azimut {deg}°', {
        'deg': azimuth.round().toString(),
      }));
    }
    final next = _untilNext(solar);
    if (next != null) parts.add(next);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// «gün doğuşuna 8 saat 14 dəqiqə» — в ответе этого нет, считаем сами по
  /// ближайшей из двух точек.
  String? _untilNext(SolarInfo solar) {
    final night = solar.isNight;
    if (night == null) return null;
    final target = night ? solar.sunrise : solar.sunset;
    if (target == null) return null;
    final minutes = _minutesUntil(target);
    if (minutes == null) return null;
    return night
        ? ft('solar_until_sunrise', 'gün doğuşuna {time}', {
            'time': fMinutesLong(minutes),
          })
        : ft('solar_until_sunset', 'gün batımına {time}', {
            'time': fMinutesLong(minutes),
          });
  }

  int? _minutesUntil(String stamp) {
    final target = fClockMinutes(_clock(stamp));
    final now = _localNow.hour * 60 + _localNow.minute;
    var left = target - now;
    if (left < 0) left += 24 * 60;
    return left;
  }

  String _clock(String raw) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match == null) return raw;
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  List<Widget> _body() {
    if (_loading) return const [FCardSkeleton(rows: 2), FCardSkeleton(rows: 9)];
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: _load)];
    }
    final solar = _solar;
    if (solar == null || solar.points.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.sunHorizon,
          title: ft('solar_empty', 'Gün vaxtı məlumatı gəlmir'),
          message: ft(
            'solar_empty_message',
            'Mənbə bu liman üçün günəş hesabı vermir.',
          ),
        ),
      ];
    }
    return [
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('solar_path', 'Günəşin yolu')),
            AspectRatio(
              aspectRatio: 300 / 120,
              child: CustomPaint(
                painter: _SunPainter(
                  dark: fDark(context),
                  progress: _dayProgress(solar),
                  line: cLine(fDark(context)),
                  label: cText3(fDark(context)),
                  sunrise: _clock(solar.sunrise ?? ''),
                  sunset: _clock(solar.sunset ?? ''),
                ),
              ),
            ),
          ],
        ),
      ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('solar_points', '{n} vaxt nöqtəsi', {
              'n': '${solar.points.length}',
            })),
            for (var i = 0; i < SolarInfo.order.length; i++)
              if (solar.points[SolarInfo.order[i]] != null)
                FRow(
                  _pointLabel(SolarInfo.order[i]),
                  value: _clock(solar.points[SolarInfo.order[i]]!),
                  last: i == SolarInfo.order.length - 1,
                ),
          ],
        ),
      ),
    ];
  }

  /// Доля пройденного светового дня: 0 — рассвет, 1 — закат. Вне дня дуга
  /// рисуется пустой.
  double _dayProgress(SolarInfo solar) {
    final sunrise = solar.sunrise;
    final sunset = solar.sunset;
    if (sunrise == null || sunset == null) return 0;
    final from = fClockMinutes(_clock(sunrise));
    final to = fClockMinutes(_clock(sunset));
    if (to <= from) return 0;
    final now = _localNow.hour * 60 + _localNow.minute;
    return ((now - from) / (to - from)).clamp(0, 1);
  }

  String _pointLabel(String key) => switch (key) {
        'dawnAstronomical' => ft('solar_dawn_astro', 'Astronomik şəfəq'),
        'dawnNautical' => ft('solar_dawn_nautical', 'Dəniz şəfəqi'),
        'dawnCivil' => ft('solar_dawn_civil', 'Mülki şəfəq'),
        'sunrise' => ft('solar_sunrise', 'Gün doğuşu'),
        'noonTrue' => ft('solar_noon', 'Həqiqi günorta'),
        'sunset' => ft('solar_sunset', 'Gün batımı'),
        'duskCivil' => ft('solar_dusk_civil', 'Mülki qürub'),
        'duskNautical' => ft('solar_dusk_nautical', 'Dəniz qürubu'),
        'duskAstronomical' => ft('solar_dusk_astro', 'Astronomik qürub'),
        _ => key,
      };
}

/// Дуга дня: пунктир — весь путь, сплошная — пройденная часть, круг — солнце.
class _SunPainter extends CustomPainter {
  _SunPainter({
    required this.dark,
    required this.progress,
    required this.line,
    required this.label,
    required this.sunrise,
    required this.sunset,
  });

  final bool dark;
  final double progress;
  final Color line;
  final Color label;
  final String sunrise;
  final String sunset;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height - 18;
    final left = Offset(size.width * .035, ground);
    final right = Offset(size.width * .965, ground);
    final radius = (right.dx - left.dx) / 2;
    final center = Offset((left.dx + right.dx) / 2, ground);

    final groundPaint = Paint()
      ..color = line
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(left.dx, ground), Offset(right.dx, ground),
        groundPaint);

    final arc = Rect.fromCircle(center: center, radius: radius);
    final dashed = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const steps = 28;
    for (var i = 0; i < steps; i++) {
      if (i.isOdd) continue;
      canvas.drawArc(arc, math.pi + math.pi * i / steps, math.pi / steps,
          false, dashed);
    }

    if (progress > 0) {
      final done = Paint()
        ..color = FT.brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arc, math.pi, math.pi * progress, false, done);
      final angle = math.pi + math.pi * progress;
      final sun = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(sun, 9, Paint()..color = FT.accent);
      canvas.drawCircle(
        sun,
        9,
        Paint()
          ..color = const Color(0xFFD8E200)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    _text(canvas, sunrise, Offset(left.dx, ground + 4));
    _text(canvas, sunset, Offset(right.dx, ground + 4));
  }

  void _text(Canvas canvas, String value, Offset at) {
    if (value.isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: label,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(at.dx - painter.width / 2, at.dy));
  }

  @override
  bool shouldRepaint(_SunPainter old) =>
      old.progress != progress ||
      old.sunrise != sunrise ||
      old.sunset != sunset ||
      old.dark != dark;
}
