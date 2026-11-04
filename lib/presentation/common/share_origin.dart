import 'package:flutter/material.dart';

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
