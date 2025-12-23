import 'package:chess_app/ui/common/ui_helpers.dart';
import 'package:chess_app/ui/views/home/widgets/chess_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ChessBoard(
            position: viewModel.position,
            onTapSquare: viewModel.selectSquare,
            size: screenWidth(context),
            highlightedSquares: viewModel.validMovesForSelectedPiece,
          ),
          verticalSpace(10)
        ],
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
