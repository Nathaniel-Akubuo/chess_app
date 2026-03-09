import 'package:chess_app/models/piece.dart';
import 'package:chess_app/ui/common/app_colors.dart';
import 'package:chess_app/ui/common/app_values.dart';
import 'package:chess_app/ui/common/ui_helpers.dart';
import 'package:chess_app/ui/views/home/widgets/chess_board_widget.dart';
import 'package:chess_app/ui/views/home/widgets/game_action_button.dart';
import 'package:chess_app/ui/widgets/buttons/custom_card.dart';
import 'package:chess_app/ui/widgets/buttons/ripple_card.dart';
import 'package:chess_app/ui/widgets/general/custom_layouts.dart';
import 'package:chess_app/ui/widgets/general/eval_bar.dart';
import 'package:chess_app/ui/widgets/text/custom_text.dart';
import 'package:chess_app/util/extensions.dart';
import 'package:chess_app/util/ui_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEndOfList() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: twoFiftyMS,
        curve: Curves.linear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaddedRow(
                padding: kMainPadding,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameActionButton(
                    iconData: Icons.copy_rounded,
                    text: 'Copy PGN',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: viewModel.currentGame?.pgn ?? ''));
                    },
                  ),
                  GameActionButton(
                    iconData: Icons.undo_rounded,
                    text: 'Undo',
                    onPressed: viewModel.undo,
                  ),
                  GameActionButton(
                    iconData: Icons.restart_alt_rounded,
                    text: 'New game',
                    onPressed: viewModel.newGame,
                  ),
                ],
              ),
              verticalSpace(32),
            ],
          ),
          appBar: AppBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // EvalBar(eval: viewModel.eval),
              ChessBoard(
                userSide: viewModel.userSide,
                position: viewModel.previewPosition ?? viewModel.position,
                selectedPiece: viewModel.highlightedPiece,
                onTapSquare: (square, promotion) async {
                  var moveMade = viewModel.selectSquare(square, promotion);
                  if (moveMade) _scrollToEndOfList();
                },
                size: screenWidth(context),
                highlightedSquares: viewModel.validMovesForSelectedPiece,
              ),
              SizedBox(
                width: screenWidth(context),
                height: 40,
                child: ScrollableRow(
                  controller: _scrollController,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ...(viewModel.currentGame?.movePairs ?? [])
                        .mapIndexed(
                          (i, e) => CustomCard(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            color: kPrimaryColor,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: k575553,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: CustomText.w600(
                                    (i + 1).toString(),
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                horizontalSpace(4),
                                ...e.map(
                                  (e) => RippleCard(
                                    onTap: () => viewModel.setCurrentMove(e),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    color: Colors.transparent,
                                    child: CustomText.w500(
                                      e.san ?? '',
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
                        .insertBetweenElements(horizontalSpace(4)),
                  ],
                ),
              ),
              verticalSpace(10),
            ],
          ),
        );
      },
    );
  }
}
