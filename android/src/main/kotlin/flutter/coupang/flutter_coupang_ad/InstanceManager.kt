package flutter.coupang.flutter_coupang_ad

import android.app.Activity
import io.flutter.plugin.common.MethodChannel

class InstanceManager(private val channel: MethodChannel) {
    private var activity: Activity? = null
    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    fun getActivity(): Activity? {
        return activity
    }
}