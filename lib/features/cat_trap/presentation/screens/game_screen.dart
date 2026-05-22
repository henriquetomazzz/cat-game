import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/enums/game_state.dart';
import '../../domain/models/game_model.dart';
import '../utils/hex_geometry.dart';
import '../widgets/game_board.dart';
import '../widgets/game_bottom_buttons.dart';
import '../widgets/game_status_bar.dart';
import '../widgets/scoreboard.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GameModel _model = GameModel();

  late AnimationController _moveController;
  Offset? _catFromPos;
  Offset? _catToPos;

  late AnimationController _lickController;
  bool _isLicking = false;

  double _hexSize = 20;
  Offset _boardOrigin = Offset.zero;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )..addListener(_onMoveTick);

    _lickController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isLicking = false;
          setState(() {});
          _scheduleLick();
        }
      });

    _model.initGame();
    _scheduleLick();
  }

  @override
  void dispose() {
    _disposed = true;
    _moveController.dispose();
    _lickController.dispose();
    super.dispose();
  }

  void _scheduleLick() {
    Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
      if (!_disposed &&
          mounted &&
          _model.state == GameState.playing &&
          !_isLicking) {
        _isLicking = true;
        _lickController.forward(from: 0);
      }
    });
  }

  void _onMoveTick() {
    setState(() {});
  }

  void _calculateLayout(double availableWidth, double availableHeight) {
    final double sizeFromWidth = availableWidth / (11 * sqrt(3));
    final double sizeFromHeight = availableHeight / 17;

    double size = min(sizeFromWidth, sizeFromHeight);
    size = size.clamp(8, 40);

    final double totalWidth = 11 * sqrt(3) * size;
    final double totalHeight = 17 * size;

    final double originX = (availableWidth - totalWidth) / 2 + sqrt(3) / 2 * size;
    final double originY = (availableHeight - totalHeight) / 2 + size;

    _hexSize = size;
    _boardOrigin = Offset(originX, originY);

    _catToPos = HexGeometry.getHexCenter(
      row: _model.catRow,
      col: _model.catCol,
      hexSize: _hexSize,
      origin: _boardOrigin,
    );

    _catFromPos ??= _catToPos;
  }

  void _handleTap(TapUpDetails details) {
    if (!_model.isPlayerTurn || _model.state != GameState.playing) return;

    final hex = HexGeometry.getHexAtPoint(
      point: details.localPosition,
      hexSize: _hexSize,
      origin: _boardOrigin,
      boardSize: GameModel.boardSize,
    );

    if (hex == null) return;
    if (!_model.isValidMove(hex.row, hex.col)) return;

    final int oldRow = _model.catRow;
    final int oldCol = _model.catCol;

    _model.moveCat(hex.row, hex.col);

    final Offset from = HexGeometry.getHexCenter(
      row: oldRow,
      col: oldCol,
      hexSize: _hexSize,
      origin: _boardOrigin,
    );

    final Offset to = HexGeometry.getHexCenter(
      row: _model.catRow,
      col: _model.catCol,
      hexSize: _hexSize,
      origin: _boardOrigin,
    );

    _catFromPos = from;
    _catToPos = to;

    _moveController.forward(from: 0);

    setState(() {});

    if (_model.state == GameState.playing) {
      Future.delayed(
        const Duration(milliseconds: 400),
        _cpuMove,
      );
    }
  }

  void _cpuMove() {
    if (_model.state != GameState.playing) return;

    _model.cpuTurn();
    setState(() {});
  }

  void _resetGame() {
    _model.initGame();

    _catFromPos = HexGeometry.getHexCenter(
      row: _model.catRow,
      col: _model.catCol,
      hexSize: _hexSize,
      origin: _boardOrigin,
    );

    _catToPos = _catFromPos;

    _isLicking = false;
    _lickController.reset();

    setState(() {});
    _scheduleLick();
  }

  void _resetScores() {
    _model.resetScores();
    _resetGame();
  }

  Offset _getAnimatedCatPos() {
    if (_catFromPos == null || _catToPos == null) {
      return Offset.zero;
    }

    return Offset.lerp(
      _catFromPos,
      _catToPos,
      _moveController.value,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Scoreboard(
              scoreCat: _model.scoreCat,
              scoreFence: _model.scoreFence,
            ),
            const Divider(
              height: 1,
              color: Color(0xFF2A2A4A),
            ),
            Expanded(
              child: GameBoard(
                model: _model,
                hexSize: _hexSize,
                boardOrigin: _boardOrigin,
                catPixelPos: _getAnimatedCatPos(),
                lickProgress: _isLicking ? _lickController.value : 0.0,
                catMoveProgress: _moveController.value,
                onTapUp: _handleTap,
                onLayout: _calculateLayout,
              ),
            ),
            const Divider(
              height: 1,
              color: Color(0xFF2A2A4A),
            ),
            GameStatusBar(
              state: _model.state,
              isPlayerTurn: _model.isPlayerTurn,
            ),
            GameBottomButtons(
              state: _model.state,
              onResetGame: _resetGame,
              onResetScores: _resetScores,
            ),
          ],
        ),
      ),
    );
  }
}