package flutter.coupang.flutter_coupang_ad

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.View
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import org.json.JSONException
import org.json.JSONObject
import java.util.*


class NativeAdView(private val context: Context?, messenger: BinaryMessenger?, viewId: Int, arguments: Any)
    : PlatformView, EventChannel.StreamHandler, MethodCallHandler {
    private var webView: WebView? = null
    private var eventSink: EventSink? = null
    private var methodChannel: MethodChannel? = null

    init {
        try {
            val args = arguments as JSONObject
            val htmlData = args.getString("data")
            webView = with(WebView(context)) {
                settings.javaScriptEnabled = true
                webViewClient = object : WebViewClient() {
                    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                        val uri = request.url
                        val intent = Intent(Intent.ACTION_VIEW, request.url)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                        onLinkOpened(uri.toString())
                        return true
                    }
                }

                if (htmlData != null && htmlData.isNotEmpty()) {
                    loadData(htmlData, "text/html", "UTF-8")
                }
                return@with this
            }
            methodChannel = with(MethodChannel(messenger,
                    "coupang_ad_view_$viewId")) {
                setMethodCallHandler(this@NativeAdView)
                return@with this
            }
            /* open an event channel */
            EventChannel(messenger, "coupang_ad_view_event_$viewId", JSONMethodCodec.INSTANCE).setStreamHandler(this)
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
                val args = arguments as HashMap<String, Any>
                val htmlData = args["data"].toString()
                if (htmlData.isNotEmpty()) {
                    webView?.loadData(htmlData, "text/html", "UTF-8")
                }
            }
        } catch (e: Exception) {
            onError(e.message)
        }
    }

    private fun onLinkOpened(url: String) {
        try {
            val message = JSONObject()
            message.put("event", "onLinkOpened")
            message.put("url", url)
            eventSink?.success(message)
        } catch (e: JSONException) {
            onError(e.message)
        }
    }

    private fun onError(errorMessage: String?) {
        try {
            val message = JSONObject()
            message.put("event", "onError")
            message.put("message", errorMessage)
            eventSink?.success(message)
        } catch (e: JSONException) { /* ignore */ }
    }

    override fun getView(): View {
        return webView!!
    }

    override fun dispose() {
        webView?.destroy()
        methodChannel?.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any, events: EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any) {
        eventSink = null
    }
}
