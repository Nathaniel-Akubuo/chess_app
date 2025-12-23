import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const twoFiftyMS = Duration(milliseconds: 250);
const fiveHundredMS = Duration(milliseconds: 500);
const sevenFiftyMS = Duration(milliseconds: 750);
const oneSecond = Duration(seconds: 1);
const twoSeconds = Duration(seconds: 2);
const threeSeconds = Duration(seconds: 3);
const fiveSeconds = Duration(seconds: 5);
const sevenSeconds = Duration(seconds: 7);
const tenSeconds = Duration(seconds: 10);
const fifteenSeconds = Duration(seconds: 15);
const oneMinute = Duration(minutes: 1);
const threeMinutes = Duration(minutes: 3);

const String nairaSign = '₦';

final numberFormatter = NumberFormat('#,###.##');
final nairaFormatter = NumberFormat('$nairaSign#,###.##');
final compactNumberFormatter = NumberFormat.compact();
final kDateFormatEEEMMMd = DateFormat('EEE, MMM d');
final kDateFormatMMMd = DateFormat('MMM d');
final kDateFormatDob = DateFormat('MMM d, yyyy');
final kDateFormatEdMhmma = DateFormat("EE d MMM yyyy, h:mm a");
final kReceiptDateFormatter = DateFormat("EE d MMM yyyy 'at' h:mm a");
final hmma = DateFormat("h:mm a");
final kDateFormatJM = DateFormat('jm');

final RegExp urlCleanerRegex = RegExp(r'^(?:https?:\/\/)?(?:www\.)?([^\/\s]+)');
final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
final RegExp formattedAmountCleanerRegex = RegExp(r'[^\d]*');

final digitsOnlyTextFormatter = FilteringTextInputFormatter.allow(RegExp('[0-9+]+'));

const String longText = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
