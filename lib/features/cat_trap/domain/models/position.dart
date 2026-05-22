class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) {
    return other is Position && row == other.row && col == other.col;
  }

  @override
  int get hashCode => row * 31 + col;

  @override
  String toString() => '($row, $col)';
}