import 'package:chess_app/util/extensions.dart';
import 'package:chess_app/util/move_validator_extension.dart';

import '../models/models.dart';

extension GameExtensions on Game {
  List<List<Move>> get movePairs => moves.chunk(2);

  String get pgn {
    final buffer = StringBuffer();

    for (int i = 0; i < moves.length; i++) {
      final move = moves[i];
      final positionBefore = positions[i];

      final isWhiteMove = positionBefore.sideToMove == PieceColor.white;

      if (isWhiteMove) {
        buffer.write('${(i ~/ 2) + 1}. ');
      }

      final san = move.toAlgebraic;

      buffer.write('$san ');
    }

    return buffer.toString().trim();
  }
}

extension MoveExtension on Move {
  String get toAlgebraic {
    // Castling
    if (piece.type == PieceType.king &&
        from.rank == destination.rank &&
        (from.file - destination.file).abs() == 2) {
      return destination.file == 6 ? 'O-O' : 'O-O-O';
    }

    final buffer = StringBuffer();

    // Piece letter (pawns have none)
    switch (piece.type) {
      case PieceType.king:
        buffer.write('K');
        break;
      case PieceType.queen:
        buffer.write('Q');
        break;
      case PieceType.rook:
        buffer.write('R');
        break;
      case PieceType.bishop:
        buffer.write('B');
        break;
      case PieceType.knight:
        buffer.write('N');
        break;
      case PieceType.pawn:
        break;
    }

    final isPawnDiagonalMove = piece.type == PieceType.pawn &&
        (from.file - destination.file).abs() == 1 &&
        (from.rank - destination.rank).abs() == 1;

    final isCapture = capturedPiece != null || isPawnDiagonalMove;

    // Pawn captures include source file
    if (piece.type == PieceType.pawn && isCapture) {
      buffer.write(
        String.fromCharCode('a'.codeUnitAt(0) + from.file),
      );
    }

    if (isCapture) {
      buffer.write('x');
    }

    buffer.write(destination.algebraic);

    // Promotion
    if (promoteTo != null) {
      buffer.write('=');
      switch (promoteTo!) {
        case PieceType.queen:
          buffer.write('Q');
          break;
        case PieceType.rook:
          buffer.write('R');
          break;
        case PieceType.bishop:
          buffer.write('B');
          break;
        case PieceType.knight:
          buffer.write('N');
          break;
        case PieceType.king:
        case PieceType.pawn:
          break;
      }
    }

    if (isMate) {
      buffer.write('#');
    } else if (isCheck) {
      buffer.write('+');
    }

    return buffer.toString();
  }

  String buildSAN(Position position) {
    var pieceType = piece.type;
    var rank = from.rank;
    var file = from.file;
    var isPawnDiagonal = piece.type == PieceType.pawn &&
        (from.file - destination.file).abs() == 1 &&
        (from.rank - destination.rank).abs() == 1;

    var isCapture = position.pieceAt(destination) != null || isPawnDiagonal;

    if (isCastlingMove) {
      return destination.file == 6 ? 'O-O' : 'O-O-O';
    }

    final buffer = StringBuffer();

    if (piece.type != PieceType.pawn) {
      buffer.write(piece.type.pieceLetter);
    }

    if (isCapture) buffer.write('x');

    if (piece.type != PieceType.pawn) {
      var pieces = position.pieces
          .where((e) =>
              e.type == pieceType &&
              e.color == piece.color &&
              e.initialSquare != piece.initialSquare)
          .where((e) => position.validSquaresForPiece(e).contains(destination));

      var piecesOnFile = pieces.where((e) => e.square?.file == file);
      var piecesOnRank = pieces.where((e) => e.square?.rank == rank);

      if (piecesOnFile.isNotEmpty) {
        buffer.write(rank + 1);
      }

      if (piecesOnRank.isNotEmpty) {
        final fileChar = String.fromCharCode('a'.codeUnitAt(0) + from.file);
        buffer.write(fileChar);
      }

      if (piecesOnRank.isEmpty && piecesOnFile.isEmpty) {
        final fileChar = String.fromCharCode('a'.codeUnitAt(0) + from.file);
        buffer.write(fileChar);
      }
    }

    if (piece.type == PieceType.pawn && isCapture) {
      buffer.write(
        String.fromCharCode('a'.codeUnitAt(0) + from.file),
      );
    }

    buffer.write(destination.algebraic);

    if (promoteTo != null) {
      buffer.write('=');
      buffer.write(promoteTo!.pieceLetter);
    }

    if (isMate) {
      buffer.write('#');
    } else if (isCheck) {
      buffer.write('+');
    }

    return buffer.toString();
  }
}

extension PieceTypeExtensions on PieceType {
  String get pieceLetter {
    switch (this) {
      case PieceType.king:
        return 'K';
      case PieceType.queen:
        return 'Q';
      case PieceType.rook:
        return 'R';
      case PieceType.bishop:
        return 'B';
      case PieceType.knight:
        return 'N';
      case PieceType.pawn:
        return '';
    }
  }
}
