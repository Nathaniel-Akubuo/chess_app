class Square {
  final int index;

  const Square(this.index) : assert(index >= 0 && index < 64);

  static Square fromFileRank(int file, int rank) {
    return Square(rank * 8 + file);
  }

  static Square fromAlgebraic(String notation) {
    if (notation.length != 2) {
      throw FormatException('Invalid algebraic notation: $notation');
    }

    final fileChar = notation[0].toLowerCase();
    final rankChar = notation[1];

    final file = fileChar.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(rankChar) - 1;

    if (file < 0 || file > 7 || rank < 0 || rank > 7) {
      throw FormatException('Invalid algebraic notation: $notation');
    }

    return Square.fromFileRank(file, rank);
  }

  String get algebraic {
    final fileChar = String.fromCharCode('a'.codeUnitAt(0) + file);
    return '$fileChar${rank + 1}';
  }

  int get file => index % 8;
  int get rank => index ~/ 8;

  @override
  bool operator ==(covariant Square other) {
    if (identical(this, other)) return true;

    return other.index == index;
  }

  @override
  int get hashCode => index.hashCode;
}
