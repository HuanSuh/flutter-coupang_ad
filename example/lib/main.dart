import 'package:flutter/material.dart';

import 'package:flutter_coupang_ad/flutter_coupang_ad.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: CoupangAdView(CoupangAdConfig(adId: '223812', height: 180)),
        ),
      ),
    );
  }
}
