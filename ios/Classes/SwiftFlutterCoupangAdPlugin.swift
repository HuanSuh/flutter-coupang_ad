import Flutter
import UIKit

public class SwiftFlutterCoupangAdPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_coupang_ad", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterCoupangAdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    AdViewFactory.register(with: registrar)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
