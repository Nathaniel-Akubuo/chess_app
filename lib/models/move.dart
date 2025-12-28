import 'package:chess_app/models/models.dart';

class Move {
  final Square from;
  final Square destination;
  final Piece piece;
  final PieceType? promoteTo;
  final Piece? capturedPiece;
  final String id;
  final bool isCheck;
  final bool isMate;
  final String? san;
  final Duration? duration;

  const Move({
    required this.from,
    required this.destination,
    required this.piece,
    this.capturedPiece,
    this.promoteTo,
    this.isCheck = false,
    this.isMate = false,
    this.id = '',
    this.san,
    this.duration,
  });

  Move copyWith({
    Square? from,
    Square? destination,
    Piece? piece,
    PieceType? promoteTo,
    Piece? capturedPiece,
    String? id,
    bool? isCheck,
    bool? isMate,
    String? san,
    Duration? duration,
  }) {
    return Move(
      from: from ?? this.from,
      destination: destination ?? this.destination,
      piece: piece ?? this.piece,
      promoteTo: promoteTo ?? this.promoteTo,
      capturedPiece: capturedPiece ?? this.capturedPiece,
      id: id ?? this.id,
      isCheck: isCheck ?? this.isCheck,
      isMate: isMate ?? this.isMate,
      san: san ?? this.san,
      duration: duration ?? this.duration,
    );
  }

  bool get isCastlingMove {
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
