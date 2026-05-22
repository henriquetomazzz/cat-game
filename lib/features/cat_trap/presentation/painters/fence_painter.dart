import 'package:flutter/material.dart';

class FencePainter {
  const FencePainter._();

  static void drawFenceSymbol(
    Canvas canvas,
    Offset center,
    double size,
  ) {
    final double s = size * 0.35;

    final Paint paint = Paint()
      ..color = const Color(0xFFE94560)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - s, center.dy - s),
      Offset(center.dx + s, center.dy + s),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx + s, center.dy - s),
      Offset(center.dx - s, center.dy + s),
      paint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: s * 1.6,
        height: s * 0.35,
      ),
      Paint()
        ..color = const Color(0xFFE94560).withAlpha(60)
        ..style = PaintingStyle.fill,
    );
  }
}