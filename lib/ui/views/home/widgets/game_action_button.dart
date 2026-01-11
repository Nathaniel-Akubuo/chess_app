import 'package:chess_app/ui/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';

class GameActionButton extends StatelessWidget {
  final IconData iconData;
  final String text;
  final VoidCallback? onPressed;
  final double? size;

  const GameActionButton({
    super.key,
    required this.iconData,
    required this.text,
    this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: Colors.white.withValues(alpha: 0.5), size: size),
          CustomText.w700(text, fontSize: 14, color: Colors.white.withValues(alpha: 0.5))
        ],
      ),
    );
  }
}
