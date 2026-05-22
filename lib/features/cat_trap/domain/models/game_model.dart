import 'dart:collection';
import 'dart:math';

import '../enums/cell_content.dart';
import '../enums/game_state.dart';
import 'position.dart';
import 'scored_move.dart';

class GameModel {
  static const int boardSize = 11;
  static const int centerRow = 5;
  static const int centerCol = 5;

  late List<List<CellContent>> _board;
  int _catRow = centerRow;
  int _catCol = centerCol;
  int _scoreCat = 0;
  int _scoreFence = 0;
  GameState _state = GameState.playing;
  bool _isPlayerTurn = true;
  final Random _random = Random();

  List<List<CellContent>> get board => _board;
  int get catRow => _catRow;
  int get catCol => _catCol;
  int get scoreCat => _scoreCat;
  int get scoreFence => _scoreFence;
  GameState get state => _state;
  bool get isPlayerTurn => _isPlayerTurn;

  void initGame() {
    _board = List.generate(
        boardSize, (_) => List.filled(boardSize, CellContent.empty));
    _catRow = centerRow;
    _catCol = centerCol;
    _board[_catRow][_catCol] = CellContent.cat;
    _state = GameState.playing;
    _isPlayerTurn = true;

    int fenceCount = _random.nextInt(9) + 7;
    int maxAttempts = 80;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      _board = List.generate(
          boardSize, (_) => List.filled(boardSize, CellContent.empty));
      _board[_catRow][_catCol] = CellContent.cat;

      int placed = 0;
      int safety = 0;
      while (placed < fenceCount && safety < 1000) {
        safety++;
        int r = _random.nextInt(boardSize);
        int c = _random.nextInt(boardSize);
        if (_board[r][c] != CellContent.empty ||
            (r == centerRow && c == centerCol)) {
          continue;
        }
        double dist = sqrt(pow(r - centerRow, 2) + pow(c - centerCol, 2));
        if (_random.nextDouble() < 1.0 / (dist * 0.3 + 1.0)) {
          _board[r][c] = CellContent.fence;
          placed++;
        }
      }

      if (hasPathToEdge()) return;
    }
  }

  List<Position> getNeighbors(int r, int c) {
    List<Position> neighbors = [];
    List<List<int>> dirs = (r % 2 == 0)
        ? [[-1, -1], [-1, 0], [0, -1], [0, 1], [1, -1], [1, 0]]
        : [[-1, 0], [-1, 1], [0, -1], [0, 1], [1, 0], [1, 1]];

    for (var d in dirs) {
      int nr = r + d[0];
      int nc = c + d[1];
      if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize) {
        neighbors.add(Position(nr, nc));
      }
    }
    return neighbors;
  }

  List<Position> getAdjacentEmpty(int r, int c) {
    return getNeighbors(r, c)
        .where((p) => _board[p.row][p.col] == CellContent.empty)
        .toList();
  }

  bool isValidMove(int r, int c) {
    if (_state != GameState.playing || !_isPlayerTurn) return false;
    if (_board[r][c] != CellContent.empty) return false;
    return getNeighbors(_catRow, _catCol).any((p) => p.row == r && p.col == c);
  }

  bool moveCat(int r, int c) {
    if (!isValidMove(r, c)) return false;

    _board[_catRow][_catCol] = CellContent.empty;
    _catRow = r;
    _catCol = c;
    _board[r][c] = CellContent.cat;
    _isPlayerTurn = false;

    if (_isOnEdge(r, c)) {
      _state = GameState.catWins;
      _scoreCat++;
      return true;
    }

    if (!hasAnyMove()) {
      _state = GameState.fenceWins;
      _scoreFence++;
      return true;
    }

    return true;
  }

  bool placeFence(int r, int c) {
    if (_state != GameState.playing || _isPlayerTurn) return false;
    if (_board[r][c] != CellContent.empty) return false;

    _board[r][c] = CellContent.fence;

    if (!hasPathToEdge()) {
      _state = GameState.fenceWins;
      _scoreFence++;
      _isPlayerTurn = false;
      return true;
    }

    if (!hasAnyMove()) {
      _state = GameState.fenceWins;
      _scoreFence++;
      _isPlayerTurn = false;
      return true;
    }

    _isPlayerTurn = true;
    return true;
  }

  bool _isOnEdge(int r, int c) =>
      r == 0 || r == boardSize - 1 || c == 0 || c == boardSize - 1;

  bool hasAnyMove() => getAdjacentEmpty(_catRow, _catCol).isNotEmpty;

  bool hasPathToEdge() {
    Set<Position> visited = {};
    Queue<Position> queue = Queue();
    Position start = Position(_catRow, _catCol);
    queue.add(start);
    visited.add(start);

    while (queue.isNotEmpty) {
      var pos = queue.removeFirst();
      if (_isOnEdge(pos.row, pos.col)) return true;

      for (var neighbor in getNeighbors(pos.row, pos.col)) {
        if (_board[neighbor.row][neighbor.col] != CellContent.fence &&
            !visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }
    return false;
  }

  List<Position>? findShortestPathToEdge() {
    Set<Position> visited = {};
    Queue<List<Position>> queue = Queue();
    List<Position> start = [Position(_catRow, _catCol)];
    queue.add(start);
    visited.add(start.first);

    while (queue.isNotEmpty) {
      var path = queue.removeFirst();
      var pos = path.last;

      if (_isOnEdge(pos.row, pos.col)) return path;

      for (var neighbor in getNeighbors(pos.row, pos.col)) {
        if (_board[neighbor.row][neighbor.col] != CellContent.fence &&
            !visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add([...path, neighbor]);
        }
      }
    }
    return null;
  }

  Position? findBestFencePlacement() {
    if (_state != GameState.playing) return null;

    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (_board[r][c] != CellContent.empty) continue;
        _board[r][c] = CellContent.fence;
        bool wins = !hasAnyMove() || !hasPathToEdge();
        _board[r][c] = CellContent.empty;
        if (wins) return Position(r, c);
      }
    }

    Set<Position> candidates = {};
    var currentPath = findShortestPathToEdge();
    
    if (currentPath != null) {
      candidates.addAll(currentPath.skip(1));
      
      candidates.addAll(getAdjacentEmpty(_catRow, _catCol));

      for (var neighbor in getNeighbors(_catRow, _catCol)) {
        for (var secondNeighbor in getNeighbors(neighbor.row, neighbor.col)) {
          if (_board[secondNeighbor.row][secondNeighbor.col] == CellContent.empty) {
            candidates.add(secondNeighbor);
          }
        }
      }
    }

    List<ScoredMove> scored = [];
    for (var c in candidates) {
      if (_board[c.row][c.col] != CellContent.empty) continue;

      _board[c.row][c.col] = CellContent.fence;
      int score = _evaluateCatBestResponse() + _wallBonus(c) * 8;
      _board[c.row][c.col] = CellContent.empty;

      scored.add(ScoredMove(c, score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    Position? bestRefined;
    int bestRefinedScore = -1000000;
    int refineCount = scored.length < 18 ? scored.length : 18;

    for (int i = 0; i < refineCount; i++) {
      var move = scored[i].move;
      _board[move.row][move.col] = CellContent.fence;
      int plyScore = _evaluate3Ply();
      _board[move.row][move.col] = CellContent.empty;

      if (plyScore > bestRefinedScore) {
        bestRefinedScore = plyScore;
        bestRefined = move;
      }
    }

    return bestRefined ?? (scored.isNotEmpty ? scored.first.move : null);
  }
  int _wallBonus(Position p) {
    int bonus = 0;
    for (var n in getNeighbors(p.row, p.col)) {
      if (_board[n.row][n.col] == CellContent.fence) bonus += 3;
    }
    return bonus;
  }

  int _evaluateCatBestResponse() {
  var adjacentMoves = getAdjacentEmpty(_catRow, _catCol);
  if (adjacentMoves.isEmpty) return 100000;

  int totalScore = 0;
  int shortestPathLen = 100000;

  totalScore -= (adjacentMoves.length * 15);

  for (var move in adjacentMoves) {
    int savedRow = _catRow;
    int savedCol = _catCol;
    
    _board[_catRow][_catCol] = CellContent.empty;
    _catRow = move.row;
    _catCol = move.col;
    _board[_catRow][_catCol] = CellContent.cat;

    var path = findShortestPathToEdge();
    if (path == null) {
      totalScore += 500;
    } else {
      int len = path.length;
      if (len < shortestPathLen) shortestPathLen = len;
      totalScore += (len * 20); 
    }

    _board[_catRow][_catCol] = CellContent.empty;
    _catRow = savedRow;
    _catCol = savedCol;
    _board[_catRow][_catCol] = CellContent.cat;
  }

    if (shortestPathLen <= 1) return -5000;

    return totalScore + (shortestPathLen * 10);
  }

  int _evaluate3Ply() {
    if (!hasAnyMove() || !hasPathToEdge()) return 100000;

    int minScore = 100000;
    int savedRow = _catRow;
    int savedCol = _catCol;

    for (var move in getAdjacentEmpty(_catRow, _catCol)) {
      _board[_catRow][_catCol] = CellContent.empty;
      _catRow = move.row;
      _catCol = move.col;
      _board[_catRow][_catCol] = CellContent.cat;

      int score;
      if (_isOnEdge(_catRow, _catCol)) {
        score = 0;
      } else {
        score = _bestNextFenceScore();
      }

      _board[_catRow][_catCol] = CellContent.empty;
      _catRow = savedRow;
      _catCol = savedCol;
      _board[_catRow][_catCol] = CellContent.cat;

      if (score < minScore) minScore = score;
      if (minScore == 0) break;
    }

    return minScore;
  }

  int _bestNextFenceScore() {
    if (!hasAnyMove()) return 100000;
    var path = findShortestPathToEdge();
    if (path == null) return 100000;

    int bestScore = -1;
    Set<Position> candidates = {};

    for (int i = 1; i < path.length && i < 6; i++) {
      if (_board[path[i].row][path[i].col] == CellContent.empty) {
        candidates.add(path[i]);
      }
    }
    for (var n in getAdjacentEmpty(_catRow, _catCol)) {
      candidates.add(n);
    }

    for (var c in candidates) {
      if (_board[c.row][c.col] != CellContent.empty) continue;

      _board[c.row][c.col] = CellContent.fence;
      int score;
      if (!hasAnyMove() || !hasPathToEdge()) {
        score = 100000;
      } else {
        var newPath = findShortestPathToEdge();
        score = (newPath == null) ? 100000 : newPath.length;
      }
      _board[c.row][c.col] = CellContent.empty;

      if (score > bestScore) bestScore = score;
    }

    return bestScore;
  }

  void cpuTurn() {
    if (_state != GameState.playing || _isPlayerTurn) return;

    var best = findBestFencePlacement();
    if (best != null) {
      placeFence(best.row, best.col);
    } else {
      for (int r = 0; r < boardSize; r++) {
        for (int c = 0; c < boardSize; c++) {
          if (_board[r][c] == CellContent.empty) {
            placeFence(r, c);
            return;
          }
        }
      }
    }
  }

  void resetScores() {
    _scoreCat = 0;
    _scoreFence = 0;
  }
}