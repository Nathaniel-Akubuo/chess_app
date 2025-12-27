import 'package:chess_app/util/move_validator_extension.dart';

import '../models/models.dart';

class CustomEngine {
  final int depth;

  CustomEngine({this.depth = 4});

  final Map<PieceType, int> pieceBaseValue = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  final List<List<int>> pawnTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ];

  final List<List<int>> knightTable = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50],
  ];

  final List<List<int>> bishopTable = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20],
  ];

  final List<List<int>> rookTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [0, 0, 0, 5, 5, 0, 0, 0],
  ];

  final List<List<int>> queenTable = [
    [-20, -10, -10, -5, -5, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 5, 5, 5, 0, -10],
    [-5, 0, 5, 5, 5, 5, 0, -5],
    [0, 0, 5, 5, 5, 5, 0, -5],
    [-10, 5, 5, 5, 5, 5, 0, -10],
    [-10, 0, 5, 0, 0, 0, 0, -10],
    [-20, -10, -10, -5, -5, -10, -10, -20],
  ];

  final List<List<int>> kingTable = [
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [20, 30, 10, 0, 0, 10, 30, 20],
  ];

  int pieceSquareValue(Piece piece) {
    final table = {
      PieceType.pawn: pawnTable,
      PieceType.knight: knightTable,
      PieceType.bishop: bishopTable,
      PieceType.rook: rookTable,
      PieceType.queen: queenTable,
      PieceType.king: kingTable,
    }[piece.type]!;

    final rank = piece.color == PieceColor.white ? piece.square!.rank : 7 - piece.square!.rank;
    final file = piece.square!.file;

    return table[rank][file];
  }

  int kingSafety(Position pos, PieceColor color) {
    final king = pos.pieces.firstWhere((p) => p.type == PieceType.king && p.color == color);
    int score = 0;

    for (int df = -1; df <= 1; df++) {
      final file = king.square!.file + df;
      if (file < 0 || file > 7) continue;
      for (int r = 0; r < 8; r++) {
        final piece = pos.pieceAt(Square.fromFileRank(file, r));
        if (piece != null && piece.color != color && piece.type != PieceType.king) {
          score -= 5;
        }
      }
    }

    return score;
  }

  int mobility(Position pos, PieceColor color) {
    int moves = 0;
    for (final piece in pos.pieces.where((p) => p.color == color)) {
      moves += pos.validSquaresForPiece(piece).length;
    }
    return moves;
  }

  bool isPassedPawn(Position pos, Piece pawn) {
    if (pawn.type != PieceType.pawn) return false;
    final dir = pawn.color == PieceColor.white ? 1 : -1;

    for (int f = pawn.square!.file - 1; f <= pawn.square!.file + 1; f++) {
      if (f < 0 || f > 7) continue;
      for (int r = pawn.square!.rank + dir; r >= 0 && r < 8; r += dir) {
        final p = pos.pieceAt(Square.fromFileRank(f, r));
        if (p != null && p.color != pawn.color && p.type == PieceType.pawn) return false;
      }
    }

    return true;
  }

  int pieceValue(Piece piece) {
    return pieceBaseValue[piece.type]!;
  }

  int eval(Position pos) {
    int score = 0;

    for (final piece in pos.pieces) {
      score += piece.color == PieceColor.white ? pieceValue(piece) : -pieceValue(piece);
      score += piece.color == PieceColor.white ? pieceSquareValue(piece) : -pieceSquareValue(piece);
    }

    score += kingSafety(pos, PieceColor.white) - kingSafety(pos, PieceColor.black);
    score += mobility(pos, PieceColor.white) - mobility(pos, PieceColor.black);

    for (final pawn in pos.pieces.where((p) => p.type == PieceType.pawn)) {
      if (isPassedPawn(pos, pawn)) {
        score += pawn.color == PieceColor.white ? 20 : -20;
      }
    }

    return score;
  }

  Move findBestMove(Position position) {
    var result = _alphabeta(
      position,
      depth,
      -10000000,
      10000000,
      true,
    );
    return result.bestMove!;
  }

  PositionSearchResult _alphabeta(
    Position position,
    int depth,
    int alpha,
    int beta,
    bool maximizing,
  ) {
    if (depth == 0) {
      return PositionSearchResult(eval(position), null);
    }

    Move? bestMove;

    for (final move in position.allValidMoves()) {
      final newPos = position.update(move);
      final result = _alphabeta(
        newPos,
        depth - 1,
        alpha,
        beta,
        !maximizing,
      );

      if (maximizing) {
        if (result.score > alpha) {
          alpha = result.score;
          bestMove = move;
        }
        if (alpha >= beta) break;
      } else {
        if (result.score < beta) {
          beta = result.score;
          bestMove = move;
        }
        if (beta <= alpha) break;
      }
    }

    return PositionSearchResult(maximizing ? alpha : beta, bestMove);
  }
}
