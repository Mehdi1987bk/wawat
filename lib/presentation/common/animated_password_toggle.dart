import 'dart:math' as math;
import 'package:flutter/material.dart';

const double _toggleIconSize = 30;

class AnimatedToggle extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const AnimatedToggle({Key? key, this.onChanged}) : super(key: key);

  @override
  _AnimatedToggleState createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        isHidden = !isHidden;
        widget.onChanged?.call(isHidden);
      }),
      child: SizedBox(
        height: _toggleIconSize,
        width: _toggleIconSize,
        child: Stack(
          children: [
            const Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.grey,
              size: _toggleIconSize,
            ),
            Positioned(
              top: 4,
              left: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 275),
                decoration: const CrossLineDecoration(),
                curve: Curves.fastOutSlowIn,
                width: isHidden ? _toggleIconSize - 8 : 0,
                height: isHidden ? _toggleIconSize - 8 : 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CrossLinePainter extends BoxPainter {
  final double lineThickness;
  final double eraseLineThickness;

  final Paint eraseLinePaint;
  final Paint linePaint;

  _CrossLinePainter({
    required this.lineThickness,
    required this.eraseLineThickness,
  })  : eraseLinePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = eraseLineThickness,
        linePaint = Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineThickness;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final bounds = offset & configuration.size!;
    _drawDecoration(canvas, bounds);
  }

  void _drawDecoration(Canvas canvas, Rect bounds) {
    final eraseLineShift = math.sqrt(math.pow(lineThickness / 2, 2) * 2);
    canvas.drawLine(Offset(bounds.topLeft.dx + eraseLineShift, bounds.topLeft.dy),
        Offset(bounds.bottomRight.dx + eraseLineShift, bounds.bottomRight.dy), eraseLinePaint);

    canvas.drawLine(Offset(bounds.topLeft.dx, bounds.topLeft.dy),
        Offset(bounds.bottomRight.dx, bounds.bottomRight.dy), linePaint);
  }
}

class CrossLineDecoration extends Decoration {
  final double lineThickness;
  final double eraseLineThickness;

  const CrossLineDecoration({
    this.lineThickness = 2,
    this.eraseLineThickness = 2,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CrossLinePainter(lineThickness: lineThickness, eraseLineThickness: eraseLineThickness);
  }
}
