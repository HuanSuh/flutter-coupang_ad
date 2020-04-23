package flutter.coupang.flutter_coupang_ad

import android.content.Context
import flutter.coupang.flutter_coupang_ad.NativeAdView
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformViewFactory

class AdViewFactory
    private constructor(private val messenger: BinaryMessenger, private val context: Context)
    : PlatformViewFactory(JSONMessageCodec.INSTANCE) {
    private var webView: NativeAdView? = null
    override fun create(context: Context, id: Int, args: Any): NativeAdView? {
        webView = NativeAdView(context, messenger, id, args)
        return webView
    }

    fun onDestroy() {
        webView?.dispose()
    }

    companion object {
        /**
         * Flutter Android v1 API (using Registrar)
         */
        fun registerWith(registrar: Registrar): AdViewFactory {
            val plugin = AdViewFactory(registrar.messenger(), registrar.activity())
            registrar.platformViewRegistry().registerViewFactory("flutter.coupang.ad/CoupangAdView", plugin)
            registrar.addViewDestroyListener {
                plugin.onDestroy()
                false
            }
            return plugin
        }

        /**
         * Flutter Android v2 API (using FlutterPluginBinding)
         */
        fun registerWith(flutterPluginBinding: FlutterPluginBinding): AdViewFactory {
            val plugin = AdViewFactory(flutterPluginBinding.binaryMessenger,
                    flutterPluginBinding.applicationContext)
            flutterPluginBinding.platformViewRegistry.registerViewFactory(
                    "flutter.coupang.ad/CoupangAdView", plugin)
            return plugin
        }
    }

}
