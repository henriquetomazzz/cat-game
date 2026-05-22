import 'package:flutter/material.dart';

import '../../domain/models/game_model.dart';
import '../painters/hex_board_painter.dart';

class GameBoard extends StatelessWidget {
  final GameModel model;
  final double hexSize;
  final Offset boardOrigin;
  final Offset catPixelPos;
  final double lickProgress;
  final double catMoveProgress;
  final void Function(TapUpDetails details) onTapUp;
  final void Function(double width, double height) onLayout;

  const GameBoard({
    super.key,
    required this.model,
    required this.hexSize,
    required this.boardOrigin,
    required this.catPixelPos,
    required this.lickProgress,
    required this.catMoveProgress,
    required this.onTapUp,
    required this.onLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        onLayout(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onTapUp: onTapUp,
          child: CustomPaint(
            painter: HexBoardPainter(
              model: model,
              hexSize: hexSize,
              boardOrigin: boardOrigin,
              catPixelPos: catPixelPos,
              lickProgress: lickProgress,
              catMoveProgress: catMoveProgress,
            ),
            size: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ),
          ),
        );
      },
    );
  }
}