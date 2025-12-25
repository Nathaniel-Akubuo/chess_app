import '../models/models.dart';

extension GameExtensions on Game {
  List<List<Move>> get movePairs {
    final value = <List<Move>>[];

    for (var i = 0; i < moves.length; i += 2) {
      value.add(moves.sublist(
        i,
        (i + 2 > moves.length) ? moves.length : i + 2,
      ));
    }

    return value;
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

    return buffer.toString();
  }
}
