import Foundation
import WebKit

class AdViewFactory: NSObject, FlutterPlatformViewFactory {
    
    var nativeAdView:NativeAdView?
    var registrar:FlutterPluginRegistrar?
    private var messenger:FlutterBinaryMessenger
    
    /* register video player */
    static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = AdViewFactory(messenger: registrar.messenger())
        plugin.registrar = registrar
        registrar.register(plugin, withId: "flutter.coupang.ad/CoupangAdView")
    }
    
    init(messenger:FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        self.nativeAdView = NativeAdView(frame: frame, viewId: viewId, messenger: messenger, args: args)
        self.registrar?.addApplicationDelegate(self.nativeAdView!)
        return self.nativeAdView!
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterJSONMessageCodec()
    }
    
    public func applicationDidEnterBackground() {}
    public func applicationWillEnterForeground() {}
}

class NativeAdView: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterPlatformView, WKNavigationDelegate, WKUIDelegate {
    
    static func register(with registrar: FlutterPluginRegistrar) { }
    
    /* view specific properties */
    var frame:CGRect
    var viewId:Int64
    
    /* Flutter event streamer properties */
    private var eventChannel:FlutterEventChannel?
    private var flutterEventSink:FlutterEventSink?
    
    private var nativeWebView:WKWebView?
    private var htmlData:String
    
    deinit {
        print("[dealloc] coupang_ad_view")
    }
    
    init(frame:CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        /* set view properties */
        self.frame = frame
        self.viewId = viewId
        
        /* data as JSON */
        let parsedData = args as! [String: Any]

        /* set incoming html data */
        self.htmlData = parsedData["data"] as! String
        super.init()
        setupEventChannel(viewId: viewId, messenger: messenger, instance: self)
        setupMethodChannel(viewId: viewId, messenger: messenger)
    }
    
    /* set Flutter event channel */
    private func setupEventChannel(viewId: Int64, messenger:FlutterBinaryMessenger, instance:NativeAdView) {
        /* register for Flutter event channel */
        instance.eventChannel = FlutterEventChannel(name: "coupang_ad_view_event_" + String(viewId), binaryMessenger: messenger, codec: FlutterJSONMethodCodec.sharedInstance())
        instance.eventChannel!.setStreamHandler(instance)
    }
    
    /* set Flutter method channel */
    private func setupMethodChannel(viewId: Int64, messenger:FlutterBinaryMessenger) {
        
        let nativeMethodsChannel = FlutterMethodChannel(name: "coupang_ad_view_" + String(viewId), binaryMessenger: messenger);
        nativeMethodsChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if ("onDataChanged" == call.method) {
                /* data as JSON */
                let parsedData = call.arguments as! [String: Any]
                /* set incoming html data properties */
                let data = parsedData["data"] as! String
                self.onDataChanged(data: data)
            }
                
            /* not implemented yet */
            else { result(FlutterMethodNotImplemented) }
        })
    }
    
    /* create html native view */
    func view() -> UIView {
        self.nativeWebView = WKWebView()
        nativeWebView!.backgroundColor = UIColor.clear
        nativeWebView!.loadHTMLString(self.htmlData, baseURL: nil)
        self.nativeWebView?.navigationDelegate = self
        self.nativeWebView?.uiDelegate = self
        return nativeWebView!
    }
    
    func onDataChanged(data:String) {
        self.nativeWebView?.loadHTMLString(data, baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
 
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            if url.description.lowercased().range(of: "http://") != nil || url.description.lowercased().range(of: "https://") != nil {
                UIApplication.shared.openURL(url)
//                onLinkOpened(url: url.absoluteString)
            }
        }
        return nil
    }
 
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
 
    func webViewDidClose(_ webView: WKWebView) {
 
    }
 
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
 
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if(navigationAction.navigationType == WKNavigationType.linkActivated) {
            if let url = navigationAction.request.url {
                if (url.absoluteString.starts(with: "http")) {
                    //onLinkOpened(url: url.absoluteString)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func onLinkOpened(url:String) -> Void {
        self.flutterEventSink?(["event":"onLinkOpened", "url": url])
    }
    
    func onError(message:String) -> Void {
        self.flutterEventSink?(["event":"onError", "message": message])
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        flutterEventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        flutterEventSink = nil
        return nil
    }
    
    /**
     detach player UI to keep audio playing in background
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    /**
     reattach player UI as app is in foreground now
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
}
