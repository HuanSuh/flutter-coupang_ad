library flutter_coupang_ad;

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'src/coupang_ad_size.dart';
part 'src/coupang_ad_event.dart';
part 'src/coupang_ad_view.dart';

class FlutterCoupangAd {
  static const MethodChannel _channel = MethodChannel('flutter_coupang_ad');

  static bool _sdkInitialized = false;
  static String? _affiliateId;
  static String? _subId;

  /// Initialize CoupangAdPlugIn for native SDK
  /// - Android : https://github.com/coupang-ads-sdk/android/blob/main/coupang-ads-sdk-v1.0.1.pdf
  /// - iOS : not implemented
  static Future<Map?> init(String affiliateId, {String? subId}) {
    _affiliateId = affiliateId;
    _subId = subId;
    if (_sdkInitialized) {
      return Future.value({'affiliateId': _affiliateId, 'subId': _subId});
    }
    if (Platform.isAndroid) {
      return _channel.invokeMethod<Map>('_init', {
        'affiliateId': affiliateId,
        'subId': subId,
      }).then((result) {
        _sdkInitialized = true;
        _affiliateId = result?['affiliateId'] as String?;
        _subId = result?['subId'] as String?;
        debugPrint('CoupangAdSDK initialized with ${result?.toString()}');
        return result;
      });
    }
    return Future.value();
  }
}
