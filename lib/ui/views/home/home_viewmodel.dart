import 'package:chess_app/models/models.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends IndexTrackingViewModel {
  late Game _currentGame;

  HomeViewModel() : _currentGame = Game.newGame();

  Square? selectedSquare;

  Game get currentGame => _currentGame;

  Move? currentMove;
  Position? previewPosition;

  Position get position => _currentGame.currentPosition;

  Piece? get highlightedPiece => selectedSquare == null ? null : position.pieceAt(selectedSquare!);

  void selectSquare(Square square) {
    if (previewPosition != null && previewPosition?.id != position.id) return;
    var isHighlighted = highlightedPiece != null;

    if (isHighlighted) {
      var isValidMoveForPiece = validMovesForSelectedPiece.contains(square);
      if (isValidMoveForPiece) _updatePositon(highlightedPiece!, square);
      selectedSquare = null;
      notifyListeners();
    } else {
      selectedSquare = square;
      notifyListeners();
    }
  }

  List<Square> get validMovesForSelectedPiece =>
      highlightedPiece == null ? [] : position.validSquaresForPiece(highlightedPiece!);

  void _updatePositon(Piece piece, Square newSquare) {
    if (piece.square == null) return;
    var move = Move(
      from: piece.square!,
      destination: newSquare,
      piece: piece,
      capturedPiece: position.pieceAt(newSquare),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    _currentGame = _currentGame.makeMove(move);
    previewPosition = null;
    setIndex(currentIndex + 1);
  }

  void setCurrentMove(Move move) {
    var moveIndex = _currentGame.moves.indexWhere((e) => e.id == move.id);
    currentMove = move;
    previewPosition = _currentGame.positions[moveIndex + 1];
    setIndex(moveIndex);

    notifyListeners();
  }

  void moveForward() {
    var index = currentIndex + 1;

    if (index > _currentGame.positions.length - 2) {
      index = _currentGame.positions.length - 2;
    }

    var move = _currentGame.moves[index];
    setCurrentMove(move);
  }

  void moveBackward() {
    var index = currentIndex - 1;

    if (index < 0) {
      index = 0;
    }

    var move = _currentGame.moves[index];
    setCurrentMove(move);
  }
}
