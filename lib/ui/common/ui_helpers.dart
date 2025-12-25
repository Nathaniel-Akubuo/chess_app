import 'dart:math';

import 'package:chess_app/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

const k120pxBorderRadius = BorderRadius.all(Radius.circular(120));
const k100pxBorderRadius = BorderRadius.all(Radius.circular(100));
const k64pxBorderRadius = BorderRadius.all(Radius.circular(64));
const k40pxBorderRadius = BorderRadius.all(Radius.circular(40));
const k32pxBorderRadius = BorderRadius.all(Radius.circular(32));
const k24pxBorderRadius = BorderRadius.all(Radius.circular(24));
const k20pxBorderRadius = BorderRadius.all(Radius.circular(20));
const k16pxBorderRadius = BorderRadius.all(Radius.circular(16));
const k12pxBorderRadius = BorderRadius.all(Radius.circular(12));
const k10pxBorderRadius = BorderRadius.all(Radius.circular(10));
const k8pxBorderRadius = BorderRadius.all(Radius.circular(8));
const k6pxBorderRadius = BorderRadius.all(Radius.circular(6));
const k4pxBorderRadius = BorderRadius.all(Radius.circular(4));

const k24pxSheetRadius = BorderRadius.vertical(top: Radius.circular(24));

const kMainPadding = EdgeInsets.symmetric(horizontal: 16);
const kMainPaddingDesktop = EdgeInsets.symmetric(horizontal: 24);

final k1pxBorder = Border.all(color: k777573, width: 1);

Widget verticalSpace(double height) => SizedBox(height: height);
Widget horizontalSpace(double width) => SizedBox(width: width);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(
  BuildContext context, {
  int dividedBy = 1,
  double offsetBy = 0,
  double max = 3000,
}) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(
  BuildContext context, {
  int dividedBy = 1,
  double offsetBy = 0,
  double max = 3000,
}) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double halfScreenWidth(BuildContext context) => screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) => screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) => screenWidthFraction(context, dividedBy: 4);

double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 10);
double getResponsiveSmallFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 14, max: 15);

double getResponsiveMediumFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 16, max: 17);

double getResponsiveLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 21, max: 31);

double getResponsiveExtraLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 25);

double getResponsiveMassiveFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 30);

double getResponsiveFontSize(
  BuildContext context, {
  double? fontSize,
  double? max,
}) {
  max ??= 100;

  var responsiveSize = min(
    screenWidthFraction(context, dividedBy: 10) * ((fontSize ?? 100) / 100),
    max,
  );

  return responsiveSize;
}

class Inter extends TextStyle {
  const Inter.w300(double fontSize, {Color? color})
      : super(
          fontFamily: 'Inter',
          color: color ?? kTextColor,
          fontWeight: FontWeight.w300,
          fontSize: fontSize,
          letterSpacing: -0.64,
        );

  const Inter.w400(double fontSize, {Color? color})
      : super(
          fontFamily: 'Inter',
          color: color ?? kTextColor,
          fontWeight: FontWeight.w400,
          fontSize: fontSize,
          letterSpacing: -0.64,
        );

  const Inter.w500(double fontSize, {Color? color})
      : super(
          fontFamily: 'Inter',
          color: color ?? kTextColor,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
          letterSpacing: -0.64,
        );

  const Inter.w600(double fontSize, {Color? color})
      : super(
          fontFamily: 'Inter',
          color: color ?? kTextColor,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
          letterSpacing: -0.64,
        );

  const Inter.w700(double fontSize, {Color? color})
      : super(
          fontFamily: 'Inter',
          color: color ?? kTextColor,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          letterSpacing: -0.64,
        );
}
