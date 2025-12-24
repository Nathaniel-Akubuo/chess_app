import 'package:chess_app/models/models.dart';

class Move {
  final Square from;
  final Square destination;
  final Piece piece;

  final PieceType? promoteTo;

  final Piece? capturedPiece;

  const Move({
    required this.from,
    required this.destination,
    required this.piece,
    this.capturedPiece,
    this.promoteTo,
  });

  bool isCastlingMove() {
    if (piece.type != PieceType.king) return false;
    if (from.rank != destination.rank) return false;
    return (from.file - destination.file).abs() == 2;
  }
}
