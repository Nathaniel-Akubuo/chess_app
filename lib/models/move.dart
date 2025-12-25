import 'package:chess_app/models/models.dart';

class Move {
  final Square from;
  final Square destination;
  final Piece piece;

  final PieceType? promoteTo;

  final Piece? capturedPiece;
  final String id;

  const Move({
    required this.from,
    required this.destination,
    required this.piece,
    this.capturedPiece,
    this.promoteTo,
    this.id = '',
  });

  bool isCastlingMove() {
    if (piece.type != PieceType.king) return false;
    if (from.rank != destination.rank) return false;
    return (from.file - destination.file).abs() == 2;
  }

  bool isEnPassantMove(Square? enPassantSquare) {
    if (piece.type != PieceType.pawn) return false;
    if (enPassantSquare == null) return false;

    final isDiagonal =
        (from.file - destination.file).abs() == 1 && (from.rank - destination.rank).abs() == 1;

    return isDiagonal && destination == enPassantSquare;
  }
}
