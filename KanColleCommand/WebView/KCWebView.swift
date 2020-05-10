import Foundation
import WebKit
import SnapKit
import ScreenType

class KCWebView: WKWebView, WKNavigationDelegate {

    func setup(parent: UIView) {
        parent.addSubview(self)
        if (UIScreen.current == .iPhone5_5) {
            self.snp.makeConstraints { maker in
                maker.width.equalTo(parent.snp.width).inset(40)
                maker.height.equalTo(self.snp.width).inset(131.2)
                maker.top.equalTo(parent.snp.top)
                maker.centerX.equalTo(parent.snp.centerX)
            }
        } else if (UIScreen.current == .iPhone4_7) {
            self.snp.makeConstraints { maker in
                maker.width.equalTo(parent.snp.width).inset(40)
                maker.height.equalTo(self.snp.width).inset(117.5)
                maker.top.equalTo(parent.snp.top)
                maker.centerX.equalTo(parent.snp.centerX)
            }
        } else if (UIScreen.current == .iPhone4_0) {
            self.snp.makeConstraints { maker in
                maker.width.equalTo(parent.snp.width).inset(40)
                maker.height.equalTo(self.snp.width).inset(97.5)
                maker.top.equalTo(parent.snp.top)
                maker.centerX.equalTo(parent.snp.centerX)
            }
        } else {
            self.snp.makeConstraints { maker in
                maker.height.equalTo(parent.snp.height).inset(10.5)
                maker.width.equalTo(parent.snp.width).inset(40)
                maker.top.equalTo(parent)
                maker.centerX.equalTo(parent)
                maker.centerY.equalTo(parent.snp.centerY)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(gameStart), name: Constants.START_EVENT, object: nil)
        //self.mediaPlaybackRequiresUserAction = false
        //self.delegate = self
    }

    func load() {
        let url = URL(string: "about:blank")
        load(URLRequest(url: url!))
        loadCookie()
    }
    

    func loadBlankPage() {
        let url = URL(string: "about:blank")
        load(URLRequest(url: url!))
    }
    
    func saveCookie() {
        let cookieJar: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: cookies)
            let ud: UserDefaults = UserDefaults.standard
            ud.set(data, forKey: "cookie")
        }
    }

    func loadCookie() {
        let ud: UserDefaults = UserDefaults.standard
        let data: Data? = ud.object(forKey: "cookie") as? Data
        if let cookie = data {
            let datas: NSArray? = NSKeyedUnarchiver.unarchiveObject(with: cookie) as? NSArray
            if let cookies = datas {
                for c in cookies {
                    if let cookieObject = c as? HTTPCookie {
                        HTTPCookieStorage.shared.setCookie(cookieObject)
                    }
                }
            }
        }
    }

    @objc private func gameStart(n: Notification) {
        OperationQueue.main.addOperation {
            //self.stringByEvaluatingJavaScript(from: Constants.FULL_SCREEN_SCRIPT)
            self.evaluateJavaScript(Constants.FULL_SCREEN_SCRIPT)
            if (UIScreen.current <= .iPhone6_5) {
            //self.stringByEvaluatingJavaScript(from: Constants.darkBG)
                self.evaluateJavaScript(Constants.darkBG)
            }
        }
    }
    
    private var isConnectedToVpn: Bool {
        if let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? Dictionary<String, Any>,
            let scopes = settings["__SCOPED__"] as? [String:Any] {
            for (key, _) in scopes {
             if key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") {
                    return true
                }
            }
        }
        return false
    }
}


extension KCWebView: WKUIDelegate {

    public func webView(_ webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, request: URLRequest) -> Bool {
        if (request.url?.scheme == "kcwebview") {
            if let params = request.url?.query {
                do {
                    let decoded = params.removingPercentEncoding!
                            .replacingOccurrences(of: "\\n", with: "")
                            .replacingOccurrences(of: " ", with: "")
                    let jsonData = decoded.data(using: .utf8)!
                    let dic = try JSONSerialization.jsonObject(with: jsonData) as? [String: String]
                    let url: String = dic?["url"] ?? ""
                    let header: String = dic?["request"] ?? ""
                    let body: String = dic?["response"] ?? ""
                    if (url.contains("kcsapi")) {
                        print(url)
                        print(header)
                        print(body)
                        Oyodo.attention().api(url: url, request: header, response: body.replacingOccurrences(of: "svdata=", with: ""))
                    }
                } catch {
                    print("[Error] Error parse response")
                }
            }
            return false
        }
        webView.navigationDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        //WKPreferences().javaScriptEnabled = true
        //WKWebViewConfiguration().preferences = WKPreferences()
        return true
    }

    public func didStartProvisionalNavigation(_ webView: WKWebView, request: URLRequest) {

    }
    
    public func didFinishProvisionalNavigation(_ webView: WKWebView ,request: URLRequest) {
        //OperationQueue.main.addOperation {
            //self.stringByEvaluatingJavaScript(from: Constants.DMM_COOKIES)
        //}
        let url1 = URL(string: "http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/")
        let url2 = URL(string: "http://ooi.moe/poi")
        let url3 = URL(string: "http://kancolle.su/poi")
        if webView.url == url1 {
            if(UIScreen.current < .iPad9_7){
                self.scrollView.minimumZoomScale = 1.0
                self.scrollView.maximumZoomScale = 1.0
                self.scrollView.zoomScale = 1.0
            } else {
                print("Using iPad, nothing needs to be modified.")
            }
        } else if webView.url == url2 {
            print("Using non official login method, the screen zoom scale needs to be changed.")
            if (UIScreen.current == .iPhone5_5) {
                //self.scrollView.minimumZoomScale = 0.546
                //self.scrollView.maximumZoomScale = 0.546
                //self.scrollView.setZoomScale(0.546, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone6_5) {
                //self.scrollView.minimumZoomScale = 0.545
                //self.scrollView.maximumZoomScale = 0.545
                //self.scrollView.setZoomScale(0.545, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone5_8) {
                //self.scrollView.minimumZoomScale = 0.495
                //self.scrollView.maximumZoomScale = 0.495
                //self.scrollView.setZoomScale(0.495, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone6_1) {
                //self.scrollView.minimumZoomScale = 0.55
                //self.scrollView.maximumZoomScale = 0.55
                //self.scrollView.setZoomScale(0.55, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone4_7) {
                //self.scrollView.minimumZoomScale = 0.49
                //self.scrollView.maximumZoomScale = 0.49
                //self.scrollView.setZoomScale(0.49, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone4_0) {
                //self.scrollView.minimumZoomScale = 0.41
                //self.scrollView.maximumZoomScale = 0.41
                //self.scrollView.setZoomScale(0.41, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else {
                print("Using iPad, nothing needs to be modified.")
            }
        } else if webView.url == url3 {
            print("Using non official login method, the screen zoom scale needs to be changed.")
            if (UIScreen.current == .iPhone5_5) {
                //self.scrollView.minimumZoomScale = 0.546
                //self.scrollView.maximumZoomScale = 0.546
                //self.scrollView.setZoomScale(0.546, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone6_5) {
                //self.scrollView.minimumZoomScale = 0.545
                //self.scrollView.maximumZoomScale = 0.545
                //self.scrollView.setZoomScale(0.545, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone5_8) {
                //self.scrollView.minimumZoomScale = 0.495
                //self.scrollView.maximumZoomScale = 0.495
                //self.scrollView.setZoomScale(0.495, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone6_1) {
                //self.scrollView.minimumZoomScale = 0.55
                //self.scrollView.maximumZoomScale = 0.55
                //self.scrollView.setZoomScale(0.55, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone4_7) {
                //self.scrollView.minimumZoomScale = 0.49
                //self.scrollView.maximumZoomScale = 0.49
                //self.scrollView.setZoomScale(0.49, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else if (UIScreen.current == .iPhone4_0) {
                //self.scrollView.minimumZoomScale = 0.41
                //self.scrollView.maximumZoomScale = 0.41
                //self.scrollView.setZoomScale(0.41, animated: false)
                //self.scrollView.isScrollEnabled = false
            } else {
                print("Using iPad, nothing needs to be modified.")
            }
        } else {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            self.scrollView.setZoomScale(1, animated: false)
            //self.scrollView.zoomScale = 1
            self.scrollView.isScrollEnabled = true
        }
        saveCookie()
    }

    public func webView(_ webView: WKWebView, didFailNavigation error: Error) {
    }

}
