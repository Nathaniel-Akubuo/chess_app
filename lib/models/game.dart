import 'models.dart';

class Game {
  final List<Move> moves;
  final List<Position> positions;

  Game({
    required this.moves,
    required this.positions,
  });

  Position get currentPosition => positions.last;

  factory Game.newGame() {
    return Game(
      moves: [],
      positions: [Position.initial()],
    );
  }
}
