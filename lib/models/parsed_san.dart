import 'models.dart';

class ParsedSan {
  final PieceType pieceType;
  final Square destination;
  final bool isCapture;
  final int? fromFile;
  final int? fromRank;
  final PieceType? promotion;
  final bool isCastleKingSide;
  final bool isCastleQueenSide;

  ParsedSan({
    required this.pieceType,
    required this.destination,
    required this.isCapture,
    this.fromFile,
    this.fromRank,
    this.promotion,
    this.isCastleKingSide = false,
    this.isCastleQueenSide = false,
  });

  factory ParsedSan.fromString(String san) {
    // 1. Strip check, mate, annotations
    var s =
        san.replaceAll('+', '').replaceAll('#', '').replaceAll('!', '').replaceAll('?', '').trim();

    // 2. Castling
    if (s == 'O-O') {
      return ParsedSan(
        pieceType: PieceType.king,
        destination: Square.fromFileRank(6, 0), // resolved later
        isCapture: false,
        isCastleKingSide: true,
      );
    }

    if (s == 'O-O-O') {
      return ParsedSan(
        pieceType: PieceType.king,
        destination: Square.fromFileRank(2, 0),
        isCapture: false,
        isCastleQueenSide: true,
      );
    }

    // 3. Promotion (with or without '=')
    PieceType? promotion;
    final promoMatch = RegExp(r'(=)?([QRBN])$').firstMatch(s);
    if (promoMatch != null) {
      promotion = {
        'Q': PieceType.queen,
        'R': PieceType.rook,
        'B': PieceType.bishop,
        'N': PieceType.knight,
      }[promoMatch.group(2)!];

      s = s.substring(0, s.length - promoMatch.group(0)!.length);
    }

    // 4. Capture
    final isCapture = s.contains('x');
    s = s.replaceAll('x', '');

    // 5. Destination square (always last two chars now)
    if (s.length < 2) {
      throw StateError('Invalid SAN: $san');
    }

    final destFileChar = s[s.length - 2];
    final destRankChar = s[s.length - 1];

    final destFile = destFileChar.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final destRank = int.parse(destRankChar) - 1;

    final destination = Square.fromFileRank(destFile, destRank);
    s = s.substring(0, s.length - 2);

    // 6. Piece type
    PieceType pieceType = PieceType.pawn;
    if (s.isNotEmpty && RegExp(r'[KQRBN]').hasMatch(s[0])) {
      pieceType = {
        'K': PieceType.king,
        'Q': PieceType.queen,
        'R': PieceType.rook,
        'B': PieceType.bishop,
        'N': PieceType.knight,
      }[s[0]]!;
      s = s.substring(1);
    }

    // 7. Disambiguation
    int? fromFile;
    int? fromRank;

    if (s.length == 1) {
      if (RegExp(r'[a-h]').hasMatch(s)) {
        fromFile = s.codeUnitAt(0) - 'a'.codeUnitAt(0);
      } else if (RegExp(r'[1-8]').hasMatch(s)) {
        fromRank = int.parse(s) - 1;
      }
    } else if (s.length == 2) {
      fromFile = s.codeUnitAt(0) - 'a'.codeUnitAt(0);
      fromRank = int.parse(s[1]) - 1;
    }

    return ParsedSan(
      pieceType: pieceType,
      destination: destination,
      isCapture: isCapture,
      fromFile: fromFile,
      fromRank: fromRank,
      promotion: promotion,
    );
  }
}
