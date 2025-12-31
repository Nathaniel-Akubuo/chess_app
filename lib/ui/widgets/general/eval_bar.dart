import 'package:chess_app/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

class EvalBar extends StatelessWidget {
  final int eval;
  final double height;

  const EvalBar({
    super.key,
    required this.eval,
    this.height = 8,
  });

  double get _eval {
    var maxEval = 1000;
    var clamped = eval.clamp(-maxEval, maxEval);
    return (clamped + maxEval) / (2 * maxEval);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        value: _eval,
        backgroundColor: k343230,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
