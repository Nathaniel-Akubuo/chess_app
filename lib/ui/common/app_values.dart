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

const String testPGN = r'''[Event "Live Chess"]
[Site "Chess.com"]
[Date "2025.09.23"]
[Round "-"]
[White "nakubuo"]
[Black "Colooo006"]
[Result "1-0"]
[CurrentPosition "k2rr3/p4p2/BRQ2n1p/3p2p1/3P4/5P1q/P1P2P2/1RK5 b - - 2 27"]
[Timezone "UTC"]
[ECO "D00"]
[ECOUrl "https://www.chess.com/openings/Queens-Pawn-Opening-1...d5-2.e3"]
[UTCDate "2025.09.23"]
[UTCTime "19:30:57"]
[WhiteElo "879"]
[BlackElo "884"]
[TimeControl "600"]
[Termination "nakubuo won by checkmate"]
[StartTime "19:30:57"]
[EndDate "2025.09.23"]
[EndTime "19:40:54"]
[Link "https://www.chess.com/analysis/game/live/143477930108/analysis?move=52"]
[WhiteUrl "https://www.chess.com/bundles/web/images/noavatar_l.84a92436.gif"]
[WhiteCountry "203"]
[WhiteTitle ""]
[BlackUrl "https://www.chess.com/bundles/web/images/noavatar_l.84a92436.gif"]
[BlackCountry "5"]
[BlackTitle ""]
1. d4 d5 2. e3 Nc6 3. Nf3 Bg4 4. Bd3 e5 5. h3 Bxf3 6. gxf3 exd4 7. exd4 Nxd4 8. Nc3 Bb4 9. Bd2 Qe7+ 10. Be3 Bxc3+ 11. bxc3 O-O-O 12. cxd4 Qb4+ 13. Qd2 Qb2 14. Ke2 Nf6 15. Rhb1 Qa3 16. Rb3 Qd6 17. Rab1 b6 18. Ba6+ Kb8 19. Bf4 Qe6+ 20. Kf1 Qxh3+ 21. Ke1 Rhe8+ 22. Kd1 h6 23. Kc1 g5 $6 24. Bxc7+ $3 Kxc7 25. Qc3+ $1 Kb8 $2 26. Rxb6+ $3 Ka8 $6 27. Qc6# 1-0''';

const String enPassantPGN = '1. d4 Nf6 2. d5 e5 3. dxe6';
const String bishopAmbigPGN =
    '1. d4 e5 {Opening: A40: Englund Gambit Complex} 2. dxe5 f6 3. exf6 gxf6 4. Nf3 Ne7 5. Nc3 Nd5 6. Nxd5 c6 7. Nxf6+ Kf7 8. Bh6 Bxh6 9. Ne5+ Kxf6 10. Qxd7 Bxd7 11. Nxd7+ Nxd7 12. Rd1 Ne5 13. e4 Qxd1+ 14. Kxd1 Ng4 15. Be2 Nxf2+ 16. Ke1 Nxh1 17. e5+ Kf7 18. e6+ Kf8 19. e7+ Kf7 20. e8B+ Kg7 21. Kf1 Rf8+ 22. Kg1 Rf1+ 23. Kxf1 Rd8 24. Ba6 Rd7 25. Kg1 Rd6 26. Kxh1 Bg5 27. Kg1 Rd2 28. Kf1 Rxg2 29. Ke1 Rxh2 30. Kd1 Rxc2 31. Ke1 Rxb2 32. Kd1 Rxa2 33. Ke1 Re2+ 34. Kxe2 Be3 35. Kxe3 Kf8 36. Bxb7 Kg8 37. Bexc6 a6 38. Bxa6 Kf8 39. Be4 Ke8 40. Bxh7 Kd8 41. Bad3';
