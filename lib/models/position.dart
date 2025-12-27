import 'package:chess_app/util/extensions.dart';

import 'models.dart';

class Position {
  final List<Piece> pieces;
  final PieceColor sideToMove;

  final bool whiteCanCastleKingSide;
  final bool whiteCanCastleQueenSide;
  final bool blackCanCastleKingSide;
  final bool blackCanCastleQueenSide;

  final int halfMoveCount;
  final int fullMoveNumber;
  final Square? enPassantSquare;
  final String id;

  const Position({
    required this.pieces,
    required this.sideToMove,
    required this.whiteCanCastleKingSide,
    required this.whiteCanCastleQueenSide,
    required this.blackCanCastleKingSide,
    required this.blackCanCastleQueenSide,
    required this.halfMoveCount,
    required this.fullMoveNumber,
    this.enPassantSquare,
    this.id = '',
  });

  Piece? pieceAt(Square square) => pieces.nullableFirstWhere((e) => e.square == square);

  factory Position.initial() {
    final List<Piece> pieces = [];

    void add(PieceType type, PieceColor color, int file, int rank) {
      final square = Square.fromFileRank(file, rank);
      pieces.add(
        Piece(
          type: type,
          color: color,
          square: square,
          initialSquare: square,
        ),
      );
    }

    void backRank(PieceColor color, int rank) {
      add(PieceType.rook, color, 0, rank);
      add(PieceType.knight, color, 1, rank);
      add(PieceType.bishop, color, 2, rank);
      add(PieceType.queen, color, 3, rank);
      add(PieceType.king, color, 4, rank);
      add(PieceType.bishop, color, 5, rank);
      add(PieceType.knight, color, 6, rank);
      add(PieceType.rook, color, 7, rank);
    }

    void pawns(PieceColor color, int rank) {
      for (int file = 0; file < 8; file++) {
        add(PieceType.pawn, color, file, rank);
      }
    }

    backRank(PieceColor.white, 0);
    pawns(PieceColor.white, 1);

    backRank(PieceColor.black, 7);
    pawns(PieceColor.black, 6);

    return Position(
      pieces: pieces,
      sideToMove: PieceColor.white,
      whiteCanCastleKingSide: true,
      whiteCanCastleQueenSide: true,
      blackCanCastleKingSide: true,
      blackCanCastleQueenSide: true,
      enPassantSquare: null,
      halfMoveCount: 0,
      fullMoveNumber: 1,
    );
  }

  Position copyWith({
    List<Piece>? pieces,
    PieceColor? sideToMove,
    bool? whiteCanCastleKingSide,
    bool? whiteCanCastleQueenSide,
    bool? blackCanCastleKingSide,
    bool? blackCanCastleQueenSide,
    int? halfMoveCount,
    int? fullMoveNumber,
    Square? enPassantSquare,
    String? id,
  }) {
    return Position(
      pieces: pieces ?? this.pieces,
      sideToMove: sideToMove ?? this.sideToMove,
      whiteCanCastleKingSide: whiteCanCastleKingSide ?? this.whiteCanCastleKingSide,
      whiteCanCastleQueenSide: whiteCanCastleQueenSide ?? this.whiteCanCastleQueenSide,
      blackCanCastleKingSide: blackCanCastleKingSide ?? this.blackCanCastleKingSide,
      blackCanCastleQueenSide: blackCanCastleQueenSide ?? this.blackCanCastleQueenSide,
      halfMoveCount: halfMoveCount ?? this.halfMoveCount,
      fullMoveNumber: fullMoveNumber ?? this.fullMoveNumber,
      enPassantSquare: enPassantSquare ?? this.enPassantSquare,
      id: id ?? this.id,
    );
  }

  String toFEN() {
    final buffer = StringBuffer();

    // 1. Piece placement
    for (int rank = 7; rank >= 0; rank--) {
      int emptyCount = 0;

      for (int file = 0; file < 8; file++) {
        final piece =
            pieces.nullableFirstWhere((p) => p.square?.file == file && p.square?.rank == rank);

        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            buffer.write(emptyCount);
            emptyCount = 0;
          }
          buffer.write(_pieceToFENChar(piece));
        }
      }

      if (emptyCount > 0) buffer.write(emptyCount);
      if (rank > 0) buffer.write('/');
    }

    // 2. Active color
    buffer.write(' ');
    buffer.write(sideToMove == PieceColor.white ? 'w' : 'b');

    // 3. Castling rights
    buffer.write(' ');
    final castling = [
      whiteCanCastleKingSide ? 'K' : '',
      whiteCanCastleQueenSide ? 'Q' : '',
      blackCanCastleKingSide ? 'k' : '',
      blackCanCastleQueenSide ? 'q' : ''
    ].where((s) => s.isNotEmpty).join();
    buffer.write(castling.isEmpty ? '-' : castling);

    // 4. En passant square
    buffer.write(' ');
    buffer.write(enPassantSquare?.algebraic ?? '-');

    // 5. Halfmove clock
    buffer.write(' ');
    buffer.write(halfMoveCount);

    // 6. Fullmove number
    buffer.write(' ');
    buffer.write(fullMoveNumber);

    return buffer.toString();
  }

  String _pieceToFENChar(Piece piece) {
    final c = {
      PieceType.pawn: 'p',
      PieceType.knight: 'n',
      PieceType.bishop: 'b',
      PieceType.rook: 'r',
      PieceType.queen: 'q',
      PieceType.king: 'k',
    }[piece.type]!;

    return piece.color == PieceColor.white ? c.toUpperCase() : c;
  }
}
