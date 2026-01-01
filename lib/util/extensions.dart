import 'dart:typed_data';

import 'package:chess_app/ui/common/app_values.dart';
import 'package:chess_app/ui/widgets/animations/bouncing_dots.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String getFilenameFromUrl() {
    final uri = Uri.parse(this);
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
  }

  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String camelCasePhrase() {
    if (isEmpty) return this;
    List<String> commonWords = ["and", "or", "a", "an", "the", "in", "on", "at"];
    List<String> words = split(" ");
    List<String> capitalizedWords = words.mapIndexed((index, word) {
      if (index == 0 || !commonWords.contains(word.toLowerCase())) {
        return word.capitalize();
      } else {
        return word;
      }
    }).toList();
    return capitalizedWords.join(" ");
  }

  List<String> get splitByNairaSign => splitByList([nairaSign]);

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

  String get formatPhoneNumber {
    var phone = trim().replaceAll(' ', '');
    if (phone.startsWith('+234')) {
      return phone;
    } else if (phone.startsWith('234')) {
      return '+$phone';
    } else if (phone.startsWith('0')) {
      return '+234${phone.substring(1)}';
    } else {
      return '+234$phone';
    }
  }

  String? get titleFromHTML {
    RegExp titleRegex = RegExp(r'<title>(.*?)</title>');

    RegExpMatch? match = titleRegex.firstMatch(this);

    if (match != null) {
      String title = match.group(1)!;

      title = title.replaceAllMapped(RegExp(r'&#?\w+;'), (match) {
        var entity = match.group(0);
        switch (entity) {
          case '&amp;':
            return '&';
          case '&lt;':
            return '<';
          case '&gt;':
            return '>';
          case '&quot;':
            return '"';
          case '&apos;':
            return "'";

          default:
            return entity!;
        }
      });

      return title;
    } else {
      return null;
    }
  }

  Color? get toColor {
    try {
      if (length < 7) {
        return null;
      } else {
        if (contains('0xff')) {
          return Color(int.parse(replaceAll('Color(', '').replaceAll(')', '')));
        } else {
          var code = replaceAll('#', '').replaceAll('Color(', '').replaceAll(')', '');
          var string = '0xff$code';
          return Color(int.parse(string));
        }
      }
    } catch (e) {
      return null;
    }
  }

  Color? get colorFromHex {
    var hexString = this;
    if (hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension IterableExtensionsUnique<E, Id> on Iterable<E> {
  List<E> unique(Id Function(E element) id) {
    var ids = <dynamic>{};
    var list = List<E>.from(this);
    list.retainWhere((x) => ids.add(id(x)));
    return list;
  }

  bool containsElementWithId(bool Function(E e) test) {
    var value = nullableFirstWhere(test);

    return value != null;
  }

  bool elementExistsAtIndex(int index) {
    if (index.isNegative) {
      return false;
    } else if (index >= length) {
      return false;
    } else {
      return true;
    }
  }

  E? nullableFirstWhere(bool Function(E e) test) {
    try {
      var e = firstWhere(test);
      return e;
    } catch (e) {
      return null;
    }
  }

  E? nullableLastWhere(bool Function(E e) test) {
    try {
      var e = lastWhere(test);
      return e;
    } catch (e) {
      return null;
    }
  }

  E? get nullableFirst {
    if (isEmpty == true) {
      return null;
    } else {
      return first;
    }
  }

  E? get nullableLast {
    if (isEmpty == true) {
      return null;
    } else {
      return last;
    }
  }
}

extension IterableExtensions<E> on Iterable<E> {
  bool isEveryItemPresent(Iterable<E>? b) {
    if (b == null) {
      return false;
    }

    for (var item in b) {
      if (contains(item) == false) return false;
    }
    return true;
  }

  Iterable<dynamic> insertBetweenElements(dynamic elementToInsert) {
    if (isEmpty) return [];

    List<dynamic> resultList = [];

    for (int i = 0; i < length - 1; i++) {
      resultList.add(toList()[i]);
      resultList.add(elementToInsert);
    }

    resultList.add(last);

    return resultList;
  }
}

extension Unique<E, Id> on List<E> {
  List<List<E>> chunk([int size = 3]) {
    List<List<E>> chunks = [];
    for (var i = 0; i < length; i += size) {
      var end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) sync* {
    var index = 0;
    for (var element in this) {
      yield f(index, element);
      index++;
    }
  }

  bool isItemPresent(List<E> list2) {
    for (var item in list2) {
      if (contains(item)) return true;
    }
    return false;
  }

  int repeatingIndexOf(E e, [int count = 10]) {
    var index = indexOf(e);
    var max = (index / count).floor();

    var repeatingIndex = index - (10 * max);
    return repeatingIndex;
  }

  List<E> insertBetweenElements(E elementToInsert) {
    if (isEmpty) return [];

    List<E> resultList = [];

    for (int i = 0; i < length - 1; i++) {
      resultList.add(this[i]);
      resultList.add(elementToInsert);
    }

    resultList.add(last);

    return resultList;
  }

  E? itemAtIndexOrNull(int index) {
    try {
      var e = this[index];
      return e;
    } catch (e) {
      return null;
    }
  }

  E? nullableFirstWhere(bool Function(E e) test) {
    try {
      var e = firstWhere(test);
      return e;
    } catch (e) {
      return null;
    }
  }

  E? nullableLastWhere(bool Function(E e) test) {
    try {
      var e = lastWhere(test);
      return e;
    } catch (e) {
      return null;
    }
  }

  List<List<E>> groupBy(dynamic Function(E element) id) {
    List<List<E>> groupedLists = [];

    for (E element in this) {
      dynamic key = id(element);
      bool found = false;

      for (int i = 0; i < groupedLists.length; i++) {
        if (groupedLists[i].isNotEmpty && id(groupedLists[i].first) == key) {
          groupedLists[i].add(element);
          found = true;
          break;
        }
      }

      if (!found) {
        groupedLists.add([element]);
      }
    }

    return groupedLists;
  }
}

extension NumExtensions on num? {
  String get numberFormat => numberFormatter.format(this ?? 0);

  String get nairaFormat => nairaFormatter.format(this ?? 0);

  String get nairaFormatPDF => NumberFormat('NGN#,###.##').format(this ?? 0);

  String formatCount(String singular, [String? plural]) {
    var value = this ?? 0;
    if (value == 1) {
      return '1 $singular';
    } else {
      return '${compactNumberFormatter.format(value)} ${plural ?? '${singular}s'}';
    }
  }

  List<Icon> ratingStars() {
    var rating = this ?? 0;
    var ratingAsInt = rating.toInt();
    var color = const Color(0xffFFCC4D);
    List<Icon> list = [
      ...List<Icon>.generate(
        ratingAsInt,
        (index) => Icon(Icons.star_rounded, color: color, size: 36),
      ),
      ...List<Icon>.generate(
        5 - ratingAsInt,
        (index) => Icon(
          Icons.star_border_rounded,
          color: color,
          size: 36,
        ),
      )
    ];
    if (rating - ratingAsInt >= 0.5) {
      list.insert(
        ratingAsInt,
        Icon(Icons.star_half_rounded, color: color, size: 36),
      );
      list.removeLast();
    }

    return list;
  }

  String toShortString({int decimals = 1}) {
    final double value = (this?.toDouble() ?? 0);
    final String sign = value < 0 ? '-' : '';
    final double absValue = value.abs();

    if (value == 0) return '0';

    String trim(double v, int d) {
      final s = v.toStringAsFixed(d);
      return s.replaceAll(RegExp(r'\.?0+$'), '');
    }

    if (absValue < 1000) return '$sign${trim(absValue, 0)}';
    if (absValue < 1e6) return '$sign${trim(absValue / 1e3, decimals)}K';
    if (absValue < 1e9) return '$sign${trim(absValue / 1e6, decimals)}M';
    return '$sign${trim(absValue / 1e9, decimals)}B';
  }
}

extension DateExtensions on DateTime? {
  String timeAgo() {
    if (this == null) {
      return 'now';
    }
    var elapsed = DateTime.now().millisecondsSinceEpoch - this!.millisecondsSinceEpoch;

    var seconds = elapsed / 1000;
    var minutes = seconds / 60;
    var hours = minutes / 60;
    var days = hours / 24;
    var months = days / 30;
    var years = days / 365;

    String value = '';

    if (seconds < 45) {
      value = "now";
    } else if (seconds < 90) {
      value = '1 minute ago';
    } else if (minutes < 45) {
      value = '${minutes.round()} minutes ago ';
    } else if (minutes < 90) {
      value = '1 hour ago';
    } else if (hours < 24) {
      value = '${hours.round()} hours ago ';
    } else if (hours < 48) {
      value = '1 day ago';
    } else if (days < 30) {
      value = '${days.round()} days ago';
    } else if (days < 60) {
      value = '1 month ago ';
    } else if (days < 365) {
      value = '${months.round()} months ago ';
    } else if (years < 2) {
      value = '1 year ago';
    } else {
      value = '${years.round()} years ago';
    }

    return value;
  }

  String timeLeft() {
    if (this == null) {
      return 'now';
    }
    var elapsed = this!.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;

    var seconds = elapsed / 1000;
    var minutes = seconds / 60;
    var hours = minutes / 60;
    var days = hours / 24;
    var months = days / 30;
    var years = days / 365;

    String value = '';

    if (seconds < 60) {
      value = seconds.floor().formatCount('second');
    } else if (minutes < 60) {
      value = minutes.floor().formatCount('minute');
    } else if (hours < 24) {
      value = hours.floor().formatCount('hour');
    } else if (days < 30) {
      value = days.floor().formatCount('day');
    } else if (months < 12) {
      value = months.floor().formatCount('month');
    } else {
      value = years.floor().formatCount('year');
    }

    return value;
  }

  String get kJMFormat => this == null ? '' : kDateFormatJM.format(this!.toLocal());

  String get kEEEMMMdFormat => this == null ? '' : kDateFormatEEEMMMd.format(this!.toLocal());
  String get kDobFormat => this == null ? '' : kDateFormatDob.format(this!.toLocal());
  String get kMMMdFormat => this == null ? '' : kDateFormatMMMd.format(this!.toLocal());
  String get kEdMhmma => this == null ? '' : kDateFormatEdMhmma.format(this!.toLocal());
  String get pickupDateFormat => this == null ? '' : kReceiptDateFormatter.format(this!.toLocal());
  String get orderDateFormat =>
      this == null ? '' : DateFormat("MMM d, yyyy - h:mm a").format(this!.toLocal());
  String get reportFormat => this == null
      ? ''
      : DateFormat("${this?.isSameDayAs(DateTime.now()) == true ? "'Today, '" : ''}MMM d, yyyy")
          .format(this!.toLocal());

  String get monthFormat => this == null ? '' : DateFormat('MMM d').format(this!.toLocal());

  bool isSameDayAs(DateTime other) =>
      this?.year == other.year && this?.month == other.month && this?.day == other.day;

  bool isWithin({DateTime? start, DateTime? end, bool inclusive = true}) {
    if (this == null) return false;
    if (start == null || end == null) return false;

    if (inclusive) {
      return this!.isAtSameMomentAs(start) ||
          this!.isAtSameMomentAs(end) ||
          (this!.isAfter(start) && this!.isBefore(end));
    } else {
      return this!.isAfter(start) && this!.isBefore(end);
    }
  }
}

extension DurationFormatting on Duration {
  String get formatDuration {
    if (isNegative) {
      return "0s";
    }

    String hoursPart =
        (inHours > 0) ? '${inHours}h${(inMinutes.remainder(60) > 0) ? ' ' : ''}' : '';

    String minutesPart = (inMinutes.remainder(60) > 0)
        ? '${inMinutes.remainder(60)}m${(inSeconds.remainder(60) > 0) ? ' ' : ''}'
        : '';

    String secondsPart = (inSeconds.remainder(60) > 0) ? '${inSeconds.remainder(60)}s' : '';

    return '$hoursPart$minutesPart$secondsPart';
  }
}

extension ColorExt on Color {
  Color withOpacityValue(double value) => withAlpha((255.0 * value).round());

  String get toHex => '#'
      // ignore: deprecated_member_use
      '${red.toRadixString(16).padLeft(2, '0')}'
      // ignore: deprecated_member_use
      '${green.toRadixString(16).padLeft(2, '0')}'
      // ignore: deprecated_member_use
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension UsefulExtensions<T> on Future<T?> {
  Future<T?> tryCatch({
    Function(dynamic)? onError,
    Function(dynamic)? onRetry,
    bool retry = false,
    int? maxRetries,
    Duration? retryAfter,
  }) async {
    if (retry) {
      int retryCount = 0;
      T? response;

      while (retryCount < (maxRetries ?? 100)) {
        try {
          var value = await this;

          if (value == null) {
            retryCount++;
            await Future.delayed(retryAfter ?? threeSeconds);
          } else {
            response = value;
            break;
          }
        } catch (e) {
          if (onRetry != null) {
            onRetry(e);
          }
          retryCount++;
          await Future.delayed(retryAfter ?? threeSeconds);
        }
      }
      return response;
    } else {
      try {
        var value = await this;
        return value;
      } catch (e) {
        if (onError == null) {
          // ToastService.showErrorToast(message: e.toString());
        } else {
          onError(e);
        }
      }
      return null;
    }
  }
}

extension RetryEXT<T> on Future<T?> Function() {
  Future<T?> tryCatch({
    Function(dynamic)? onError,
    Function(dynamic)? onRetry,
    bool retry = false,
    int? maxRetries,
    Duration? retryAfter,
  }) async {
    if (retry) {
      int retryCount = 0;
      T? response;

      while (retryCount < (maxRetries ?? 100)) {
        try {
          var value = await this();
          if (value == null) {
            retryCount++;
            await Future.delayed(retryAfter ?? const Duration(seconds: 3));
          } else {
            response = value;
            break;
          }
        } catch (e) {
          if (onRetry != null) {
            onRetry(e);
          }
          retryCount++;
          // logfn(e);
          await Future.delayed(retryAfter ?? const Duration(seconds: 3));
        }
      }
      return response;
    } else {
      try {
        return await this();
      } catch (e) {
        if (onError != null) {
          onError(e);
        } else {
          // ToastService.showErrorToast(message: e.toString());
        }
        return null;
      }
    }
  }
}

extension ContexExt on BuildContext {
  // AppLocalizations get l10n => AppLocalizations.of(this)!;

  Locale get currentLocale => Localizations.localeOf(this);

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();

    return Navigator.pushNamed<T>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) => Navigator.pop(this, result);

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(
      this,
    ).pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
  }

  void toggleLoader(bool value) {
    if (value) {
      showDialog(context: this, builder: (_) => const BouncingDotsLoader());
    } else {
      pop();
    }
  }
}

extension Uint8ListExt on Uint8List {
  String? extension() {
    var bytes = this;
    if (bytes.length < 12) return null;

    // JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return "jpg";
    }

    // PNG
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return "png";
    }

    // GIF
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return "gif";
    }

    // WEBP
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return "webp";
    }

    return null; // unknown
  }
}
