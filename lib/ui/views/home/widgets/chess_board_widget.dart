import 'package:chess_app/ui/common/app_colors.dart';
import 'package:chess_app/ui/common/app_values.dart';
import 'package:chess_app/ui/widgets/images/image_card.dart';
import 'package:chess_app/ui/widgets/text/custom_text.dart';
import 'package:chess_app/util/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../models/models.dart';

class ChessBoard extends StatelessWidget {
  final Position position;
  final double size;
  final Piece? selectedPiece;

  final Function(Square square, PieceType? promotion) onTapSquare;
  final List<Square> highlightedSquares;

  const ChessBoard({
    super.key,
    required this.position,
    required this.size,
    this.selectedPiece,
    required this.onTapSquare,
    this.highlightedSquares = const [],
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
            onTapSquare: (square, rect) async {
              var isLastRank = square.rank == 0 || square.rank == 7;
              var isValidMoveForPiece = highlightedSquares.contains(square);
              PieceType? type;
              if (selectedPiece?.type == PieceType.pawn && isLastRank && isValidMoveForPiece) {
                type = await showMenu<PieceType>(
                  position: RelativeRect.fromRect(
                    rect,
                    Offset.zero & MediaQuery.of(context).size,
                  ),
                  context: context,
                  color: Colors.transparent,
                  elevation: 0,
                  menuPadding: EdgeInsets.zero,
                  items: [
                    PieceType.bishop,
                    PieceType.knight,
                    PieceType.rook,
                    PieceType.queen,
                  ]
                      .map(
                        (e) => PopupMenuItem<PieceType>(
                          padding: EdgeInsets.zero,
                          value: e,
                          child: Container(
                            height: squareSize,
                            width: squareSize,
                            color: Colors.white,
                            padding: const EdgeInsetsGeometry.all(8),
                            child: ImageCard.local(
                              '${e.name}-${selectedPiece?.color.name}.svg',
                              size: squareSize,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
                if (type == null) return;
              }

              onTapSquare(square, type);
            },
            isHighlighted: (square) => highlightedSquares.contains(square),
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
  final void Function(Square square, Rect globalRect) onTapSquare;
  final bool Function(Square square) isHighlighted;

  const _BoardGrid({
    required this.squareSize,
    required this.onTapSquare,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (row) {
        final rank = 7 - row;

        return Row(
          children: List.generate(8, (file) {
            final square = Square.fromFileRank(file, rank);
            final isLight = (rank + file) % 2 == 0;
            final highlighted = isHighlighted(square);

            final squareColorValue = isLight ? kE0E5C4 : k5C8F40;
            final textColor = !isLight ? kE0E5C4 : k5C8F40;
            return Builder(
              builder: (squareContext) {
                return GestureDetector(
                  onTap: () {
                    final renderBox = squareContext.findRenderObject() as RenderBox;

                    final topLeft = renderBox.localToGlobal(Offset.zero);
                    final rect = topLeft & renderBox.size;

                    onTapSquare(square, rect);
                  },
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    color: squareColorValue,
                    child: Stack(
                      children: [
                        if (highlighted)
                          Center(
                            child: Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        if (file == 0)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: CustomText.w600(
                              (rank + 1).toString(),
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        if (rank == 0)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: CustomText.w600(
                              square.algebraic.substring(0, 1),
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
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
