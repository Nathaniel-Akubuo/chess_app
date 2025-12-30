import 'package:chess_app/repo/engine/chess_engine.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import '../../models/models.dart';

class OptimizedEngine extends ChessEngine {
  final int depth;

  OptimizedEngine({this.depth = 4});

  // Basic piece values
  final Map<PieceType, int> pieceBaseValue = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  // Simple piece-square tables (can expand or adjust later)
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

  // Simplified example for other pieces
  final Map<PieceType, List<List<int>>> pieceSquareTables = {};

  int pieceValue(Piece piece) => pieceBaseValue[piece.type]!;

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

  // Evaluation function
  @override
  int evaluate(Position pos) {
    int score = 0;

    // Material + piece-square value
    for (final piece in pos.pieces) {
      int value = pieceValue(piece) + pieceSquareValue(piece, pos);

      score += piece.color == PieceColor.white ? value : -value;
    }

    // Mobility bonus (moves for all non-king pieces)
    int whiteMobility = pos.pieces
        .where((p) => p.color == PieceColor.white && p.type != PieceType.king)
        .map((p) => pos.validSquaresForPiece(p).length)
        .fold(0, (a, b) => a + b);

    int blackMobility = pos.pieces
        .where((p) => p.color == PieceColor.black && p.type != PieceType.king)
        .map((p) => pos.validSquaresForPiece(p).length)
        .fold(0, (a, b) => a + b);

    score += (whiteMobility - blackMobility) * 2;

    // King safety, simple: penalize if attacked
    score += kingSafety(pos, PieceColor.white) - kingSafety(pos, PieceColor.black);

    if (!isEndgame(pos)) {
      if (isCastled(pos, PieceColor.white)) score += 40;
      if (isCastled(pos, PieceColor.black)) score -= 40;
    }

    return score;
  }

  bool isEndgame(Position pos) {
    int material = 0;

    for (final p in pos.pieces) {
      if (p.type != PieceType.king) {
        material += pieceBaseValue[p.type]!;
      }
    }

    return material < 2400; // roughly rook + minor + pawns
  }

  bool isCastled(Position pos, PieceColor color) {
    final king = pos.pieces.firstWhere(
      (p) => p.type == PieceType.king && p.color == color,
    );

    final file = king.square!.file;
    return file == 2 || file == 6; // c-file or g-file
  }

  int kingSafety(Position pos, PieceColor color) {
    final king = pos.pieces.firstWhere((p) => p.type == PieceType.king && p.color == color);
    int score = 0;
    for (int df = -1; df <= 1; df++) {
      final file = king.square!.file + df;
      if (file < 0 || file > 7) continue;
      for (int r = 0; r < 8; r++) {
        final piece = pos.pieceAt(Square.fromFileRank(file, r));
        if (piece != null && piece.color != color && piece.type != PieceType.king) score -= 5;
      }
    }
    return score;
  }

  // -------------------------
  // Best move entry point
  // -------------------------
  @override
  Move? bestMove(Position pos) {
    Move? best;
    int alpha = -10000000;
    int beta = 10000000;

    // Iterative deepening
    for (int d = 1; d <= depth; d++) {
      final result = _alphabeta(pos, d, alpha, beta, pos.sideToMove == PieceColor.white);
      if (result.bestMove != null) best = result.bestMove;
    }

    return best;
  }

  // -------------------------
  // Alpha-beta search
  // -------------------------
  PositionSearchResult _alphabeta(Position pos, int depth, int alpha, int beta, bool maximizing) {
    if (depth == 0) {
      return _quiescence(pos, alpha, beta, maximizing);
    }

    Move? bestMove;
    final moves = _orderMoves(pos.allValidMoves());

    for (final move in moves) {
      final newPos = pos.update(move);
      final result = _alphabeta(newPos, depth - 1, alpha, beta, !maximizing);

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

  // -------------------------
  // Simple quiescence search
  // -------------------------
  PositionSearchResult _quiescence(Position pos, int alpha, int beta, bool maximizing) {
    int standPat = evaluate(pos);

    if (maximizing) {
      if (standPat >= beta) return PositionSearchResult(beta, null);
      if (alpha < standPat) alpha = standPat;
    } else {
      if (standPat <= alpha) return PositionSearchResult(alpha, null);
      if (beta > standPat) beta = standPat;
    }

    // Only consider captures to extend search
    for (final move in pos.allValidMoves().where((m) => m.capturedPiece != null)) {
      final newPos = pos.update(move);
      final result = _quiescence(newPos, alpha, beta, !maximizing);

      if (maximizing) {
        if (result.score > alpha) alpha = result.score;
        if (alpha >= beta) break;
      } else {
        if (result.score < beta) beta = result.score;
        if (beta <= alpha) break;
      }
    }

    return PositionSearchResult(maximizing ? alpha : beta, null);
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
