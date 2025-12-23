import 'package:chess_app/models/models.dart';

class Move {
  final Square from;
  final Square destination;
  final Piece piece;

  final PieceType? promoteTo;

  final Piece? capturedPiece;

  final bool isCastle;
  final bool isEnPassant;

  const Move({
    required this.from,
    required this.destination,
    required this.piece,
    this.capturedPiece,
    this.promoteTo,
    this.isCastle = false,
    this.isEnPassant = false,
  });
}
