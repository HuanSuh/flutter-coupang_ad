package flutter.coupang.flutter_coupang_ad

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.coupang.ads.CoupangAds
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*

/** FlutterCoupangAdPlugin */
public class FlutterCoupangAdPlugin: FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
  private lateinit var adViewFactory : AdViewFactory
  private var instanceManager: InstanceManager? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory = AdViewFactory.registerWith(flutterPluginBinding)

    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_coupang_ad")
    channel.setMethodCallHandler(this)
    instanceManager = InstanceManager(channel)
  }
  companion object {
    const val TAG = "FlutterCoupangAdPlugin"

    @JvmStatic
    fun registerWith(registrar: PluginRegistry.Registrar) {
      AdViewFactory.registerWith(registrar)
    }
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory.onDestroy()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    instanceManager?.setActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    instanceManager?.setActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    instanceManager?.setActivity(binding.activity)
  }

  override fun onDetachedFromActivity() {
    instanceManager?.setActivity(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    if (instanceManager == null) {
      Log.e(TAG, "method call received before instanceManager initialized: " + call.method)
      return
    }
    // Use activity as context if available.
    val context: Context? = instanceManager!!.getActivity()
    if (call.method == "_init") {
      try {
        if(context == null) {
          result.error("-2", "context is null", "context is null")
          return
        }
        call.argument<String>("affiliateId")?.let{ affiliateId ->
          Log.d(TAG, call.arguments.toString())
          if(affiliateId.isEmpty()) {
            result.error("1", "affiliateId is empty", "affiliateId is empty")
            return
          }
          val subId: String? = call.argument<String?>("subId")
          val coupangAds = CoupangAds.init(context, affiliateId, subId = subId)
          result.success(mapOf(
                  "affiliateId" to coupangAds.affiliateId,
                  "subId" to coupangAds.subId,
                  "versionCode" to coupangAds.versionCode,
                  "versionName" to coupangAds.versionName,
          ))
        }.run {
          result.error("0", "affiliateId is null", "affiliateId is null")
          return
        }
      } catch (e: Exception) {
        result.error("-1", e.message, e.localizedMessage)
      }
    } else {
      result.notImplemented()
    }
  }
}
