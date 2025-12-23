import 'package:chess_app/models/models.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  late Game _currentGame;

  HomeViewModel() : _currentGame = Game.newGame();

  Square? selectedSquare;

  Position get position => _currentGame.currentPosition;

  Piece? get highlightedPiece => selectedSquare == null ? null : position.pieceAt(selectedSquare!);

  void selectSquare(Square square) {
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
    var move = Move(from: piece.square!, destination: newSquare, piece: piece);

    _currentGame = _currentGame.makeMove(move);
    notifyListeners();
  }
}
