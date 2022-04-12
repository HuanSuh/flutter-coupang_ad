part of flutter_coupang_ad;

/// [CoupangAdEvent] callback
typedef OnCoupangAdEvent = Function(CoupangAdEvent event, CoupangAdEventData data);

/// [OnCoupangAdEvent] callback 에 사용되는 event type
enum CoupangAdEvent {
  /// 배너 광고 클릭 시
  onAdClicked,

  /// 배너 광고 노출 완료 시
  onAdLoaded,

  /// 배너 광고 노출 실패 시 (CoupangAdSDK 에러 메시지)
  onAdFailedToLoad,

  /// 패키지 내부에서 에러 발생 시
  onError,
}

/// [OnCoupangAdEvent] callback 에 사용되는 event data
class CoupangAdEventData {
  /// Event type
  final CoupangAdEvent? _event;

  /// 호출된 ad Id
  final String? adId;

  /// Event message
  final String? message;

  /// Default constructor
  CoupangAdEventData._(this._event, {this.adId, this.message});

  factory CoupangAdEventData._build(String adId, dynamic data) {
    CoupangAdEvent event;
    if (data is Map<String, dynamic>) {
      String eventName = data["event"];
      switch (eventName) {
        case "onAdLoaded":
          event = CoupangAdEvent.onAdLoaded;
          break;
        case "onAdClicked":
          event = CoupangAdEvent.onAdClicked;
          break;
        case "onAdFailedToLoad":
          event = CoupangAdEvent.onAdFailedToLoad;
          break;
        case "onError":
          event = CoupangAdEvent.onError;
          break;
        default:
          return CoupangAdEventData._(null);
      }
      return CoupangAdEventData._(
        event,
        adId: adId,
        message: data["message"],
      );
    }
    return CoupangAdEventData._(null);
  }

  @override
  String toString() {
    return 'AdFitEventData{event: $_event, adId: $adId, message: $message}';
  }
}
