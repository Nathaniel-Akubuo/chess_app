class Square {
  final int index;

  const Square(this.index) : assert(index >= 0 && index < 64);

  int get file => index % 8;
  int get rank => index ~/ 8;

  static Square fromFileRank(int file, int rank) {
    return Square(rank * 8 + file);
  }

  String get algebraic {
    final fileChar = String.fromCharCode('a'.codeUnitAt(0) + file);
    return '$fileChar${rank + 1}';
  }

  @override
  bool operator ==(covariant Square other) {
    if (identical(this, other)) return true;

    return other.index == index;
  }

  @override
  int get hashCode => index.hashCode;
}
