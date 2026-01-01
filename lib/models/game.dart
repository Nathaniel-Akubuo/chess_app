import 'package:chess_app/util/extensions.dart';
import 'package:chess_app/util/move_validator_extension.dart';

import 'models.dart';

enum GameType { online, offline }

class Game {
  final String id;
  final List<Move> moves;
  final List<Position> positions;
  final GameType type;

  Game({
    required this.id,
    required this.moves,
    required this.positions,
    required this.type,
  });

  Position get currentPosition => positions.last;

  factory Game.newGame() {
    return Game(
      id: '',
      moves: [],
      positions: [Position.initial()],
      type: GameType.offline,
    );
  }

  Game makeMove(Move move) {
    var newPosition = currentPosition.update(move);
    var updatedMove = move.copyWith(id: moves.length.toString());

    moves.add(updatedMove);
    positions.add(newPosition.copyWith(id: move.id, move: updatedMove));

    return copyWith(positions: positions, moves: moves);
  }

  Game copyWith({
    String? id,
    List<Move>? moves,
    List<Position>? positions,
    GameType? type,
  }) {
    return Game(
      id: id ?? this.id,
      moves: moves ?? this.moves,
      positions: positions ?? this.positions,
      type: type ?? this.type,
    );
  }

  factory Game.fromPgn(String pgn) {
    var cleanedText = _sanitizePgnMoves(pgn);

    var tokens = cleanedText.split(RegExp(r'\s+'));

    Game game = Game.newGame();

    for (final token in tokens) {
      if (_isGameTermination(token)) break;
      if (token.isEmpty) continue;

      final position = game.currentPosition;

      final move = _resolveSanMove(
        san: token,
        position: position,
      );

      game = game.makeMove(move);
    }

    return game;
  }

  static String _sanitizePgnMoves(String pgn) {
    var text = pgn;

    text = text.split('\n').where((l) => !l.trim().startsWith('[')).join(' ');

    text = text.replaceAll(RegExp(r'\{[^}]*\}'), ' ');

    while (RegExp(r'\([^()]*\)').hasMatch(text)) {
      text = text.replaceAll(RegExp(r'\([^()]*\)'), ' ');
    }

    text = text.replaceAll(RegExp(r'\$\d+'), ' ');

    text = text.replaceAll(RegExp(r'\d+\.(\.\.)?'), ' ');

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  static bool _isGameTermination(String token) {
    return token == '1-0' || token == '0-1' || token == '1/2-1/2' || token == '*';
  }

  static Move _resolveSanMove({
    required String san,
    required Position position,
  }) {
    final parsed = ParsedSan.fromString(san);
    Move? move;
    if (parsed.isCastleKingSide) {
      move = position
          .allValidMoves()
          .where((e) => e.isCastlingMove)
          .nullableFirstWhere((e) => e.destination.file == 6);
    } else if (parsed.isCastleQueenSide) {
      move = position
          .allValidMoves()
          .where((e) => e.isCastlingMove)
          .nullableFirstWhere((e) => e.destination.file == 2);
    } else {
      List<Piece> possible = [];
      var pieces = position.pieces
          .where((e) => e.color == position.sideToMove)
          .where((e) => e.type == parsed.pieceType);

      possible = pieces
          .where((e) => position.validSquaresForPiece(e).contains(parsed.destination))
          .toList();

      if (parsed.fromFile != null) {
        possible.retainWhere((e) => e.square?.file == parsed.fromFile);
      }

      if (parsed.fromRank != null) {
        possible.retainWhere((e) => e.square?.rank == parsed.fromRank);
      }

      if (possible.length > 1) {
        throw StateError('Ambiguous SAN move: $san');
      }
      if (possible.isEmpty) {
        throw StateError('Could not parse SAN move: $san');
      }

      var piece = possible.first;
      move = Move(
        from: piece.square!,
        destination: parsed.destination,
        piece: piece,
        promoteTo: parsed.promotion,
        capturedPiece: position.pieceAt(parsed.destination),
        isCheck: san.contains('+'),
        isMate: san.contains('#'),
        san: san,
      );
    }

    if (move == null) {
      throw StateError('Could not parse SAN move: $san');
    }
    return move;
  }
}
