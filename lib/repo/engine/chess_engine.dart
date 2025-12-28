import '../../models/models.dart';

abstract class ChessEngine {
  int evaluate(Position position);

  Move? bestMove(Position position);
}
