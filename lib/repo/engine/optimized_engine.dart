import 'dart:math';
import 'package:chess_app/repo/engine/chess_engine.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import '../../models/models.dart';

class TTEntry {
  final int depth;
  final int score;
  final Move? bestMove;
  final int flag; // 0 = exact, -1 = alpha, 1 = beta

  TTEntry(this.depth, this.score, this.bestMove, this.flag);
}

class OptimizedEngine extends ChessEngine {
  final int depth;
  final Map<int, TTEntry> transpositionTable = {};
  final List<List<int>> zobristTable =
      List.generate(64, (_) => List.generate(12, (_) => Random().nextInt(1 << 32)));
  int sideToMoveHash = Random().nextInt(1 << 32);

  OptimizedEngine({this.depth = 4});

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

    // simple pawn shield evaluation
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

    // bonus if king is castled (simple heuristic)
    if ((color == PieceColor.white &&
            king.square!.rank == 0 &&
            (king.square!.file == 2 || king.square!.file == 6)) ||
        (color == PieceColor.black &&
            king.square!.rank == 7 &&
            (king.square!.file == 2 || king.square!.file == 6))) {
      score += 15;
    }

    return score;
  }

  int mobility(Position pos, PieceColor color) {
    int moves = 0;
    for (final piece in pos.pieces.where((p) => p.color == color && p.type != PieceType.king)) {
      moves += pos.validSquaresForPiece(piece).length;
    }
    return moves * 2;
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

  int pieceValue(Piece piece) => pieceBaseValue[piece.type]!;

  @override
  int evaluate(Position pos) {
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

  int zobristHash(Position pos) {
    int hash = 0;
    for (final piece in pos.pieces) {
      final pieceIndex = piece.type.index + (piece.color == PieceColor.white ? 0 : 6);
      final squareIndex = piece.square!.rank * 8 + piece.square!.file;
      hash ^= zobristTable[squareIndex][pieceIndex];
    }
    if (pos.sideToMove == PieceColor.white) hash ^= sideToMoveHash;
    return hash;
  }

  @override
  Move? bestMove(Position position) {
    Move? best;
    for (int depth = 1; depth <= this.depth; depth++) {
      final result =
          _alphabeta(position, depth, -10000000, 10000000, position.sideToMove == PieceColor.white);
      best = result.bestMove ?? best;
    }
    return best;
  }

  PositionSearchResult _alphabeta(
      Position position, int depth, int alpha, int beta, bool maximizing) {
    final hash = zobristHash(position);
    final tt = transpositionTable[hash];
    if (tt != null && tt.depth >= depth) {
      if (tt.flag == 0) return PositionSearchResult(tt.score, tt.bestMove);
      if (tt.flag == -1 && tt.score > alpha) alpha = tt.score;
      if (tt.flag == 1 && tt.score < beta) beta = tt.score;
      if (alpha >= beta) return PositionSearchResult(tt.score, tt.bestMove);
    }

    if (depth == 0) {
      return PositionSearchResult(_quiescence(position, alpha, beta, maximizing), null);
    }

    Move? bestMove;
    final moves = position.allValidMoves();

    // simple move ordering: captures first, then killer move from table
    moves.sort((a, b) {
      if (a.isCapture && !b.isCapture) return -1;
      if (!a.isCapture && b.isCapture) return 1;
      return 0;
    });

    for (final move in moves) {
      final newPos = position.update(move);
      final result = _alphabeta(newPos, depth - 1, alpha, beta, !maximizing);
      final score = result.score;

      if (maximizing) {
        if (score > alpha) {
          alpha = score;
          bestMove = move;
        }
        if (alpha >= beta) break;
      } else {
        if (score < beta) {
          beta = score;
          bestMove = move;
        }
        if (beta <= alpha) break;
      }
    }

    int flag = 0;
    int value = maximizing ? alpha : beta;
    if (value <= alpha) {
      flag = 1;
    } else if (value >= beta) {
      flag = -1;
    }

    transpositionTable[hash] = TTEntry(depth, value, bestMove, flag);
    return PositionSearchResult(maximizing ? alpha : beta, bestMove);
  }

  int _quiescence(Position pos, int alpha, int beta, bool maximizing) {
    int standPat = evaluate(pos);
    if (maximizing) {
      if (standPat >= beta) return beta;
      if (standPat > alpha) alpha = standPat;
    } else {
      if (standPat <= alpha) return alpha;
      if (standPat < beta) beta = standPat;
    }

    for (final move in pos.allValidMoves().where((m) => m.isCapture)) {
      final newPos = pos.update(move);
      int score = _quiescence(newPos, alpha, beta, !maximizing);
      if (maximizing) {
        if (score > alpha) alpha = score;
        if (alpha >= beta) return beta;
      } else {
        if (score < beta) beta = score;
        if (beta <= alpha) return alpha;
      }
    }

    return maximizing ? alpha : beta;
  }
}
