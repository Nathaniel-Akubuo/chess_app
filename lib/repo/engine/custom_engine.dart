import 'package:chess_app/repo/engine/chess_engine.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import '../../models/models.dart';

class CustomEngine extends ChessEngine {
  final int depth;

  CustomEngine({this.depth = 4});

  // Base material values for pieces
  final Map<PieceType, int> pieceBaseValue = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  // Piece-square tables for positional evaluation
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

  int kingSafety(Position pos, PieceColor color, {bool endgame = false}) {
    final king = pos.pieces.firstWhere((p) => p.type == PieceType.king && p.color == color);
    int score = 0;

    // Track if the king has castled
    bool castled = (king.color == PieceColor.white &&
            (king.square!.file == 6 || king.square!.file == 2) &&
            king.square!.rank == 0) ||
        (king.color == PieceColor.black &&
            (king.square!.file == 6 || king.square!.file == 2) &&
            king.square!.rank == 7);

    if (endgame == false) {
      // Penalty for enemy pieces near king
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

      // Bonus for castled king
      if (castled) {
        score += 20;
      } else if ((king.square!.file != 4) ||
          (king.square!.rank != (color == PieceColor.white ? 0 : 7))) {
        // Penalize king moving before castling
        score -= 10;
      }
    } else {
      // Endgame: reward centralization
      score += (3 - (king.square!.file - 3).abs()) * 10;
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

  int pieceValue(Piece piece) {
    return pieceBaseValue[piece.type]!;
  }

  @override
  int evaluate(Position pos) {
    int score = 0;
    int totalMaterial = 0;

    for (final piece in pos.pieces) {
      final value = pieceValue(piece);
      totalMaterial += value;
      score += piece.color == PieceColor.white ? value : -value;
      score += piece.color == PieceColor.white ? pieceSquareValue(piece) : -pieceSquareValue(piece);
    }

    bool endgame = totalMaterial < 1400;

    score += kingSafety(pos, PieceColor.white, endgame: endgame) -
        kingSafety(pos, PieceColor.black, endgame: endgame);

    score += mobility(pos, PieceColor.white) - mobility(pos, PieceColor.black);

    for (final pawn in pos.pieces.where((p) => p.type == PieceType.pawn)) {
      if (isPassedPawn(pos, pawn)) {
        score += pawn.color == PieceColor.white ? (endgame ? 50 : 20) : (endgame ? -50 : -20);
      }
    }

    return score;
  }

  @override
  Move? bestMove(Position position) {
    final result =
        _alphabeta(position, depth, -10000000, 10000000, position.sideToMove == PieceColor.white);
    if (result.bestMove != null) {
      return result.bestMove;
    } else {
      final moves = position.allValidMoves();
      return moves.isNotEmpty ? moves.first : null;
    }
  }

  PositionSearchResult _alphabeta(
      Position position, int depth, int alpha, int beta, bool maximizing) {
    if (depth == 0) {
      return _quiescence(position, alpha, beta, maximizing);
    }

    Move? bestMove;

    for (final move in position.allValidMoves()) {
      final newPos = position.update(move);
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

  PositionSearchResult _quiescence(Position position, int alpha, int beta, bool maximizing) {
    int standPat = evaluate(position);

    if (maximizing) {
      if (standPat >= beta) return PositionSearchResult(beta, null);
      if (standPat > alpha) alpha = standPat;
    } else {
      if (standPat <= alpha) return PositionSearchResult(alpha, null);
      if (standPat < beta) beta = standPat;
    }

    for (final move in position.allValidMoves().where((m) => m.capturedPiece != null)) {
      final newPos = position.update(move);
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
}
