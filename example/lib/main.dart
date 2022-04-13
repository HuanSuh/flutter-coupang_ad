import 'package:flutter/material.dart';
import 'package:flutter_coupang_ad/flutter_coupang_ad.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterCoupangAd.init('<AFFILIATE_ID>', subId: '<SUB_ID>');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Coupang Ad')),
        body: Center(
          child: CoupangAdView(
            adId: '<AdID>',
            size: CoupangAdSize.banner,
            fillWidth: true,
            dynamicAd: true,
            listener: (event, data) {
              switch (event) {
                case CoupangAdEvent.onAdClicked:
                  break;
                case CoupangAdEvent.onAdLoaded:
                  break;
                case CoupangAdEvent.onAdFailedToLoad:
                case CoupangAdEvent.onError:
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
