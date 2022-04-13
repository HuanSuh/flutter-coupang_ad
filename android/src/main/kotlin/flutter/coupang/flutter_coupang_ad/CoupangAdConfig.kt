package flutter.coupang.flutter_coupang_ad

import com.coupang.ads.config.AdSize
import org.json.JSONObject
import java.lang.Exception

class CoupangAdConfig(
        val adId: Long,
        val width: Int?,
        val height: Int?,
        val useSDKView: Boolean,
        val htmlData: String?,
        val affiliatePage: String?,
        val affiliatePlacement: String?) {

    companion object {
        fun fromMap(args: JSONObject): CoupangAdConfig {
            val adId = try { args.getLong("adId") } catch (e: Exception) { -1 }
            val width = try { args.getInt("width") } catch (e: Exception) { -1 }
            val height = try { args.getInt("height") } catch (e: Exception) { -1 }
            val useSDKView = try { args.getBoolean("useSDKView") } catch (e: Exception) { false }
            val htmlData = try { args.getString("data") } catch (e:Exception) { null }
            val affiliatePage = try { args.getString("affiliatePage") } catch (e:Exception) { null }
            val affiliatePlacement = try { args.getString("affiliatePlacement") } catch (e:Exception) { null }
            return CoupangAdConfig(
                    adId = adId,
                    width = width,
                    height = height,
                    useSDKView = useSDKView,
                    htmlData = htmlData,
                    affiliatePage = affiliatePage,
                    affiliatePlacement = affiliatePlacement,
            )
        }
    }

    override fun toString(): String {
        return "CoupangAdConfig(adId=$adId, width=$width, height=$height, useSDKView=$useSDKView, htmlData=$htmlData, affiliatePage=$affiliatePage, affiliatePlacement=$affiliatePlacement)"
    }

    val adSize: Int
        get() {
            if(width == 320 && height == 50) {
                return AdSize.BANNER_320X50
            } else if(width == 320 && height == 100) {
                return AdSize.LARGE_BANNER_320X100
            } else if (width == 300 && height == 250) {
                return AdSize.MEDIUM_RECTANGLE_300X250
            }
            return AdSize.SMART_BANNER_WIDTH
        }


}