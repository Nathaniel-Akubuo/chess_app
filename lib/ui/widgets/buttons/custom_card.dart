import 'package:chess_app/ui/common/app_values.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? size;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLongPress;
  final bool visible;
  final Duration? duration;

  final Gradient? gradient;
  final bool _nonAnimating;
  final Widget? replacement;

  const CustomCard({
    this.child,
    this.width,
    this.height,
    this.size,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.color,
    this.padding,
    this.borderRadius,
    this.border,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.visible = true,
    this.duration,
    super.key,
    this.gradient,
    this.replacement,
  }) : _nonAnimating = false;

  const CustomCard.nonAnimating({
    this.child,
    this.width,
    this.height,
    this.size,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.color,
    this.padding,
    this.borderRadius,
    this.border,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.visible = true,
    this.duration,
    super.key,
    this.gradient,
    this.replacement,
  }) : _nonAnimating = true;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      replacement: replacement ?? const SizedBox.shrink(),
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: onTap,
        child: _nonAnimating
            ? Container(
                margin: margin,
                height: (size ?? height),
                width: (size ?? width),
                padding: padding,
                constraints: BoxConstraints(
                  minHeight: (minHeight ?? 0),
                  minWidth: (minWidth ?? 0),
                  maxWidth: (maxWidth ?? double.infinity),
                  maxHeight: (maxHeight ?? double.infinity),
                ),
                decoration: BoxDecoration(
                  border: border,
                  color: color ?? Colors.white,
                  borderRadius: borderRadius ?? BorderRadius.zero,
                  gradient: gradient,
                ),
                child: child,
              )
            : _Animated(
                width: width,
                height: height,
                minWidth: minWidth,
                minHeight: minHeight,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                color: color,
                padding: padding,
                margin: margin,
                borderRadius: borderRadius,
                border: border,
                duration: duration,
                size: size,
                gradient: gradient,
                child: child,
              ),
      ),
    );
  }
}

class _Animated extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;

  final Duration? duration;

  final double? size;
  final Gradient? gradient;

  const _Animated({
    required this.child,
    required this.width,
    required this.height,
    required this.minWidth,
    required this.minHeight,
    required this.maxWidth,
    required this.maxHeight,
    required this.color,
    required this.padding,
    required this.margin,
    required this.borderRadius,
    required this.border,
    required this.duration,
    required this.size,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration ?? twoFiftyMS,
      margin: margin,
      height: (size ?? height),
      width: (size ?? width),
      padding: padding,
      constraints: BoxConstraints(
        minHeight: (minHeight ?? 0),
        minWidth: (minWidth ?? 0),
        maxWidth: (maxWidth ?? double.infinity),
        maxHeight: (maxHeight ?? double.infinity),
      ),
      decoration: BoxDecoration(
        border: border,
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.zero,
        gradient: gradient,
      ),
      child: child,
    );
  }
}
