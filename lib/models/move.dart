import 'package:chess_app/models/models.dart';

class Move {
  final Square from;
  final Square to;
  final Piece piece;

  final PieceType? promoteTo;

  final Piece? capturedPiece;

  final bool isCastle;
  final bool isEnPassant;

  const Move({
    required this.from,
    required this.to,
    required this.piece,
    this.capturedPiece,
    this.promoteTo,
    this.isCastle = false,
    this.isEnPassant = false,
  });
}
