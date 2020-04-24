import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CoupangAdConfig {
  final String adId;
  final double height;
  final double width;

  const CoupangAdConfig({
    @required this.adId,
    @required this.height,
    this.width,
  });
}

class CoupangAdView extends StatefulWidget {
  final String adId;
  final double height; // default : 80px
  final double width;

  CoupangAdView(CoupangAdConfig config)
      : this.adId = config?.adId,
        this.height = config?.height,
        this.width = config?.width,
        assert(config?.adId?.isNotEmpty == true);

  @override
  _CoupangAdViewState createState() => _CoupangAdViewState();
}

class _CoupangAdViewState extends State<CoupangAdView> {
  MethodChannel _channel;

  @override
  void didUpdateWidget(CoupangAdView oldWidget) {
    if (oldWidget.adId != widget.adId) {
      _onDataChanged(widget.adId);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onDataChanged(String adId) {
    _channel?.invokeMethod(
        "onDataChanged", {"data": _constructHTMLData(adId, widget.height)});
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return Container(
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
        EventChannel("coupang_ad_view_event_$viewId", JSONMethodCodec());
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
    String cleanHTML = '<div style="height: ${(height ?? 80).toInt()}px;">' +
        '<script src="https://ads-partners.coupang.com/g.js"></script>' +
        '<script> new PartnersCoupang.G({ id: $adId });</script>' +
        '</div>';
    return "<html><header>" +
        "<meta name='viewport' content='width=device-width, " +
        "initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>" +
        "</header><body>" +
        cleanHTML +
        "</body></html>";
  }
}
