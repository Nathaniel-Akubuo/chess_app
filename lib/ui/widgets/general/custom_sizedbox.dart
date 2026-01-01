import 'package:flutter/material.dart';

class CustomSizedbox extends StatelessWidget {
  final double? height;
  final double? width;
  final double? size;
  final Widget? child;

  const CustomSizedbox({
    this.height,
    this.width,
    this.size,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? height,
      width: size ?? width,
      child: child,
    );
  }
}
