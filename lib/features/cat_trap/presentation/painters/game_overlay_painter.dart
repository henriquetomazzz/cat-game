import 'package:flutter/material.dart';

class GameOverlayPainter {
  const GameOverlayPainter._();

  static void drawOverlay(
    Canvas canvas,
    Size size,
    String text,
    Color color,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x80000000),
    );

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final Paint backgroundPaint = Paint()..color = const Color(0xFF1A1A2E);

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: 260,
        height: 100,
      ),
      const Radius.circular(16),
    );

    canvas.drawRRect(rrect, backgroundPaint);
    canvas.drawRRect(rrect, borderPaint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        cx - textPainter.width / 2,
        cy - 10,
      ),
    );
  }
}