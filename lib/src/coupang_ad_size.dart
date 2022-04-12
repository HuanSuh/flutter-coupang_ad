part of flutter_coupang_ad;

class CoupangAdSize {
  final double width;
  final double height;

  const CoupangAdSize({
    required this.width,
    required this.height,
  });

  /// The standard banner (320x50) size.
  static const CoupangAdSize banner = CoupangAdSize(width: 320, height: 50);

  /// The large banner (320x100) size.
  static const CoupangAdSize largeBanner =
  CoupangAdSize(width: 320, height: 100);

  /// The medium rectangle (300x250) size.
  static const CoupangAdSize mediumRectangle =
  CoupangAdSize(width: 300, height: 250);

  /// The smart banner (468x60) size.
  /// (width <= 400) x 32
  /// (width <= 720) x 50
  /// (width >  720) x 90
  static const CoupangAdSize smart = CoupangAdSize(width: -1, height: -1);

  static double _calcHeightFromWidth(double width) {
    if (width <= 0) return 0;
    if (width <= 400) return 32;
    if (width <= 720) return 50;
    return 90;
  }
}