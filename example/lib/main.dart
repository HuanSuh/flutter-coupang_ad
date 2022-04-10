import 'package:flutter/material.dart';
import 'package:flutter_coupang_ad/flutter_coupang_ad.dart';

void main() {
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
            const CoupangAdConfig(adId: '223812', height: 180),
          ),
        ),
      ),
    );
  }
}
