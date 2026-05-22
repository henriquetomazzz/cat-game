import 'dart:math';

import 'package:flutter/material.dart';

class CatPainter {
  const CatPainter._();

  static void drawCat(
    Canvas canvas,
    Offset center,
    double size,
    double lickProgress,
    double moveProgress,
  ) {
    if (center == Offset.zero) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final Paint white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint pink = Paint()
      ..color = const Color(0xFFFFB6C1)
      ..style = PaintingStyle.fill;

    final Paint dark = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;

    final Paint stroke = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Paint whisker = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (moveProgress > 0) {
      canvas.save();

      final double squash = 1.0 + 0.08 * sin(moveProgress * pi * 2);
      final double stretch = 1.0 / squash;

      canvas.scale(stretch, squash);

      _drawCatBody(
        canvas,
        size,
        white,
        pink,
        dark,
        stroke,
        whisker,
        0.0,
      );

      canvas.restore();

      _drawMotionLines(canvas, size);
    } else {
      _drawCatBody(
        canvas,
        size,
        white,
        pink,
        dark,
        stroke,
        whisker,
        lickProgress,
      );
    }

    canvas.restore();
  }

  static void _drawCatBody(
    Canvas canvas,
    double size,
    Paint white,
    Paint pink,
    Paint dark,
    Paint stroke,
    Paint whisker,
    double lick,
  ) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, size * 0.2),
          width: size * 0.65,
          height: size * 0.45),
      white,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, size * 0.2),
          width: size * 0.65,
          height: size * 0.45),
      stroke,
    );

    canvas.drawCircle(Offset(0, -size * 0.15), size * 0.28, white);
    canvas.drawCircle(Offset(0, -size * 0.15), size * 0.28, stroke);

    var leftEar = Path()
      ..moveTo(-size * 0.22, -size * 0.3)
      ..lineTo(-size * 0.12, -size * 0.58)
      ..lineTo(-size * 0.02, -size * 0.3);
    canvas.drawPath(leftEar, white);
    canvas.drawPath(leftEar, stroke);

    var leftInner = Path()
      ..moveTo(-size * 0.19, -size * 0.33)
      ..lineTo(-size * 0.13, -size * 0.5)
      ..lineTo(-size * 0.06, -size * 0.33);
    canvas.drawPath(leftInner, pink);

    var rightEar = Path()
      ..moveTo(size * 0.02, -size * 0.3)
      ..lineTo(size * 0.12, -size * 0.58)
      ..lineTo(size * 0.22, -size * 0.3);
    canvas.drawPath(rightEar, white);
    canvas.drawPath(rightEar, stroke);

    var rightInner = Path()
      ..moveTo(size * 0.06, -size * 0.33)
      ..lineTo(size * 0.13, -size * 0.5)
      ..lineTo(size * 0.19, -size * 0.33);
    canvas.drawPath(rightInner, pink);

    canvas.drawCircle(Offset(-size * 0.12, -size * 0.17), size * 0.065,
        Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(size * 0.12, -size * 0.17), size * 0.065,
        Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(-size * 0.12, -size * 0.17), size * 0.03, dark);
    canvas.drawCircle(Offset(size * 0.12, -size * 0.17), size * 0.03, dark);

    var nose = Path()
      ..moveTo(0, -size * 0.1)
      ..lineTo(-size * 0.035, -size * 0.06)
      ..lineTo(size * 0.035, -size * 0.06)
      ..close();
    canvas.drawPath(nose, pink);

    canvas.drawLine(
        Offset(0, -size * 0.06), Offset(0, -size * 0.03), stroke);
    canvas.drawLine(Offset(0, -size * 0.03), Offset(-size * 0.05, -0.01),
        stroke);
    canvas.drawLine(
        Offset(0, -size * 0.03), Offset(size * 0.05, -0.01), stroke);

    canvas.drawLine(
        Offset(-size * 0.04, -size * 0.08), Offset(-size * 0.28, -size * 0.12),
        whisker);
    canvas.drawLine(
        Offset(-size * 0.04, -size * 0.06), Offset(-size * 0.28, -size * 0.06),
        whisker);
    canvas.drawLine(
        Offset(-size * 0.04, -size * 0.04), Offset(-size * 0.28, 0), whisker);
    canvas.drawLine(
        Offset(size * 0.04, -size * 0.08), Offset(size * 0.28, -size * 0.12),
        whisker);
    canvas.drawLine(
        Offset(size * 0.04, -size * 0.06), Offset(size * 0.28, -size * 0.06),
        whisker);
    canvas.drawLine(
        Offset(size * 0.04, -size * 0.04), Offset(size * 0.28, 0), whisker);

    var tail = Path()
      ..moveTo(-size * 0.25, size * 0.12)
      ..cubicTo(-size * 0.45, size * 0.3, -size * 0.35, size * 0.5,
          -size * 0.18, size * 0.45);
    canvas.drawPath(
        tail,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.08
          ..strokeCap = StrokeCap.round);
    canvas.drawPath(
        tail,
        Paint()
          ..color = const Color(0xFFCCCCCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.08
          ..strokeCap = StrokeCap.round);

    if (lick > 0.05) {
      double lift = lick * size * 0.28;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-size * 0.13, size * 0.35),
            width: size * 0.1,
            height: size * 0.12),
        white,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size * 0.08, size * 0.12 - lift),
            width: size * 0.1,
            height: size * 0.12),
        white,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(0.0, -size * 0.04),
            width: size * 0.06,
            height: size * 0.03),
        pink,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-size * 0.13, size * 0.35),
            width: size * 0.1,
            height: size * 0.12),
        white,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size * 0.13, size * 0.35),
            width: size * 0.1,
            height: size * 0.12),
        white,
      );
    }
  }

  static void _drawMotionLines(
    Canvas canvas,
    double size,
  ) {
    final Paint paint = Paint()
      ..color = const Color(0xFF4A90D9).withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final double x = -size * 0.4 - i * size * 0.08;
      final double y = -size * 0.1 + i * size * 0.06;

      canvas.drawLine(
        Offset(x, y),
        Offset(x - size * 0.06, y),
        paint,
      );
    }
  }
}