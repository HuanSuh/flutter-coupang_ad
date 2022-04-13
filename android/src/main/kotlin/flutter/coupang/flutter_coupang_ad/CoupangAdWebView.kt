package flutter.coupang.flutter_coupang_ad

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.webkit.*
import android.widget.RelativeLayout
import com.coupang.ads.impl.AdListener

@SuppressLint("ViewConstructor")
class CoupangAdWebView(context: Context, config: CoupangAdConfig, listener: AdListener): RelativeLayout(context) {
    private var webView: WebView? = null

    init {
        try {
            webView = with(WebView(context)) {
                settings.javaScriptEnabled = true
                webChromeClient = object: WebChromeClient() {
                    override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
                        when(consoleMessage?.messageLevel()) {
                            ConsoleMessage.MessageLevel.ERROR -> {
                                listener.onAdFailedToLoad(consoleMessage.message())
                            }
                            else -> {}
                        }
                        return super.onConsoleMessage(consoleMessage)
                    }
                }
                webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView?, url: String?) {
                        evaluateJavascript(
                                "(function() { return (document.getElementsByTagName('ins')[0].style.display); })();"
                        ) { display ->
                            if(display.contains("inline")) {
                                listener.onAdLoaded()
                            }
                        }
                    }

                    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                        val uri = request.url
                        val intent = Intent(Intent.ACTION_VIEW, request.url)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                        listener.onAdClicked()
                        return true
                    }
                }

                if (!config.htmlData.isNullOrEmpty()) {
                    loadData(config.htmlData, "text/html", "UTF-8")
                }

                return@with this
            }
        } catch (e: Exception) { /* ignore */ }
        addView(webView)
    }

    fun reload(data: String) {
        webView?.loadData(data, "text/html", "UTF-8")
    }

    fun dispose() {
        webView?.destroy()
    }

}