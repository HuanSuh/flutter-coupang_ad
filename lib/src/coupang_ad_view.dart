part of flutter_coupang_ad;

class CoupangAdView extends StatefulWidget {
  final String adId;
  final double height;
  final double? width;

  CoupangAdView(CoupangAdConfig config, {Key? key})
      : adId = config.adId,
        height = config.height,
        width = config.width,
        assert(config.adId.isNotEmpty == true),
        super(key: key);

  @override
  _CoupangAdViewState createState() => _CoupangAdViewState();
}

class _CoupangAdViewState extends State<CoupangAdView> {
  late MethodChannel _channel;

  @override
  void didUpdateWidget(CoupangAdView oldWidget) {
    if (oldWidget.adId != widget.adId) {
      _onDataChanged(widget.adId);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onDataChanged(String adId) {
    _channel.invokeMethod(
        "onDataChanged", {"data": _constructHTMLData(adId, widget.height)});
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: _buildAdView(),
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
        creationParams: {
          "data": _constructHTMLData(widget.adId, widget.height),
        },
        creationParamsCodec: const JSONMessageCodec(),
        onPlatformViewCreated: (viewId) => _onPlatformViewCreated(viewId),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: 'flutter.coupang.ad/CoupangAdView',
        creationParams: {
          "data": _constructHTMLData(widget.adId, widget.height),
        },
        creationParamsCodec: const JSONMessageCodec(),
        onPlatformViewCreated: (viewId) => _onPlatformViewCreated(viewId),
      );
    }
    return Container();
  }

  void _onPlatformViewCreated(int viewId) {
    _channel = MethodChannel('coupang_ad_view_$viewId');
    _listenForNativeEvents(viewId);
  }

  void _listenForNativeEvents(int viewId) {
    EventChannel eventChannel =
        EventChannel("coupang_ad_view_event_$viewId", const JSONMethodCodec());
    eventChannel.receiveBroadcastStream().listen(_processNativeEvent);
  }

  void _processNativeEvent(dynamic event) async {
    if (event is Map) {
      String eventName = event["event"];
      switch (eventName) {
        case "onLinkOpened":
          break;
        case "onError":
          break;
        default:
          break;
      }
    }
  }

  String _constructHTMLData(String adId, double height) {
    String cleanHTML = '<div style="height: ${height.toInt()}px;">'
        '<script src="https://ads-partners.coupang.com/g.js"></script>'
        '<script> new PartnersCoupang.G({ id: $adId });</script>'
        '</div>';
    return "<html><header>"
        "<meta name='viewport' content='width=device-width, "
        "initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>"
        "</header><body>$cleanHTML</body></html>";
  }
}
