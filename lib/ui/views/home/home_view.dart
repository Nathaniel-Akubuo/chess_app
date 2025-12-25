import 'package:chess_app/models/piece.dart';
import 'package:chess_app/ui/common/app_colors.dart';
import 'package:chess_app/ui/common/app_values.dart';
import 'package:chess_app/ui/common/ui_helpers.dart';
import 'package:chess_app/ui/views/home/widgets/chess_board_widget.dart';
import 'package:chess_app/ui/widgets/buttons/custom_card.dart';
import 'package:chess_app/ui/widgets/buttons/ripple_card.dart';
import 'package:chess_app/ui/widgets/general/custom_layouts.dart';
import 'package:chess_app/ui/widgets/text/custom_text.dart';
import 'package:chess_app/util/extensions.dart';
import 'package:chess_app/util/ui_extensions.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                onPressed: () => viewModel.moveBackward(),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                onPressed: () => viewModel.moveForward(),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: SizedBox(
                width: screenWidth(context),
                child: ScrollableRow(
                  controller: _scrollController,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ...viewModel.currentGame.movePairs
                        .mapIndexed(
                          (i, e) => CustomCard(
                            borderRadius: k4pxBorderRadius,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            color: kPrimaryColor,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomText.w600((i + 1).toString()),
                                horizontalSpace(4),
                                ...e.map(
                                  (e) => RippleCard(
                                    onTap: () => viewModel.setCurrentMove(e),
                                    borderRadius: k4pxBorderRadius,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    color: Colors.transparent,
                                    child: CustomText.w500(
                                      e.toAlgebraic(),
                                      fontSize: 14,
                                      color: e.piece.color == PieceColor.black
                                          ? k817F7B
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .insertBetweenElements(horizontalSpace(12)),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              ChessBoard(
                position: viewModel.previewPosition ?? viewModel.position,
                onTapSquare: (square) {
                  var moveMade = viewModel.selectSquare(square);
                  if (moveMade) {
                    _scrollController.animateTo(_scrollController.positions.last.maxScrollExtent, duration: twoFiftyMS, curve: Curves.linear);
                  }
                },
                size: screenWidth(context),
                highlightedSquares: viewModel.validMovesForSelectedPiece,
              ),
              verticalSpace(10),
            ],
          ),
        );
      },
    );
  }
}
