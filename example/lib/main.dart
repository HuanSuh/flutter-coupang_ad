import 'package:flutter/material.dart';
import 'package:flutter_coupang_ad/flutter_coupang_ad.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterCoupangAd.init('AF2693277', subId: 'dfhowmuch');
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
        backgroundColor: Colors.red,
        appBar: AppBar(title: const Text('Flutter Coupang Ad')),
        body: Center(
          child: CoupangAdView(
            adId: '575249',
            size: CoupangAdSize.banner,
            fillWidth: true,
            listener: (event, data) {
              print('$event : ${data.toString()}');
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
