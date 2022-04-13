part of flutter_coupang_ad;

class CoupangAdView extends StatefulWidget {
  final String adId;
  final CoupangAdSize size;
  final OnCoupangAdEvent? listener;
  final bool fillWidth;
  final bool dynamicAd;

  const CoupangAdView({
    required this.adId,
    this.size = CoupangAdSize.smart,
    this.listener,
    this.fillWidth = false,
    this.dynamicAd = true,
    Key? key,
  }) : super(key: key);

  @override
  _CoupangAdViewState createState() => _CoupangAdViewState();
}

class _CoupangAdViewState extends State<CoupangAdView> {
  late MethodChannel _channel;
  bool _initialized = false;
  bool _hasError = false;
  set hasError(bool value) {
    if (_hasError != value) {
      Future.microtask(() => setState(() => _hasError = value));
    }
  }

  @override
  void didUpdateWidget(CoupangAdView oldWidget) {
    if (oldWidget.adId != widget.adId ||
        oldWidget.fillWidth != widget.fillWidth ||
        oldWidget.size.width != widget.size.width ||
        oldWidget.size.height != widget.size.height ||
        oldWidget.dynamicAd != widget.dynamicAd) {
      _onDataChanged(widget.adId);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onDataChanged(String adId) {
    hasError = false;
    _channel.invokeMethod("onDataChanged", _buildParams(adId));
  }

  double _bannerWidth = 0, _bannerHeight = 0;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return LayoutBuilder(
        builder: (_, layout) {
          double maxWidth =
              min(MediaQuery.of(context).size.width, layout.maxWidth);
          double width = widget.size.width;
          double height = widget.size.height;
          if (width < 0) {
            width = maxWidth;
          }
          if (height < 0) {
            height = CoupangAdSize._calcHeightFromWidth(width);
          }
          double scale = widget.fillWidth ? maxWidth / width : 1.0;
          width *= scale;
          height *= scale;
          if (width != _bannerWidth || height != _bannerHeight) {
            _bannerWidth = width;
            _bannerHeight = height;
            if (_initialized) {
              _onDataChanged(widget.adId);
            }
          }
          return SizedBox(
            width: width,
            height: height,
            child: _buildAdView(),
          );
        },
      );
    }
    debugPrint(
      'coupang_ad_view package only support for Andoid and IOS.\n'
      'Current platform is ${Platform.operatingSystem}',
    );
    return Container();
  }

  Widget _buildAdView() {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'flutter.coupang.ad/CoupangAdView',
        creationParams: _buildParams(widget.adId),
        creationParamsCodec: const JSONMessageCodec(),
        onPlatformViewCreated: (viewId) => _onPlatformViewCreated(viewId),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: 'flutter.coupang.ad/CoupangAdView',
        creationParams: _buildParams(widget.adId),
        creationParamsCodec: const JSONMessageCodec(),
        onPlatformViewCreated: (viewId) => _onPlatformViewCreated(viewId),
      );
    }
    return Container();
  }

  void _onPlatformViewCreated(int viewId) {
    _initialized = true;
    _channel = MethodChannel('coupang_ad_view_$viewId');
    _listenForNativeEvents(viewId);
  }

  void _listenForNativeEvents(int viewId) {
    EventChannel eventChannel =
        EventChannel("coupang_ad_view_event_$viewId", const JSONMethodCodec());
    eventChannel.receiveBroadcastStream().listen(_processNativeEvent);
  }

  void _processNativeEvent(Object? data) async {
    CoupangAdEventData event = CoupangAdEventData._build(widget.adId, data);
    switch (event._event) {
      case CoupangAdEvent.onAdClicked:
        break;
      case CoupangAdEvent.onAdLoaded:
        break;
      case CoupangAdEvent.onAdFailedToLoad:
        hasError = true;
        break;
      case CoupangAdEvent.onError:
        break;
      case null:
        break;
    }
    if (event._event != null) {
      widget.listener?.call(event._event!, event);
    }
  }

  Map<String, dynamic> _buildParams(String adId) {
    double width = _bannerWidth;
    double height = _bannerHeight;
    if (Platform.isIOS) {
      width *= MediaQuery.of(context).devicePixelRatio;
      height *= MediaQuery.of(context).devicePixelRatio;
    }
    return {
      'adId': adId,
      'width': width.toInt(),
      'height': height.toInt(),
      'useSDKView': FlutterCoupangAd._sdkInitialized && widget.dynamicAd,
      'data': _constructHTMLData(adId, width, height),
    };
  }

  String _constructHTMLData(String adId, double width, double height) {
    String cleanHTML =
        '<script src="https://ads-partners.coupang.com/g.js"></script>'
        '<script>new PartnersCoupang.G({'
        '"id":$adId,'
        '"template":"carousel",'
        '"trackingCode": "${FlutterCoupangAd._affiliateId}",'
        '"subId": "${FlutterCoupangAd._subId}",'
        '"width":"${width.toInt()}",'
        '"height":"${height.toInt()}"'
        '});</script>';
    return "<body style='margin: 0px;'>$cleanHTML</body>";
  }
}
