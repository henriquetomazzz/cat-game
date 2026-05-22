import 'dart:math';

import 'package:flutter/material.dart';

class HexPainter {
  const HexPainter._();

  static void drawHex(
    Canvas canvas,
    Offset center,
    double size, {
    required Color fillColor,
    required Color borderColor,
    required double borderWidth,
  }) {
    final Path path = Path();

    for (int i = 0; i < 6; i++) {
      final double angle = (pi / 180) * (60 * i - 90);
      final double x = center.dx + size * cos(angle);
      final double y = center.dy + size * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }
}