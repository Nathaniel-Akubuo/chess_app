import 'package:chess_app/repo/engine/custom_engine.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import '../models/models.dart';

class GameService with ListenableServiceMixin {
  Game? _currentGame;

  Game? get currentGame => _currentGame;

  void startGame() {
    _currentGame = Game.newGame();
  }

  Future<Move?> getEngineMove(Position? position) async {
    if (position == null) return null;
    return await compute(_engineWorker, {
      'position': position,
      'depth': 4,
    });
  }

  Move? _engineWorker(Map<String, dynamic> args) {
    final engine = CustomEngine(depth: args['depth']);
    return engine.bestMove(args['position']);
  }

  Future<void> makeMove(
    Piece piece,
    Square newSquare,
    PieceType? promotion,
    Duration duration,
  ) async {
    if (currentGame != null) {
      var move = _currentGame!.currentPosition.buildMove(piece, newSquare, promotion);

      _currentGame = _currentGame?.makeMove(move);
      notifyListeners();
    }
  }
}
