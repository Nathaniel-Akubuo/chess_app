import 'dart:math';

import 'package:chess_app/repo/engine/chess_engine.dart';
import 'package:chess_app/util/move_validator_extension.dart';

import '../../models/models.dart';

class CustomEngine2 extends ChessEngine {
  final int depth;
  final Map<int, _TTEntry> _tt = {};
  final Random _rng = Random(1337);

  late final Map<int, int> _zobristTable;
  late final int _zobristSide;

  CustomEngine2({this.depth = 5}) {
    _initZobrist();
  }

  // ===========================================================================
  // PUBLIC API
  // ===========================================================================

  @override
  Move? bestMove(Position position) {
    Move? bestMove;

    for (int depth = 1; depth <= this.depth; depth++) {
      _alphaBeta(
        position: position,
        depth: depth,
        alpha: -_inf,
        beta: _inf,
        maximizing: position.sideToMove == PieceColor.white,
        onBestMove: (m) => bestMove = m,
      );
    }
    if (bestMove == null) {
      final moves = position.allValidMoves();
      if (moves.isNotEmpty) {
        return moves.first;
      } else {
        return null;
      }
    }

    return bestMove;
  }

  // ===========================================================================
  // ALPHA BETA + QUIESCENCE
  // ===========================================================================

  int _alphaBeta({
    required Position position,
    required int depth,
    required int alpha,
    required int beta,
    required bool maximizing,
    void Function(Move)? onBestMove,
  }) {
    final hash = _hash(position);
    final tt = _tt[hash];

    if (tt != null && tt.depth >= depth) {
      if (tt.flag == _TTFlag.exact) return tt.score;
      if (tt.flag == _TTFlag.lower && tt.score > alpha) alpha = tt.score;
      if (tt.flag == _TTFlag.upper && tt.score < beta) beta = tt.score;
      if (alpha >= beta) return tt.score;
    }

    if (depth == 0) {
      return _quiescence(position, alpha, beta);
    }

    final moves = _orderMoves(position.allValidMoves());
    if (moves.isEmpty) {
      if (position.isInCheck(position.sideToMove)) {
        return maximizing ? -_mateScore : _mateScore;
      }
      return 0;
    }

    int bestScore = maximizing ? -_inf : _inf;
    Move? bestLocalMove;

    for (final move in moves) {
      final next = position.update(move);
      final score = _alphaBeta(
        position: next,
        depth: depth - 1,
        alpha: alpha,
        beta: beta,
        maximizing: !maximizing,
      );

      if (maximizing) {
        if (score > bestScore) {
          bestScore = score;
          bestLocalMove = move;
        }
        alpha = max(alpha, score);
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestLocalMove = move;
        }
        beta = min(beta, score);
      }

      if (beta <= alpha) break;
    }

    _tt[hash] = _TTEntry(
      depth: depth,
      score: bestScore,
      flag: bestScore <= alpha
          ? _TTFlag.upper
          : bestScore >= beta
              ? _TTFlag.lower
              : _TTFlag.exact,
    );

    if (bestLocalMove != null) {
      onBestMove?.call(bestLocalMove);
    }

    return bestScore;
  }

  int _quiescence(Position position, int alpha, int beta) {
    int standPat = evaluate(position);

    if (standPat >= beta) return beta;
    if (standPat > alpha) alpha = standPat;

    final captures = position.allValidMoves().where((m) => m.capturedPiece != null).toList();

    for (final move in captures) {
      final next = position.update(move);
      final score = -_quiescence(next, -beta, -alpha);

      if (score >= beta) return beta;
      if (score > alpha) alpha = score;
    }

    return alpha;
  }

  // ===========================================================================
  // MOVE ORDERING
  // ===========================================================================

  List<Move> _orderMoves(List<Move> moves) {
    moves.sort((a, b) {
      int scoreA = _moveScore(a);
      int scoreB = _moveScore(b);
      return scoreB.compareTo(scoreA);
    });
    return moves;
  }

  int _moveScore(Move m) {
    int score = 0;
    if (m.capturedPiece != null) {
      score += 10 * _pieceValue(m.capturedPiece!.type) - _pieceValue(m.piece.type);
    }
    if (m.promoteTo != null) score += 800;
    if (m.isCheck) score += 50;
    return score;
  }

  // ===========================================================================
  // EVALUATION (MATERIAL + PST)
  // ===========================================================================

  @override
  int evaluate(Position position) {
    int score = 0;

    for (final p in position.pieces) {
      final value = _pieceValue(p.type) + _pst(p);
      score += p.color == PieceColor.white ? value : -value;
    }

    return score;
  }

  int _pieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return 100;
      case PieceType.knight:
        return 320;
      case PieceType.bishop:
        return 330;
      case PieceType.rook:
        return 500;
      case PieceType.queen:
        return 900;
      case PieceType.king:
        return 20000;
    }
  }

  int _pst(Piece p) {
    final table = _pieceSquareTable[p.type]!;
    final index = p.color == PieceColor.white ? p.square!.index : 63 - p.square!.index;
    return table[index];
  }

  // ===========================================================================
  // ZOBRIST
  // ===========================================================================

  void _initZobrist() {
    _zobristTable = {};
    for (int i = 0; i < 12 * 64; i++) {
      _zobristTable[i] = _rng.nextInt(1 << 30);
    }
    _zobristSide = _rng.nextInt(1 << 30);
  }

  int _hash(Position pos) {
    int h = 0;
    for (final p in pos.pieces) {
      final pieceIndex = p.type.index + (p.color == PieceColor.white ? 0 : 6);
      h ^= _zobristTable[pieceIndex * 64 + p.square!.index]!;
    }
    if (pos.sideToMove == PieceColor.white) h ^= _zobristSide;
    return h;
  }

  static const int _inf = 1000000;
  static const int _mateScore = 900000;
}

// ===========================================================================
// TRANSPOSITION TABLE
// ===========================================================================

class _TTEntry {
  final int depth;
  final int score;
  final _TTFlag flag;

  _TTEntry({required this.depth, required this.score, required this.flag});
}

enum _TTFlag { exact, lower, upper }

// ===========================================================================
// PIECE-SQUARE TABLES (MIDGAME)
// ===========================================================================

final Map<PieceType, List<int>> _pieceSquareTable = {
  PieceType.pawn: _pawnPst,
  PieceType.knight: _knightPst,
  PieceType.bishop: _bishopPst,
  PieceType.rook: _rookPst,
  PieceType.queen: _queenPst,
  PieceType.king: _kingPst,
};

// (64 values each)
const _pawnPst = [
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  5,
  10,
  10,
  -20,
  -20,
  10,
  10,
  5,
  5,
  -5,
  -10,
  0,
  0,
  -10,
  -5,
  5,
  0,
  0,
  0,
  20,
  20,
  0,
  0,
  0,
  5,
  5,
  10,
  25,
  25,
  10,
  5,
  5,
  10,
  10,
  20,
  30,
  30,
  20,
  10,
  10,
  50,
  50,
  50,
  50,
  50,
  50,
  50,
  50,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
];

const _knightPst = [
  -50,
  -40,
  -30,
  -30,
  -30,
  -30,
  -40,
  -50,
  -40,
  -20,
  0,
  0,
  0,
  0,
  -20,
  -40,
  -30,
  0,
  10,
  15,
  15,
  10,
  0,
  -30,
  -30,
  5,
  15,
  20,
  20,
  15,
  5,
  -30,
  -30,
  0,
  15,
  20,
  20,
  15,
  0,
  -30,
  -30,
  5,
  10,
  15,
  15,
  10,
  5,
  -30,
  -40,
  -20,
  0,
  5,
  5,
  0,
  -20,
  -40,
  -50,
  -40,
  -30,
  -30,
  -30,
  -30,
  -40,
  -50,
];

final _bishopPst = List.filled(64, 0);
final _rookPst = List.filled(64, 0);
final _queenPst = List.filled(64, 0);
final _kingPst = List.filled(64, 0);
