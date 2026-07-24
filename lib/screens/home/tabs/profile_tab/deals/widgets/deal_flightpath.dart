import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../presentation/resourses/wawat_dark.dart';
import 'deal_status.dart';

/// Route mini-widget: `cityFrom  ●┄┄(✈)┄┄○  cityTo`, matching the mockup's `.fp` block.
class DealFlightPath extends StatelessWidget {
  final String cityFrom;
  final String cityTo;
  final bool muted;

  const DealFlightPath({
    super.key,
    required this.cityFrom,
    required this.cityTo,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = muted
        ? (isDark ? WawatDark.iconMuted : dealInk300)
        : dealBrand;
    final badgeBg = muted
        ? (isDark ? WawatDark.surfaceAlt : dealInk100)
        : (isDark ? WawatDark.brandSoft : dealBrand50);
    final badgeColor = muted
        ? (isDark ? WawatDark.textMuted : dealInk400)
        : dealBrand;
    return Row(
      children: [
        Expanded(
          child: Text(
            cityFrom,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? WawatDark.textPrimary : dealInk900,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              _dashedTrack(isDark),
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
                child: Icon(PhosphorIconsFill.airplaneTilt, size: 13, color: badgeColor),
              ),
              _dashedTrack(isDark),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? WawatDark.surface : Colors.white,
                  border: Border.all(color: dotColor, width: 2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Text(
            cityTo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? WawatDark.textPrimary : dealInk900,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dashedTrack(bool isDark) {
    return SizedBox(
      width: 14,
      child: CustomPaint(
        size: const Size(14, 1),
        painter: _DashedLinePainter(
          color: muted
              ? (isDark ? WawatDark.border : dealInk200)
              : (isDark ? WawatDark.brand : const Color(0xFFBFDBFE)),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dashWidth = 3.0;
    const dashSpace = 2.0;
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
