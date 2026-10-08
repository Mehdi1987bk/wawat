import 'package:flutter/material.dart';

/// На iPad системный «поделиться» открывается поповером и требует якорь.
/// Без него share_plus бросает PlatformException
/// («sharePositionOrigin: argument must be set») и экран падает.
///
/// Берём прямоугольник текущего виджета; если он ещё не разложен, отдаём
/// небольшую область в центре экрана — поповер просто появится посередине,
/// но приложение не упадёт.
Rect shareOriginOf(BuildContext context) {
  final object = context.findRenderObject();
  if (object is RenderBox && object.hasSize) {
    return object.localToGlobal(Offset.zero) & object.size;
  }
  final size = MediaQuery.of(context).size;
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 100,
    height: 100,
  );
}
