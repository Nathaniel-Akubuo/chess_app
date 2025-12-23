import 'package:chess_app/ui/common/app_values.dart';
import 'package:chess_app/ui/widgets/images/image_card.dart';
import 'package:chess_app/util/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../models/models.dart';

class ChessBoard extends StatelessWidget {
  final Position position;
  final double size;
  final Piece? selectedPiece;
  final Function(Square? square) onTapSquare;

  const ChessBoard({
    super.key,
    required this.position,
    required this.size,
    this.selectedPiece,
    required this.onTapSquare,
  });

  @override
  Widget build(BuildContext context) {
    final squareSize = size / 8;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          _BoardGrid(
            squareSize: squareSize,
            onTapSquare: (index) => onTapSquare(Square(index)),
          ),
          ..._pieces,
        ],
      ),
    );
  }

  List<Widget> get _pieces {
    final squareSize = size / 8;

    final pieces = <Widget>[];

    for (int i = 0; i < 64; i++) {
      final piece = position.pieces.nullableFirstWhere((e) => e.square?.index == i);
      if (piece == null) continue;

      final square = piece.square;

      if (square == null) continue;

      final offset = _squareToOffset(square, squareSize);

      pieces.add(
        AnimatedPositioned(
          key: ValueKey(piece.initialSquare.algebraic),
          duration: twoFiftyMS,
          curve: Curves.easeInOut,
          left: offset.dx,
          top: offset.dy,
          width: squareSize,
          height: squareSize,
          child: IgnorePointer(
            child: _ChessPiece(
              piece: piece,
              squareSize: squareSize,
            ),
          ),
        ),
      );
    }

    return pieces;
  }

  Offset _squareToOffset(Square square, double squareSize) {
    final file = square.file;
    final rank = square.rank;

    final x = file * squareSize;
    final y = (7 - rank) * squareSize;

    return Offset(x.toDouble(), y.toDouble());
  }
}

class _BoardGrid extends StatelessWidget {
  final double squareSize;
  final Function(int index) onTapSquare;

  const _BoardGrid({
    required this.squareSize,
    required this.onTapSquare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (_) {
        var rank = 7 - _;
        return Row(
          children: List.generate(8, (file) {
            var index = rank * 8 + file;

            final isLight = (rank + file) % 2 == 0;
            return GestureDetector(
              onTap: () => onTapSquare(index),
              child: Container(
                width: squareSize,
                height: squareSize,
                color: isLight ? const Color(0xFFEEEED2) : const Color(0xFF769656),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _ChessPiece extends StatelessWidget {
  final Piece piece;
  final double squareSize;

  const _ChessPiece({
    required this.piece,
    required this.squareSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Padding(
          padding: const EdgeInsetsGeometry.all(8),
          child: ImageCard.local(
            '${piece.type.name}-${piece.color.name}.svg',
            size: squareSize,
          ),
        ),
      ),
    );
  }
}
