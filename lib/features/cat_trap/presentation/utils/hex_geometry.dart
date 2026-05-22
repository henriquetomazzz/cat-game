import 'dart:math';
import 'package:flutter/material.dart';

import '../../domain/models/position.dart';

class HexGeometry {
  const HexGeometry._();

  static Offset getHexCenter({
    required int row,
    required int col,
    required double hexSize,
    required Offset origin,
  }) {
    final double width = sqrt(3) * hexSize;

    return Offset(
      origin.dx + col * width + (row % 2) * width / 2,
      origin.dy + row * hexSize * 1.5,
    );
  }

  static Position? getHexAtPoint({
    required Offset point,
    required double hexSize,
    required Offset origin,
    required int boardSize,
  }) {
    final double width = sqrt(3) * hexSize;
    final double height = 2 * hexSize;

    final double dx = point.dx - origin.dx;
    final double dy = point.dy - origin.dy;

    int row = (dy / (height * 0.75)).round();
    row = row.clamp(0, boardSize - 1);

    final double colOffset = (row % 2) * width / 2;
    int col = ((dx - colOffset) / width).round();
    col = col.clamp(0, boardSize - 1);

    final Offset center = getHexCenter(
      row: row,
      col: col,
      hexSize: hexSize,
      origin: origin,
    );

    final double px = (point.dx - center.dx).abs();
    final double py = (point.dy - center.dy).abs();
    final double halfWidth = sqrt(3) / 2 * hexSize;

    if (px > halfWidth || py > hexSize) return null;
    if (sqrt(3) * px + py > 2 * hexSize) return null;

    return Position(row, col);
  }
}