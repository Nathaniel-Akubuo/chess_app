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

      final san = move.buildSAN(positionBefore);

      buffer.write('$san ');
    }

    return buffer.toString().trim();
  }
}

extension MoveExtension on Move {
  String buildSAN(Position position) {
    var rank = from.rank;
    var file = from.file;
    var isPawnDiagonal = piece.type == PieceType.pawn &&
        (from.file - destination.file).abs() == 1 &&
        (from.rank - destination.rank).abs() == 1;

    var isCapture = capturedPiece != null || isPawnDiagonal;

    if (isCastlingMove) {
      return destination.file == 6 ? 'O-O' : 'O-O-O';
    }

    final buffer = StringBuffer();

    if (piece.type != PieceType.pawn) {
      buffer.write(piece.type.pieceLetter);
      var pieces = position.pieces.where((e) =>
          e.type == piece.type && e.color == piece.color && e.initialSquare != piece.initialSquare);

      var canMakeMove = pieces.any((e) => position.validSquaresForPiece(e).contains(destination));

      var piecesOnFile = pieces.where((e) => e.square?.file == file);
      var piecesOnRank = pieces.where((e) => e.square?.rank == rank);

      if (canMakeMove) {
        if (piecesOnFile.isNotEmpty) {
          buffer.write(rank + 1);
        }

        if (piecesOnRank.isNotEmpty) {
          buffer.write(from.fileChar);
        }

        if (piecesOnRank.isEmpty && piecesOnFile.isEmpty) {
          buffer.write(from.fileChar);
        }
      }
    } else if (piece.type == PieceType.pawn && isCapture) {
      buffer.write(from.fileChar);
    }

    if (isCapture) buffer.write('x');

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
