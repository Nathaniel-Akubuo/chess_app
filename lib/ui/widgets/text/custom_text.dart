import 'package:chess_app/ui/common/app_colors.dart';
import 'package:chess_app/ui/widgets/text/custom_richtext.dart';
import 'package:flutter/widgets.dart';

class CustomText extends StatelessWidget {
  final String data;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? softWrap;
  final TextOverflow? overflow;
  final GestureTapCallback? onTap;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final FontStyle? fontStyle;

  const CustomText(
    this.data, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.onTap,
    this.decoration,
    this.letterSpacing,
    this.fontStyle,
  });

  const CustomText.w300(
    this.data, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.w300,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.onTap,
    this.decoration,
    this.letterSpacing,
    this.fontStyle,
  });

  const CustomText.w400(
    this.data, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.w400,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.onTap,
    this.decoration,
    this.letterSpacing,
    this.fontStyle,
  });

  const CustomText.w500(
    this.data, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.w500,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.onTap,
    this.decoration,
    this.letterSpacing,
    this.fontStyle,
  });

  const CustomText.w600(
    this.data, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.w600,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.onTap,
    this.decoration,
    this.letterSpacing,
    this.fontStyle,
  });

  const CustomText.w700(
    this.data, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.w700,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.onTap,
    this.decoration,
    this.letterSpacing,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomRichText.split(
        text: data,
        textAlign: textAlign,
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: overflow,
        style: TextStyle(
          decoration: decoration,
          fontFamily: 'Inter',
          fontWeight: fontWeight ?? FontWeight.w500,
          fontSize: fontSize ?? 16,
          color: color ?? kTextColor,
          letterSpacing: letterSpacing ?? -0.64,
          fontStyle: fontStyle,
        ),
      ),
    );
  }
}
