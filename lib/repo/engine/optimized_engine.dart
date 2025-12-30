import 'package:chess_app/repo/engine/chess_engine.dart';
import 'package:chess_app/util/move_validator_extension.dart';

import '../../models/models.dart';

class OptimizedEngine extends ChessEngine {
  final int depth;

  OptimizedEngine({this.depth = 4});

  // =========================
  // Material values
  // =========================
  final Map<PieceType, int> pieceBaseValue = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  // =========================
  // Piece-square tables
  // =========================
  final List<List<int>> pawnTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0],
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

  final List<List<int>> kingEndgameTable = [
    [-50, -30, -30, -30, -30, -30, -30, -50],
    [-30, -10, 0, 0, 0, 0, -10, -30],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, -10, 0, 0, 0, 0, -10, -30],
    [-50, -30, -30, -30, -30, -30, -30, -50],
  ];

  // =========================
  // Helpers
  // =========================
  bool isEndgame(Position pos) {
    int material = 0;
    for (final p in pos.pieces) {
      if (p.type != PieceType.king) {
        material += pieceBaseValue[p.type]!;
      }
    }
    return material < 2400;
  }

  bool isCastled(Position pos, PieceColor color) {
    final king = pos.pieces.firstWhere(
      (p) => p.type == PieceType.king && p.color == color,
    );
    final file = king.square!.file;
    return file == 2 || file == 6;
  }

  int pieceSquareValue(Piece piece, Position pos) {
    if (piece.type == PieceType.king && isEndgame(pos)) {
      final rank = piece.color == PieceColor.white ? piece.square!.rank : 7 - piece.square!.rank;
      return kingEndgameTable[rank][piece.square!.file];
    }

    final table = {
      PieceType.pawn: pawnTable,
      PieceType.knight: knightTable,
      PieceType.bishop: bishopTable,
      PieceType.rook: rookTable,
      PieceType.queen: queenTable,
      PieceType.king: kingTable,
    }[piece.type]!;

    final rank = piece.color == PieceColor.white ? piece.square!.rank : 7 - piece.square!.rank;

    return table[rank][piece.square!.file];
  }

  int captureScore(Move m) {
    if (m.capturedPiece == null) return 0;
    return pieceBaseValue[m.capturedPiece!.type]! - pieceBaseValue[m.piece.type]!;
  }

  // =========================
  // Evaluation
  // =========================
  @override
  int evaluate(Position pos) {
    int score = 0;

    for (final piece in pos.pieces) {
      final sign = piece.color == PieceColor.white ? 1 : -1;
      score += sign * pieceBaseValue[piece.type]!;
      score += sign * pieceSquareValue(piece, pos);
    }

    if (!isEndgame(pos)) {
      if (isCastled(pos, PieceColor.white)) score += 40;
      if (isCastled(pos, PieceColor.black)) score -= 40;
    }

    return score;
  }

  // =========================
  // Search
  // =========================
  @override
  Move? bestMove(Position position) {
    return _alphabeta(
      position,
      depth,
      -10000000,
      10000000,
      position.sideToMove == PieceColor.white,
    ).bestMove;
  }

  PositionSearchResult _alphabeta(
    Position pos,
    int depth,
    int alpha,
    int beta,
    bool maximizing,
  ) {
    if (depth == 0) {
      return PositionSearchResult(
        _quiescence(pos, alpha, beta, maximizing),
        null,
      );
    }

    Move? bestMove;
    final moves = _orderMoves(pos.allValidMoves());

    for (final move in moves) {
      final next = pos.update(move);
      final result = _alphabeta(next, depth - 1, alpha, beta, !maximizing);

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

  int _quiescence(
    Position pos,
    int alpha,
    int beta,
    bool maximizing,
  ) {
    final standPat = evaluate(pos);

    if (maximizing) {
      if (standPat >= beta) return beta;
      if (standPat > alpha) alpha = standPat;
    } else {
      if (standPat <= alpha) return alpha;
      if (standPat < beta) beta = standPat;
    }

    final captures = pos.allValidMoves().where((m) => m.capturedPiece != null).toList()
      ..sort((a, b) => captureScore(b) - captureScore(a));

    for (final move in captures) {
      final next = pos.update(move);
      final score = _quiescence(next, alpha, beta, !maximizing);

      if (maximizing) {
        if (score >= beta) return beta;
        if (score > alpha) alpha = score;
      } else {
        if (score <= alpha) return alpha;
        if (score < beta) beta = score;
      }
    }

    return maximizing ? alpha : beta;
  }

  // -------------------------
  // Move ordering: captures first, then promotions
  // -------------------------
  List<Move> _orderMoves(List<Move> moves) {
    moves.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      // Captures get higher priority
      if (a.capturedPiece != null) scoreA += 1000;
      if (b.capturedPiece != null) scoreB += 1000;

      // Promotions get higher priority
      if (a.promoteTo != null) scoreA += 500;
      if (b.promoteTo != null) scoreB += 500;

      return scoreB - scoreA;
    });
    return moves;
  }
}
