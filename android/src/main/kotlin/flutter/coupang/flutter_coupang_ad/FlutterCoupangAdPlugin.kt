package flutter.coupang.flutter_coupang_ad

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterCoupangAdPlugin */
public class FlutterCoupangAdPlugin: FlutterPlugin {
  private lateinit var adViewFactory : AdViewFactory
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory = AdViewFactory.registerWith(flutterPluginBinding)
  }
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      AdViewFactory.registerWith(registrar)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory.onDestroy()
  }
}
