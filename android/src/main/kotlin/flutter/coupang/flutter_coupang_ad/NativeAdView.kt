package flutter.coupang.flutter_coupang_ad

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.View
import android.webkit.*
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import org.json.JSONObject


@SuppressLint("SetJavaScriptEnabled")
class NativeAdView(private val context: Context, messenger: BinaryMessenger?, viewId: Int, arguments: Any)
    : PlatformView, EventChannel.StreamHandler, MethodCallHandler {
    private var webView: WebView? = null
    private var eventSink: EventSink? = null
    private var methodChannel: MethodChannel? = null

    init {
        try {
            methodChannel = with(MethodChannel(messenger,
                    "coupang_ad_view_$viewId")) {
                setMethodCallHandler(this@NativeAdView)
                return@with this
            }
            /* open an event channel */
            EventChannel(messenger, "coupang_ad_view_event_$viewId", JSONMethodCodec.INSTANCE).setStreamHandler(this)

            val args = arguments as JSONObject
            val htmlData = args.getString("data")
            webView = with(WebView(context)) {
                settings.javaScriptEnabled = true
                webChromeClient = object: WebChromeClient() {
                    override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
                        when(consoleMessage?.messageLevel()) {
                            ConsoleMessage.MessageLevel.ERROR -> {
                                callback("onAdFailedToLoad", consoleMessage.message())
                            }
                            else -> {}
                        }
                        return super.onConsoleMessage(consoleMessage)
                    }
                }
                webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView?, url: String?) {
                        evaluateJavascript(
                                "(function() { return (document.getElementsByTagName('ins')[0].style['display']); })();"
                        ) { display ->
                            if(display.contains("inline")) {
                                callback("onAdLoaded")
                            }
                        }
                    }

                    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                        val uri = request.url
                        val intent = Intent(Intent.ACTION_VIEW, request.url)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                        onLinkOpened(uri?.toString())
                        return true
                    }
                }

                if (htmlData.isNotEmpty()) {
                    loadData(htmlData, "text/html", "UTF-8")
                }

                return@with this
            }
        } catch (e: Exception) { /* ignore */ }
    }



    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "onDataChanged") {
            onDataChanged(call.arguments)
            result.success(true)
        } else {
            result.notImplemented()
        }
    }

    private fun onDataChanged(arguments: Any) {
        try {
            if (arguments is HashMap<*, *>) {
                val htmlData = arguments["data"].toString()
                if (htmlData.isNotEmpty()) {
                    webView?.loadData(htmlData, "text/html", "UTF-8")
                }
            }
        } catch (e: Exception) {
            onError(e.message)
        }
    }

    private fun onLinkOpened(url: String?) {
        callback("onAdClicked", url)
    }

    private fun onError(errorMessage: String?) {
        callback("onError", errorMessage)
    }

    private fun callback(event: String) {
        callback(event, null)
    }
    private fun callback(event: String, message: String?) {
        val data = JSONObject()
        data.put("event", event)
        if(!message.isNullOrEmpty()) {
            data.put("message", message)
        }
        eventSink?.success(data)
    }

    override fun getView(): View {
        return webView!!
    }

    override fun dispose() {
        webView?.destroy()
        methodChannel?.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
