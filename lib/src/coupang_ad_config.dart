part of flutter_coupang_ad;

class CoupangAdConfig {
  final String adId;
  final double height; // default : 80px
  final double? width;

  const CoupangAdConfig({
    required this.adId,
    this.height = 80,
    this.width,
  });
}
