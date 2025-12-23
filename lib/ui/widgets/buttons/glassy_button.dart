import 'dart:ui';

import 'package:chess_app/ui/common/ui_helpers.dart';
import 'package:chess_app/ui/widgets/buttons/custom_card.dart';
import 'package:flutter/material.dart';

class GlassyButton extends StatelessWidget {
  final Widget child;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final GestureTapCallback? onTap;
  final BorderRadius? radius;
  final bool centerChild;
  final bool responsive;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final double? blur;

  const GlassyButton({
    required this.child,
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.onTap,
    this.radius,
    this.centerChild = true,
    this.responsive = true,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? k120pxBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur ?? 1, sigmaY: blur ?? 1),
        child: CustomCard(
          onTap: onTap,
          height: height ?? size,
          width: width ?? size,
          borderRadius: radius ?? k120pxBorderRadius,
          color: color ?? Colors.transparent,
          maxHeight: maxHeight,
          minHeight: minHeight,
          maxWidth: maxWidth,
          minWidth: minWidth,
          child: centerChild ? Center(child: child) : child,
        ),
      ),
    );
  }
}
