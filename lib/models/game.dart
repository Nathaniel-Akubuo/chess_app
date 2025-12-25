import 'package:chess_app/util/move_validator_extension.dart';

import 'models.dart';

class Game {
  final String id;
  final List<Move> moves;
  final List<Position> positions;

  Game({
    required this.id,
    required this.moves,
    required this.positions,
  });

  Position get currentPosition => positions.last;

  factory Game.newGame() {
    return Game(
      id: '',
      moves: [],
      positions: [Position.initial()],
    );
  }

  Game makeMove(Move move) {
    var newPosition = currentPosition.update(move);

    moves.add(
      move.copyWith(
        isCheck: newPosition.isInCheck(newPosition.sideToMove),
        isMate: newPosition.isCheckmate(newPosition.sideToMove),
      ),
    );
    positions.add(newPosition.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));

    return copyWith(positions: positions, moves: moves);
  }

  Game copyWith({
    String? id,
    List<Move>? moves,
    List<Position>? positions,
  }) {
    return Game(
      id: id ?? this.id,
      moves: moves ?? this.moves,
      positions: positions ?? this.positions,
    );
  }
}
