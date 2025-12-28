import 'package:chess_app/app/app.locator.dart';
import 'package:chess_app/models/models.dart';
import 'package:chess_app/services/game_service.dart';

import 'package:chess_app/util/global_functions.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import 'package:chess_app/util/ui_extensions.dart';

import 'package:stacked/stacked.dart';

class HomeViewModel extends IndexTrackingViewModel {
  final _gameService = locator<GameService>();

  HomeViewModel() {
    _gameService.startGame();
  }

  Square? selectedSquare;

  Game? get currentGame => _gameService.currentGame;

  Move? currentMove;
  Position? previewPosition;

  Position? get position => currentGame?.currentPosition;

  Piece? get highlightedPiece => selectedSquare == null ? null : position?.pieceAt(selectedSquare!);

  bool selectSquare(Square square, PieceType? promotion) {
    if (previewPosition != null && previewPosition?.id != position?.id) return false;
    var isHighlighted = highlightedPiece != null;

    if (isHighlighted) {
      var isValidMoveForPiece = validMovesForSelectedPiece.contains(square);
      if (isValidMoveForPiece) {
        _updatePositon(highlightedPiece!, square, promotion);
        _respond();
        _setSelectedSquare(null);
        return true;
      } else {
        _setSelectedSquare(null);
        return false;
      }
    } else {
      _setSelectedSquare(square);
      return false;
    }
  }

  void _setSelectedSquare(Square? square) {
    selectedSquare = square;
    notifyListeners();
  }

  List<Square> get validMovesForSelectedPiece =>
      highlightedPiece == null ? [] : (position?.validSquaresForPiece(highlightedPiece!) ?? []);

  void _updatePositon(Piece piece, Square newSquare, PieceType? promotion) {
    if (piece.square == null) return;
    _gameService.makeMove(piece, newSquare, promotion, Duration.zero);
    previewPosition = null;

    setIndex(currentIndex + 1);
  }

  Future<void> _respond() async {
    if (position?.isCheckMateForSideToMove == true) {
      logfn(currentGame?.pgn);
      logfn('Checkmate');
      return;
    }

    var start = DateTime.now();
    var response = await _gameService.getEngineMove(position);
    var end = DateTime.now();

    logfn(end.difference(start).inMilliseconds);

    if (response != null) {
      _updatePositon(response.piece, response.destination, response.promoteTo);
      if (position?.isCheckMateForSideToMove == true) {
        logfn(currentGame?.pgn);

        logfn("I've been mated");
      }
    } else {
      logfn('no best move');
    }
  }

  void setCurrentMove(Move move) {
    if (currentGame == null) return;
    var moveIndex = currentGame!.moves.indexWhere((e) => e.id == move.id);
    currentMove = move;
    previewPosition = currentGame!.positions[moveIndex + 1];
    setIndex(moveIndex);

    notifyListeners();
  }

  void moveForward() {
    if (currentGame == null) return;

    var index = currentIndex + 1;

    if (index > currentGame!.positions.length - 2) {
      index = currentGame!.positions.length - 2;
    }

    var move = currentGame!.moves[index];
    setCurrentMove(move);
  }

  void moveBackward() {
    if (currentGame == null) return;

    var index = currentIndex - 1;

    if (index < 0) {
      index = 0;
    }

    var move = currentGame!.moves[index];
    setCurrentMove(move);
  }
}
