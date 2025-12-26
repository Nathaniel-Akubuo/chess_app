import 'package:chess_app/models/models.dart';

extension MoveValidatorExtension on Position {
  List<Square> validSquaresForPiece(Piece piece) {
    assert(piece.square != null, 'Piece must have a valid square');
    return allSquaresForPiece(piece)
        .where(
          (toSquare) => validateMove(
            Move(
              from: piece.square!,
              destination: toSquare,
              piece: piece,
            ),
          ),
        )
        .toList();
  }

  List<Square> allSquaresForPiece(Piece piece) {
    final squares = <Square>[];

    final from = piece.square!;
    final directions = <List<int>>[];

    switch (piece.type) {
      case PieceType.pawn:
        final dir = piece.color == PieceColor.white ? 1 : -1;
        final startRank = piece.color == PieceColor.white ? 1 : 6;

        // Forward moves
        final oneForward = Square.fromFileRank(from.file, from.rank + dir);
        if (pieceAt(oneForward) == null) squares.add(oneForward);

        final twoForward = Square.fromFileRank(from.file, from.rank + 2 * dir);
        if (from.rank == startRank && pieceAt(oneForward) == null && pieceAt(twoForward) == null) {
          squares.add(twoForward);
        }

        // Captures
        for (final df in [-1, 1]) {
          final targetFile = from.file + df;
          if (targetFile < 0 || targetFile > 7) continue;
          final targetSquare = Square.fromFileRank(from.file + df, from.rank + dir);
          final targetPiece = pieceAt(targetSquare);

          if (targetPiece != null && targetPiece.color != piece.color) {
            squares.add(targetSquare);
          }
          // En passant
          if (targetSquare == enPassantSquare) {
            squares.add(targetSquare);
          }
        }
        break;

      case PieceType.knight:
        final jumps = [
          [1, 2],
          [2, 1],
          [-1, 2],
          [-2, 1],
          [1, -2],
          [2, -1],
          [-1, -2],
          [-2, -1]
        ];
        for (final jump in jumps) {
          final x = from.file + jump[0];
          final y = from.rank + jump[1];
          if (x < 0 || x > 7 || y < 0 || y > 7) continue;

          final target = Square.fromFileRank(x, y);
          final targetPiece = pieceAt(target);
          if (targetPiece == null || targetPiece.color != piece.color) {
            squares.add(target);
          }
        }
        break;

      case PieceType.bishop:
        directions.addAll([
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1]
        ]);
        squares.addAll(_slidingSquares(piece, directions));
        break;

      case PieceType.rook:
        directions.addAll([
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1]
        ]);
        squares.addAll(_slidingSquares(piece, directions));
        break;

      case PieceType.queen:
        directions.addAll([
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ]);
        squares.addAll(_slidingSquares(piece, directions));
        break;

      case PieceType.king:
        for (final dx in [-1, 0, 1]) {
          for (final dy in [-1, 0, 1]) {
            if (dx == 0 && dy == 0) continue;
            final x = from.file + dx;
            final y = from.rank + dy;
            if (x < 0 || x > 7 || y < 0 || y > 7) continue;

            final target = Square.fromFileRank(x, y);
            final targetPiece = pieceAt(target);
            if (targetPiece == null || targetPiece.color != piece.color) {
              squares.add(target);
            }
          }
        }

        // Castling squares
        for (final df in [-2, 2]) {
          final to = Square.fromFileRank(from.file + df, from.rank);
          if (_validateCastling(piece, from, to)) {
            squares.add(to);
          }
        }
        break;
    }

    return squares;
  }

  List<Square> _slidingSquares(Piece piece, List<List<int>> directions) {
    final squares = <Square>[];
    final from = piece.square!;
    for (final dir in directions) {
      var x = from.file;
      var y = from.rank;
      while (true) {
        x += dir[0];
        y += dir[1];
        if (x < 0 || x > 7 || y < 0 || y > 7) break;

        final target = Square.fromFileRank(x, y);
        final targetPiece = pieceAt(target);
        if (targetPiece == null) {
          squares.add(target);
        } else {
          if (targetPiece.color != piece.color) {
            squares.add(target);
          }
          break;
        }
      }
    }
    return squares;
  }

  Position update(Move move) {
    assert(validateMove(move));
    var piece = move.piece;

    final nextPieces = List<Piece>.from(pieces);
    final isCastle = move.isCastlingMove;
    if (move.isEnPassantMove(enPassantSquare)) {
      var dir = piece.color == PieceColor.white ? -1 : 1;
      var destination = move.destination;
      var captureSquare = Square.fromFileRank(destination.file, destination.rank + dir);

      final index = nextPieces.indexWhere((e) => e.initialSquare == piece.initialSquare);
      final movingPiece = move.piece.copyWith(type: move.promoteTo, square: move.destination);

      nextPieces.removeWhere((e) => e.square == captureSquare);
      nextPieces[index] = movingPiece;

      return Position(
        pieces: nextPieces,
        sideToMove: _opposite(sideToMove),
        enPassantSquare: _computeEnPassant(piece, move.from, destination),
        halfMoveCount: movingPiece.type == PieceType.pawn || pieceAt(move.destination) != null
            ? 0
            : halfMoveCount + 1,
        fullMoveNumber: sideToMove == PieceColor.black ? fullMoveNumber + 1 : fullMoveNumber,
        whiteCanCastleKingSide: whiteCanCastleKingSide,
        whiteCanCastleQueenSide: whiteCanCastleQueenSide,
        blackCanCastleKingSide: blackCanCastleKingSide,
        blackCanCastleQueenSide: blackCanCastleQueenSide,
      );
    } else if (isCastle) {
      var from = move.from;

      final isKingSide = move.destination.file > from.file;

      final rookFrom = Square.fromFileRank(
        isKingSide ? 7 : 0,
        from.rank,
      );

      final rookTo = Square.fromFileRank(
        isKingSide ? 5 : 3,
        from.rank,
      );

      var rook = pieceAt(rookFrom)?.copyWith(square: rookTo);
      var king = move.piece.copyWith(square: move.destination);
      final rookIndex = nextPieces.indexWhere((e) => e.square == rookFrom);
      final kingIndex = nextPieces.indexWhere((e) => e.square == move.from);
      final isBlack = king.color == PieceColor.black;
      nextPieces[rookIndex] = rook!;
      nextPieces[kingIndex] = king;

      return Position(
        pieces: nextPieces,
        sideToMove: _opposite(sideToMove),
        enPassantSquare: _computeEnPassant(king, move.from, move.destination),
        halfMoveCount: king.type == PieceType.pawn || pieceAt(move.destination) != null
            ? 0
            : halfMoveCount + 1,
        fullMoveNumber: sideToMove == PieceColor.black ? fullMoveNumber + 1 : fullMoveNumber,
        whiteCanCastleKingSide: isBlack ? whiteCanCastleKingSide : false,
        whiteCanCastleQueenSide: isBlack ? whiteCanCastleQueenSide : false,
        blackCanCastleKingSide: isBlack ? false : blackCanCastleKingSide,
        blackCanCastleQueenSide: isBlack ? false : blackCanCastleQueenSide,
      );
    } else {
      nextPieces.removeWhere((p) => p.square == move.destination);

      final movingPiece = move.piece.copyWith(type: move.promoteTo, square: move.destination);

      final index = nextPieces.indexWhere((p) => p.initialSquare == piece.initialSquare);
      nextPieces[index] = movingPiece;
      final isBlack = piece.color == PieceColor.black;
      return Position(
        pieces: nextPieces,
        sideToMove: _opposite(sideToMove),
        enPassantSquare: _computeEnPassant(movingPiece, move.from, move.destination),
        halfMoveCount: movingPiece.type == PieceType.pawn || pieceAt(move.destination) != null
            ? 0
            : halfMoveCount + 1,
        fullMoveNumber: sideToMove == PieceColor.black ? fullMoveNumber + 1 : fullMoveNumber,
        whiteCanCastleKingSide: isBlack
            ? whiteCanCastleKingSide
            : _updateKingSideCastlingRight(whiteCanCastleKingSide, movingPiece),
        whiteCanCastleQueenSide: isBlack
            ? whiteCanCastleQueenSide
            : _updateQueenSideCastlingRight(whiteCanCastleQueenSide, movingPiece),
        blackCanCastleKingSide: isBlack
            ? _updateKingSideCastlingRight(blackCanCastleKingSide, movingPiece)
            : blackCanCastleKingSide,
        blackCanCastleQueenSide: isBlack
            ? _updateQueenSideCastlingRight(blackCanCastleQueenSide, movingPiece)
            : blackCanCastleQueenSide,
      );
    }
  }

  PieceColor _opposite(PieceColor c) => c == PieceColor.white ? PieceColor.black : PieceColor.white;

  bool _updateKingSideCastlingRight(bool current, Piece piece) {
    if (current == false) return false;

    if (piece.type == PieceType.king) {
      return false;
    }

    if (piece.type == PieceType.rook && piece.initialSquare.file == 7) {
      return piece.initialSquare.file == piece.square?.file;
    }

    return true;
  }

  bool _updateQueenSideCastlingRight(bool current, Piece piece) {
    if (current == false) return false;

    if (piece.type == PieceType.king) {
      return false;
    }

    if (piece.type == PieceType.rook && piece.initialSquare.file == 0) {
      return piece.initialSquare.file == piece.square?.file;
    }

    return true;
  }

  Square? _computeEnPassant(
    Piece piece,
    Square from,
    Square to,
  ) {
    if (piece.type != PieceType.pawn) {
      return null;
    } else if ((from.rank - to.rank).abs() == 2) {
      return Square.fromFileRank(
        from.file,
        (from.rank + to.rank) ~/ 2,
      );
    }
    return null;
  }

  bool isInCheck(PieceColor color) {
    final king = pieces.firstWhere((p) => p.type == PieceType.king && p.color == color);

    final kingSquare = king.square!;

    for (final piece in pieces) {
      if (piece.color == color) continue;

      final move = Move(from: piece.square!, destination: kingSquare, piece: piece);
      if (_validatePieceMove(piece, move, king)) {
        return true;
      }
    }

    return false;
  }

  bool hasAnyLegalMove(PieceColor color) {
    for (final piece in pieces.where((p) => p.color == color)) {
      final moves = validSquaresForPiece(piece);
      if (moves.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  List<Move> allValidMoves() {
    final moves = <Move>[];

    for (final piece in pieces.where((p) => p.color == sideToMove)) {
      for (final square in validSquaresForPiece(piece)) {
        final move = Move(
          from: piece.square!,
          destination: square,
          piece: piece,
        );
        var newPosition = update(move);

        moves.add(move.copyWith(
          isCheck: newPosition.isInCheck(newPosition.sideToMove),
          isMate: newPosition.isCheckmate(newPosition.sideToMove),
          capturedPiece: pieceAt(square)
        ));
      }
    }

    return moves;
  }

  bool isCheckmate(PieceColor color) {
    if (isInCheck(color) == false) return false;
    if (hasAnyLegalMove(color)) return false;
    return true;
  }

  bool isStalemate(PieceColor color) {
    if (isInCheck(color)) return false;
    if (hasAnyLegalMove(color)) return false;
    return true;
  }

  bool validateMove(Move move) {
    final piece = pieceAt(move.from);

    if (piece == null) return false;

    if (piece.color != sideToMove) return false;

    final target = pieceAt(move.destination);
    if (target != null && target.color == piece.color) {
      return false;
    }

    if (!_validatePieceMove(piece, move, target)) {
      return false;
    }

    final simulated = _simulateMove(move);
    if (simulated.isInCheck(piece.color)) {
      return false;
    }

    return true;
  }

  Position _simulateMove(Move move) {
    var piece = move.piece;

    final nextPieces = List<Piece>.from(pieces);

    nextPieces.removeWhere((p) => p.square == move.destination);

    final movingPiece = move.piece.copyWith(type: move.promoteTo, square: move.destination);

    final index = nextPieces.indexWhere((p) => p.initialSquare == piece.initialSquare);
    nextPieces[index] = movingPiece;

    return Position(
      pieces: nextPieces,
      sideToMove: sideToMove,
      whiteCanCastleKingSide: whiteCanCastleKingSide,
      whiteCanCastleQueenSide: whiteCanCastleQueenSide,
      blackCanCastleKingSide: blackCanCastleKingSide,
      blackCanCastleQueenSide: blackCanCastleQueenSide,
      enPassantSquare: enPassantSquare,
      halfMoveCount: halfMoveCount,
      fullMoveNumber: fullMoveNumber,
    );
  }

  bool _validatePieceMove(
    Piece piece,
    Move move,
    Piece? target,
  ) {
    final from = move.from;
    final to = move.destination;

    final deltaFile = to.file - from.file;
    final deltaRank = to.rank - from.rank;

    switch (piece.type) {
      case PieceType.pawn:
        return _validatePawn(piece, from, to, target);
      case PieceType.knight:
        return (deltaFile.abs() == 1 && deltaRank.abs() == 2) ||
            (deltaFile.abs() == 2 && deltaRank.abs() == 1);
      case PieceType.bishop:
        return deltaFile.abs() == deltaRank.abs() && _pathIsClear(from, to);
      case PieceType.rook:
        return (deltaFile == 0 || deltaRank == 0) && _pathIsClear(from, to);
      case PieceType.queen:
        return ((deltaFile == 0 || deltaRank == 0) || deltaFile.abs() == deltaRank.abs()) &&
            _pathIsClear(from, to);
      case PieceType.king:
        return _validateKing(piece, from, to);
    }
  }

  bool _pathIsClear(Square from, Square to) {
    final stepFile = (to.file - from.file).sign;
    final stepRank = (to.rank - from.rank).sign;

    var file = from.file + stepFile;
    var rank = from.rank + stepRank;

    while (file != to.file || rank != to.rank) {
      if (pieceAt(Square.fromFileRank(file, rank)) != null) {
        return false;
      }
      file += stepFile;
      rank += stepRank;
    }

    return true;
  }

  bool _validatePawn(
    Piece piece,
    Square from,
    Square to,
    Piece? target,
  ) {
    final direction = piece.color == PieceColor.white ? 1 : -1;

    final startRank = piece.color == PieceColor.white ? 1 : 6;

    final deltaFile = to.file - from.file;
    final deltaRank = to.rank - from.rank;

    if (deltaFile == 0 && target == null) {
      if (deltaRank == direction) return true;

      if (from.rank == startRank &&
          deltaRank == 2 * direction &&
          pieceAt(
                Square.fromFileRank(from.file, from.rank + direction),
              ) ==
              null) {
        return true;
      }
    }

    if (deltaFile.abs() == 1 && deltaRank == direction) {
      if (target != null) return true;
      if (to == enPassantSquare) return true;
    }

    return false;
  }

  bool _validateKing(
    Piece piece,
    Square from,
    Square to,
  ) {
    final deltaFile = to.file - from.file;
    final deltaRank = (to.rank - from.rank).abs();

    // Normal king move
    if (deltaFile.abs() <= 1 && deltaRank <= 1) return true;

    // Castling
    if (deltaRank == 0 && deltaFile.abs() == 2) {
      return _validateCastling(piece, from, to);
    }

    return false;
  }

  bool _validateCastling(
    Piece king,
    Square from,
    Square to,
  ) {
    if (isInCheck(king.color)) return false;

    final isKingSide = to.file > from.file;

    final canCastle = king.color == PieceColor.white
        ? (isKingSide ? whiteCanCastleKingSide : whiteCanCastleQueenSide)
        : (isKingSide ? blackCanCastleKingSide : blackCanCastleQueenSide);

    if (!canCastle) return false;

    final rookFile = isKingSide ? 7 : 0;
    final rook = pieceAt(
      Square.fromFileRank(rookFile, from.rank),
    );

    if (rook == null || rook.type != PieceType.rook) {
      return false;
    }

    // Path between king and rook must be empty
    final step = isKingSide ? 1 : -1;
    for (int file = from.file + step; file != rookFile; file += step) {
      if (pieceAt(Square.fromFileRank(file, from.rank)) != null) {
        return false;
      }
    }

    // King cannot pass through check
    for (int i = 1; i <= 2; i++) {
      final intermediate = Square.fromFileRank(
        from.file + i * step,
        from.rank,
      );

      final simulated = _simulateMove(Move(from: from, destination: intermediate, piece: king));

      if (simulated.isInCheck(king.color)) {
        return false;
      }
    }

    return true;
  }
}
