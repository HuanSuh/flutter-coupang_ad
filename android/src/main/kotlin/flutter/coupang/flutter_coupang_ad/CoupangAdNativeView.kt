package flutter.coupang.flutter_coupang_ad

import android.content.Context
import android.widget.RelativeLayout
import com.coupang.ads.impl.AdListener
import com.coupang.ads.view.banner.AdsBannerView

class CoupangAdNativeView(context: Context, config: CoupangAdConfig, listener: AdListener) : RelativeLayout(context) {
    private var adView: AdsBannerView? = AdsBannerView(context)

    init {
        adView?.setAdListener(listener)
        addView(adView)
        updateConfig(config)
    }

    fun updateConfig(config: CoupangAdConfig) {
        adView?.setAdSize(config.adSize)
        adView?.loadAdData(config.adId, affiliatePage = config.affiliatePage, affiliatePlacement = config.affiliatePlacement)
    }
}