import 'package:chess_app/ui/common/ui_helpers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class CustomString {
  String? string;
  TextStyle? textStyle;

  GestureTapCallback? onTap;

  CustomString({
    this.string,
    this.textStyle,
    this.onTap,
  });
}

class CustomRichText extends StatelessWidget {
  final String? text;
  final List<InlineSpan>? children;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextStyle? style;
  final TextAlign? textAlign;

  final bool _splitByNairaSign;
  final List<CustomString>? customString;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const CustomRichText({
    super.key,
    this.text,
    this.children,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.style,
    this.textAlign,
    this.customString,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : _splitByNairaSign = false;

  const CustomRichText.split({
    super.key,
    this.text,
    this.children,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.style,
    this.textAlign,
    this.customString,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : _splitByNairaSign = true;

  TextStyle? _textStyle(String text) =>
      customString?.nullableFirstWhere((e) => e.string == text)?.textStyle;

  List<String> get _splitString =>
      (text ?? '').splitByList(['₦', ...(customString?.map((e) => e.string ?? '').toList() ?? [])]);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      softWrap: softWrap ?? true,
      text: TextSpan(
        style: style ?? Inter.w500(fontSize ?? 16),
        children: _splitByNairaSign
            ? _splitString.map(
                (e) {
                  var onTap = customString?.nullableFirstWhere((cs) => cs.string == e)?.onTap;

                  return TextSpan(
                    text: e,
                    recognizer: onTap != null ? (TapGestureRecognizer()..onTap = onTap) : null,
                    style: e == '₦'
                        ? DefaultTextStyle.of(context).style.copyWith(
                              color: style?.color,
                              fontSize: style?.fontSize,
                              fontWeight: style?.fontWeight ?? FontWeight.w500,
                              letterSpacing: style?.letterSpacing,
                            )
                        : (_textStyle(e) ?? style ?? const Inter.w500(16)),
                  );
                },
              ).toList()
            : children,
      ),
    );
  }
}

extension _NullableExtensions<E> on List<E>? {
  E? nullableFirstWhere(bool Function(E e) test) {
    try {
      var e = this?.firstWhere(test);
      return e;
    } catch (e) {
      return null;
    }
  }
}

extension _StringExtension on String {
  List<String> splitByList(List<String> list) {
    final regexPattern = list.map(RegExp.escape).join('|');
    final regex = RegExp('($regexPattern)');

    final result = <String>[];
    splitMapJoin(
      regex,
      onMatch: (match) {
        result.add(match.group(0)!);
        return '';
      },
      onNonMatch: (nonMatch) {
        if (nonMatch.isNotEmpty) result.add(nonMatch);
        return '';
      },
    );

    return result;
  }
}
