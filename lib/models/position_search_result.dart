import 'models.dart';

class PositionSearchResult {
  final int score;
  final Move? bestMove;

  PositionSearchResult(this.score, this.bestMove);
}
