import 'dart:math';
import 'package:flutter/material.dart';
import 'game_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final GameModel _model = GameModel();

  late AnimationController _moveController;
  Offset? _catFromPos;
  Offset? _catToPos;

  late AnimationController _lickController;
  bool _isLicking = false;

  double _hexSize = 20;
  Offset _boardOrigin = Offset.zero;

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

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _moveController.dispose();
    _lickController.dispose();
    super.dispose();
  }

  void _scheduleLick() {
    Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
      if (!_disposed && mounted && _model.state == GameState.playing && !_isLicking) {
        _isLicking = true;
        _lickController.forward(from: 0);
      }
    });
  }

  void _onMoveTick() {
    setState(() {});
  }

  Offset _getHexCenter(int r, int c, double size, Offset origin) {
    double w = sqrt(3) * size;
    double x = origin.dx + c * w + (r % 2) * w / 2;
    double y = origin.dy + r * size * 1.5;
    return Offset(x, y);
  }

  void _calculateLayout(double availableW, double availableH) {
    double sizeFromW = availableW / (11 * sqrt(3));
    double sizeFromH = availableH / 17;
    double size = min(sizeFromW, sizeFromH);
    size = size.clamp(8, 40);

    double totalW = 11 * sqrt(3) * size;
    double totalH = 17 * size;
    double originX = (availableW - totalW) / 2 + sqrt(3) / 2 * size;
    double originY = (availableH - totalH) / 2 + size;

    _hexSize = size;
    _boardOrigin = Offset(originX, originY);

    if (_catFromPos == null) {
      _catFromPos =
          _getHexCenter(_model.catRow, _model.catCol, _hexSize, _boardOrigin);
      _catToPos = _catFromPos;
    }
  }

  Position? _hexAtPoint(Offset point) {
    double w = sqrt(3) * _hexSize;
    double h = 2 * _hexSize;

    double dx = point.dx - _boardOrigin.dx;
    double dy = point.dy - _boardOrigin.dy;

    int r = (dy / (h * 0.75)).round();
    r = r.clamp(0, 10);

    double colOffset = (r % 2) * w / 2;
    int c = ((dx - colOffset) / w).round();
    c = c.clamp(0, 10);

    Offset center = _getHexCenter(r, c, _hexSize, _boardOrigin);
    double px = (point.dx - center.dx).abs();
    double py = (point.dy - center.dy).abs();
    double hw = sqrt(3) / 2 * _hexSize;

    if (px > hw || py > _hexSize) return null;
    if (sqrt(3) * px + py > 2 * _hexSize) return null;

    return Position(r, c);
  }

  void _handleTap(TapUpDetails details) {
    if (!_model.isPlayerTurn || _model.state != GameState.playing) return;

    var hex = _hexAtPoint(details.localPosition);
    if (hex == null) return;

    if (!_model.isValidMove(hex.row, hex.col)) return;

    int oldRow = _model.catRow;
    int oldCol = _model.catCol;

    _model.moveCat(hex.row, hex.col);

    Offset from = _getHexCenter(oldRow, oldCol, _hexSize, _boardOrigin);
    Offset to =
        _getHexCenter(_model.catRow, _model.catCol, _hexSize, _boardOrigin);

    _catFromPos = from;
    _catToPos = to;
    _moveController.forward(from: 0);

    setState(() {});

    if (_model.state == GameState.playing) {
      Future.delayed(const Duration(milliseconds: 400), _cpuMove);
    }
  }

  void _cpuMove() {
    if (_model.state != GameState.playing) return;
    _model.cpuTurn();
    setState(() {});
  }

  void _resetGame() {
    _model.initGame();
    _catFromPos =
        _getHexCenter(_model.catRow, _model.catCol, _hexSize, _boardOrigin);
    _catToPos = _catFromPos;
    _isLicking = false;
    _lickController.reset();
    setState(() {});
    _scheduleLick();
  }

  Offset _getAnimatedCatPos() {
    if (_catFromPos == null || _catToPos == null) return Offset.zero;
    return Offset.lerp(_catFromPos, _catToPos, _moveController.value)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildScoreboard(),
            const Divider(height: 1, color: Color(0xFF2A2A4A)),
            Expanded(child: _buildBoardArea()),
            const Divider(height: 1, color: Color(0xFF2A2A4A)),
            _buildStatusBar(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildScoreSide(
            icon: Icons.pets,
            label: 'GATO',
            score: _model.scoreCat,
            color: Colors.white,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A6A),
              ),
            ),
          ),
          _buildScoreSide(
            icon: Icons.grid_on,
            label: 'CERCA',
            score: _model.scoreFence,
            color: const Color(0xFFE94560),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSide({
    required IconData icon,
    required String label,
    required int score,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6A6A8A),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildBoardArea() {
    return LayoutBuilder(builder: (context, constraints) {
      _calculateLayout(constraints.maxWidth, constraints.maxHeight);

      return GestureDetector(
        onTapUp: _handleTap,
        child: CustomPaint(
          painter: HexBoardPainter(
            model: _model,
            hexSize: _hexSize,
            boardOrigin: _boardOrigin,
            catPixelPos: _getAnimatedCatPos(),
            lickProgress: _isLicking ? _lickController.value : 0.0,
            catMoveProgress: _moveController.value,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        ),
      );
    });
  }

  Widget _buildStatusBar() {
    String text;
    Color color;

    switch (_model.state) {
      case GameState.playing:
        if (_model.isPlayerTurn) {
          text = 'SUA VEZ — toque em um hexágono adjacente';
          color = const Color(0xFF4A90D9);
        } else {
          text = 'VEZ DA CERCA...';
          color = const Color(0xFFE94560);
        }
      case GameState.catWins:
        text = ' VOCÊ VENCEU! O GATO FUGIU!';
        color = const Color(0xFF4ADE80);
      case GameState.fenceWins:
        text = ' A CERCA VENCEU! O GATO FOI PRESO!';
        color = const Color(0xFFE94560);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      alignment: Alignment.center,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(
              _model.state == GameState.playing ? 'REINICIAR' : 'JOGAR NOVAMENTE',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6A6A8A),
              side: const BorderSide(color: Color(0xFF2A2A4A)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          if (_model.state != GameState.playing) ...[
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                _model.resetScores();
                _resetGame();
              },
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('ZERAR PLACAR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6A6A8A),
                side: const BorderSide(color: Color(0xFF2A2A4A)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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

  Offset getHexCenter(int r, int c) {
    double w = sqrt(3) * hexSize;
    return Offset(
      boardOrigin.dx + c * w + (r % 2) * w / 2,
      boardOrigin.dy + r * hexSize * 1.5,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    for (int r = 0; r < GameModel.boardSize; r++) {
      for (int c = 0; c < GameModel.boardSize; c++) {
        Offset center = getHexCenter(r, c);
        bool isFence = model.board[r][c] == CellContent.fence;
        bool isCat = model.board[r][c] == CellContent.cat;
        if (isFence) {
          _drawHex(canvas, center, hexSize,
              fillColor: const Color(0xFF2A1A1A),
              borderColor: const Color(0xFFE94560),
              borderWidth: 1.5);
          _drawFenceSymbol(canvas, center, hexSize);
        } else {
          bool isAdjacent = false;
          if (model.state == GameState.playing && model.isPlayerTurn) {
            isAdjacent = model
                .getNeighbors(model.catRow, model.catCol)
                .any((p) => p.row == r && p.col == c);
          }
          _drawHex(canvas, center, hexSize,
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
              borderWidth: isCat ? 1.5 : (isAdjacent ? 2.0 : 1.0));
        }
      }
    }

    _drawCat(canvas, catPixelPos, hexSize * 0.75, lickProgress, catMoveProgress);

    if (model.state == GameState.catWins) {
      _drawOverlay(canvas, size, 'VOCÊ VENCEU!', const Color(0xFF4ADE80));
    } else if (model.state == GameState.fenceWins) {
      _drawOverlay(canvas, size, 'A CERCA VENCEU!', const Color(0xFFE94560));
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D0D1A),
    );
  }

  void _drawHex(Canvas canvas, Offset center, double size,
      {required Color fillColor,
      required Color borderColor,
      required double borderWidth}) {
    Path path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (pi / 180) * (60 * i - 90);
      double x = center.dx + size * cos(angle);
      double y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth);
  }

  void _drawFenceSymbol(Canvas canvas, Offset center, double size) {
    double s = size * 0.35;
    final paint = Paint()
      ..color = const Color(0xFFE94560)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(center.dx - s, center.dy - s),
        Offset(center.dx + s, center.dy + s),
        paint);
    canvas.drawLine(
        Offset(center.dx + s, center.dy - s),
        Offset(center.dx - s, center.dy + s),
        paint);

    canvas.drawRect(
      Rect.fromCenter(
          center: center, width: s * 1.6, height: s * 0.35),
      Paint()
        ..color = const Color(0xFFE94560).withAlpha(60)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawCat(Canvas canvas, Offset center, double size, double lick,
      double moveProgress) {
    if (center == Offset.zero) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final white = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final pink = Paint()
      ..color = const Color(0xFFFFB6C1)
      ..style = PaintingStyle.fill;
    final dark = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final whisker = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (moveProgress > 0) {
      canvas.save();
      double squash = 1.0 + 0.08 * sin(moveProgress * pi * 2);
      double stretch = 1.0 / squash;
      canvas.scale(stretch, squash);
      _drawCatBody(canvas, size, white, pink, dark, stroke, whisker, 0.0);
      canvas.restore();
      _drawMotionLines(canvas, size);
    } else {
      _drawCatBody(canvas, size, white, pink, dark, stroke, whisker, lick);
    }

    canvas.restore();
  }

  void _drawCatBody(Canvas canvas, double size, Paint white, Paint pink,
      Paint dark, Paint stroke, Paint whisker, double lick) {
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

  void _drawMotionLines(Canvas canvas, double size) {
    final paint = Paint()
      ..color = const Color(0xFF4A90D9).withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      double x = -size * 0.4 - i * size * 0.08;
      double y = -size * 0.1 + i * size * 0.06;
      canvas.drawLine(Offset(x, y), Offset(x - size * 0.06, y), paint);
    }
  }

  void _drawOverlay(
      Canvas canvas, Size size, String text, Color color) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x80000000),
    );

    double cx = size.width / 2;
    double cy = size.height / 2;

    final bgPaint = Paint()..color = const Color(0xFF1A1A2E);
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy), width: 260, height: 100),
      const Radius.circular(16),
    );
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    final textPainter = TextPainter(
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
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 10));
  }

  @override
  bool shouldRepaint(HexBoardPainter oldDelegate) => true;
}
