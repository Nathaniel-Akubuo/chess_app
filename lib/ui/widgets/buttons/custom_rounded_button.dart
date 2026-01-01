import 'package:chess_app/ui/common/app_colors.dart';
import 'package:chess_app/ui/common/ui_helpers.dart';
import 'package:chess_app/ui/widgets/animations/bouncing_dots.dart';
import 'package:chess_app/ui/widgets/buttons/ripple_card.dart';
import 'package:flutter/material.dart';

class CustomRoundedButton extends StatelessWidget {
  final bool isBusy;
  final Widget? child;
  final GestureTapCallback? onTap;
  final Color? color;
  final Color? dotsColor;
  final BorderRadius? radius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const CustomRoundedButton({
    super.key,
    this.isBusy = false,
    this.child,
    this.onTap,
    this.color,
    this.dotsColor,
    this.radius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return RippleCard(
      margin: margin,
      padding: padding,
      height: 52,
      width: screenWidth(context),
      onTap: onTap,
      color: color ?? kPrimaryGreen,
      borderRadius: radius ?? k8pxBorderRadius,
      child: isBusy ? const Center(child: BouncingDotsLoader()) : child ?? const SizedBox.shrink(),
    );
  }
}
