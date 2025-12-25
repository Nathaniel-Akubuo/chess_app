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

  bool selectSquare(Square square, PieceType? promotion) {
    if (previewPosition != null && previewPosition?.id != position.id) return false;
    var isHighlighted = highlightedPiece != null;

    if (isHighlighted) {
      var isValidMoveForPiece = validMovesForSelectedPiece.contains(square);
      if (isValidMoveForPiece) {
        _updatePositon(highlightedPiece!, square, promotion);
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
      highlightedPiece == null ? [] : position.validSquaresForPiece(highlightedPiece!);

  void _updatePositon(Piece piece, Square newSquare, PieceType? promotion) {
    if (piece.square == null) return;
    var move = Move(
      from: piece.square!,
      destination: newSquare,
      piece: piece,
      capturedPiece: position.pieceAt(newSquare),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      promoteTo: promotion,
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
