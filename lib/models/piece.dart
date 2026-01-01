import 'package:chess_app/models/square.dart';

enum PieceType { pawn, knight, bishop, rook, queen, king }

enum PieceColor { white, black }

class Piece {
  final Square initialSquare;
  PieceType type;
  PieceColor color;
  Square? square;

  Piece({
    required this.type,
    required this.color,
    required this.initialSquare,
    this.square,
  });

  int get materialValue {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 0;
    }
  }

  @override
  bool operator ==(covariant Piece other) {
    if (identical(this, other)) return true;

    return other.initialSquare == initialSquare;
  }

  @override
  int get hashCode {
    return initialSquare.hashCode;
  }

  Piece copyWith({
    PieceType? type,
    PieceColor? color,
    Square? square,
  }) {
    return Piece(
      type: type ?? this.type,
      color: color ?? this.color,
      initialSquare: initialSquare,
      square: square ?? this.square,
    );
  }
}
