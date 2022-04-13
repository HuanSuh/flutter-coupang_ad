package flutter.coupang.flutter_coupang_ad

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.View
import android.webkit.*
import android.widget.RelativeLayout
import com.coupang.ads.impl.AdListener
import com.google.gson.Gson
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import org.json.JSONObject


@SuppressLint("SetJavaScriptEnabled")
class CoupangAdView(private val context: Context, messenger: BinaryMessenger?, viewId: Int, arguments: Any)
    : PlatformView, EventChannel.StreamHandler, MethodCallHandler, AdListener {
    private var webView: CoupangAdWebView? = null
    private var nativeView: CoupangAdNativeView? = null
    private var nativeLoadFailed: Boolean = false
    private var eventSink: EventSink? = null
    private var methodChannel: MethodChannel? = null

    init {
        try {
            methodChannel = with(MethodChannel(messenger,
                    "coupang_ad_view_$viewId")) {
                setMethodCallHandler(this@CoupangAdView)
                return@with this
            }
            /* open an event channel */
            EventChannel(messenger, "coupang_ad_view_event_$viewId", JSONMethodCodec.INSTANCE).setStreamHandler(this)

            onDataChanged(arguments)
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
            val jsonObject = if(arguments is JSONObject) {
                arguments
            } else {
                JSONObject(Gson().toJson(arguments))
            }
            val config: CoupangAdConfig = CoupangAdConfig.fromMap(jsonObject)
            Log.d("COUPANG_AD", config.toString() + "${jsonObject.javaClass}")
            if(config.useSDKView && !nativeLoadFailed) {
                if(nativeView == null) {
                    nativeView = CoupangAdNativeView(context, config, listener = object: AdListener {
                        override fun onAdClicked() {
                            this@CoupangAdView.onAdClicked()
                        }
                        override fun onAdFailedToLoad(errorMessage: String?) {
                            nativeLoadFailed = true
                            onDataChanged(arguments)
                            this@CoupangAdView.onAdFailedToLoad(errorMessage)
                        }
                        override fun onAdLoaded() {
                            nativeLoadFailed = false
                            this@CoupangAdView.onAdLoaded()
                        }
                    })
                } else {
                    nativeView?.updateConfig(config)
                }
            } else {
                nativeView = null
            }
            if (!config.htmlData.isNullOrEmpty()) {
                if(webView == null) {
                    webView = CoupangAdWebView(context, config, listener = this)
                } else {
                    webView?.reload(config.htmlData)
                }
            }
        } catch (e: Exception) {
            onError(e.message)
        }
    }

    override fun onAdLoaded() {
        callback("onAdLoaded")
    }

    override fun onAdFailedToLoad(errorMessage: String?) {
        callback("onAdFailedToLoad", errorMessage)
    }

    override fun onAdClicked() {
        callback("onAdClicked")
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
        return nativeView ?: webView ?: RelativeLayout(context)
    }

    override fun dispose() {
        webView?.dispose()
        methodChannel?.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
