import 'package:flutter/material.dart';

import '../../domain/enums/cell_content.dart';
import '../../domain/enums/game_state.dart';
import '../../domain/models/game_model.dart';
import '../utils/hex_geometry.dart';
import 'cat_painter.dart';
import 'fence_painter.dart';
import 'game_overlay_painter.dart';
import 'hex_painter.dart';

class HexBoardPainter extends CustomPainter {
  final GameModel model;
  final double hexSize;
  final Offset boardOrigin;
  final Offset catPixelPos;
  final double lickProgress;
  final double catMoveProgress;

  HexBoardPainter({
    required this.model,
    required this.hexSize,
    required this.boardOrigin,
    required this.catPixelPos,
    required this.lickProgress,
    required this.catMoveProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawBoard(canvas);

    CatPainter.drawCat(
      canvas,
      catPixelPos,
      hexSize * 0.75,
      lickProgress,
      catMoveProgress,
    );

    if (model.state == GameState.catWins) {
      GameOverlayPainter.drawOverlay(
        canvas,
        size,
        'VOCÊ VENCEU!',
        const Color(0xFF4ADE80),
      );
    } else if (model.state == GameState.fenceWins) {
      GameOverlayPainter.drawOverlay(
        canvas,
        size,
        'A CERCA VENCEU!',
        const Color(0xFFE94560),
      );
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D0D1A),
    );
  }

  void _drawBoard(Canvas canvas) {
    for (int row = 0; row < GameModel.boardSize; row++) {
      for (int col = 0; col < GameModel.boardSize; col++) {
        final Offset center = HexGeometry.getHexCenter(
          row: row,
          col: col,
          hexSize: hexSize,
          origin: boardOrigin,
        );

        final bool isFence = model.board[row][col] == CellContent.fence;
        final bool isCat = model.board[row][col] == CellContent.cat;

        if (isFence) {
          HexPainter.drawHex(
            canvas,
            center,
            hexSize,
            fillColor: const Color(0xFF2A1A1A),
            borderColor: const Color(0xFFE94560),
            borderWidth: 1.5,
          );

          FencePainter.drawFenceSymbol(
            canvas,
            center,
            hexSize,
          );
        } else {
          bool isAdjacent = false;

          if (model.state == GameState.playing && model.isPlayerTurn) {
            isAdjacent = model
                .getNeighbors(model.catRow, model.catCol)
                .any((position) => position.row == row && position.col == col);
          }

          HexPainter.drawHex(
            canvas,
            center,
            hexSize,
            fillColor: isCat
                ? const Color(0xFF1A1A2E)
                : isAdjacent
                    ? const Color(0xFF1A2A3A)
                    : const Color(0xFF12121E),
            borderColor: isCat
                ? const Color(0xFF4A4A6A)
                : isAdjacent
                    ? const Color(0xFF4A90D9)
                    : const Color(0xFF1E1E3A),
            borderWidth: isCat ? 1.5 : isAdjacent ? 2.0 : 1.0,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(HexBoardPainter oldDelegate) {
    return true;
  }
}