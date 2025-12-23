import 'package:flutter/material.dart';

class RippleCard extends StatelessWidget {
  final Widget child;
  final Widget? replacement;
  final BorderRadiusGeometry? borderRadius;
  final GestureTapCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final bool visible;
  final BoxBorder? border;
  final double? height;
  final double? width;
  final double? size;
  final bool responsive;

  const RippleCard({
    required this.child,
    this.onTap,
    super.key,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.visible = true,
    this.replacement,
    this.border,
    this.height,
    this.width,
    this.size,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      replacement: replacement ?? const SizedBox.shrink(),
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: SizedBox(
          height: (size ?? height),
          width: (size ?? width),
          child: Material(
            color: color ?? Colors.white,
            elevation: elevation ?? 0,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.zero,
            ),
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.zero,
              child: InkWell(
                onTap: onTap ?? () {},
                customBorder: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.zero,
                ),
                child: Ink(
                  padding: padding,
                  decoration: BoxDecoration(
                    border: border,
                    borderRadius: borderRadius,
                    color: Colors.transparent,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
