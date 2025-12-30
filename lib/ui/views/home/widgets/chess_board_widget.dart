import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chess_app/ui/common/app_colors.dart';
import 'package:chess_app/ui/common/app_values.dart';
import 'package:chess_app/ui/widgets/animations/tip_over.dart';
import 'package:chess_app/ui/widgets/images/image_card.dart';
import 'package:chess_app/ui/widgets/text/custom_text.dart';
import 'package:chess_app/util/extensions.dart';
import 'package:chess_app/util/move_validator_extension.dart';
import 'package:flutter/material.dart';

import '../../../../models/models.dart';

class ChessBoard extends StatefulWidget {
  final Position? position;
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
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  final GlobalKey _boardKey = GlobalKey();

  @override
  void didUpdateWidget(covariant ChessBoard oldWidget) {
    bool isNewPosition = widget.position?.move?.id != oldWidget.position?.move?.id;

    if (isNewPosition) {
      var move = widget.position?.move;
      if (move?.isMate == true) {
        _playSound('game-end');
      } else if (move?.isCheck == true) {
        _playSound('move-check');
      } else if (move?.isCastlingMove == true) {
        _playSound('castle');
      } else if (move?.capturedPiece != null) {
        _playSound('capture');
      } else if (move?.promoteTo != null) {
        _playSound('promote');
      } else {
        _playSound('move-self');
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _playSound(String path) {
    var player = AudioPlayer();
    var source = AssetSource('$path.mp3');
    player.play(source);
  }

  Future<PieceType?> _showPromotionOverlay(Rect rect) async {
    var completer = Completer<PieceType?>();
    var squareSize = widget.size / 8;
    var overlay = Overlay.of(context);
    var boardBox = _boardKey.currentContext!.findRenderObject() as RenderBox;

    var boardGlobalOffset = boardBox.localToGlobal(Offset.zero);

    var menuHeight = squareSize * 4;
    var menuTop = widget.selectedPiece!.color == PieceColor.white
        ? boardGlobalOffset.dy
        : boardGlobalOffset.dy + boardBox.size.height - menuHeight;

    var menuLeft = boardGlobalOffset.dx + rect.left;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  entry.remove();
                  completer.complete(null);
                },
              ),
            ),
            Positioned(
              left: menuLeft,
              top: menuTop,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: (widget.selectedPiece!.color == PieceColor.white
                          ? [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]
                          : [PieceType.knight, PieceType.bishop, PieceType.rook, PieceType.queen])
                      .map((type) {
                    return GestureDetector(
                      onTap: () {
                        entry.remove();
                        completer.complete(type);
                      },
                      child: Container(
                        width: squareSize,
                        height: squareSize,
                        padding: const EdgeInsets.all(4),
                        child: ImageCard.local(
                          '${type.name}-${widget.selectedPiece!.color.name}.png',
                          size: squareSize,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(entry);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    var squareSize = widget.size / 8;

    return SizedBox(
      key: _boardKey,
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          _BoardGrid(
            squareSize: squareSize,
            isHighlighted: (square) => widget.highlightedSquares.contains(square),
            onTapSquare: (square, rect) async {
              var isPawn = widget.selectedPiece?.type == PieceType.pawn;
              var isLastRank = square.rank == 0 || square.rank == 7;
              var isValidMoveForPiece = widget.highlightedSquares.contains(square);

              PieceType? type;

              if (isPawn && isLastRank && isValidMoveForPiece) {
                type = await _showPromotionOverlay(rect);
                if (type == null) return;
              }

              widget.onTapSquare(square, type);
            },
          ),
          ..._pieces,
        ],
      ),
    );
  }

  List<Widget> get _pieces {
    var squareSize = widget.size / 8;

    var pieces = <Widget>[];

    for (int i = 0; i < 64; i++) {
      var piece = widget.position?.pieces.nullableFirstWhere((e) => e.square?.index == i);
      if (piece == null) continue;

      var square = piece.square;

      if (square == null) continue;

      var offset = _squareToOffset(square, squareSize);

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
              position: widget.position,
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
        var rank = 7 - row;

        return Row(
          children: List.generate(8, (file) {
            var square = Square.fromFileRank(file, rank);
            var isDark = (rank + file) % 2 == 0;
            var highlighted = isHighlighted(square);

            var squareColorValue = isDark ? k5C8F40 : kE0E5C4;
            var textColor = !isDark ? k5C8F40 : kE0E5C4;

            return Builder(
              builder: (squareContext) {
                return GestureDetector(
                  onTap: () {
                    var renderBox = squareContext.findRenderObject() as RenderBox;
                    var topLeft = renderBox.localToGlobal(Offset.zero);
                    var size = renderBox.size;

                    var rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);

                    onTapSquare(square, rect);
                  },
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(color: squareColorValue),
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
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                        if (rank == 0)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: CustomText.w600(
                              square.fileChar,
                              fontSize: 12,
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
  final Position? position;

  const _ChessPiece({
    required this.piece,
    required this.squareSize,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Padding(
          padding: const EdgeInsetsGeometry.all(4),
          child: TipOver(
            angle: 45,
            duration: fiveHundredMS,
            delay: twoFiftyMS,
            play: position?.isCheckmate(piece.color) == true && piece.type == PieceType.king,
            child: ImageCard.local(
              '${piece.type.name}-${piece.color.name}.png',
              size: squareSize,
            ),
          ),
        ),
      ),
    );
  }
}
