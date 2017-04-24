//
//  ViewController.swift
//  WKWebViewTest
//
//  Created by Sebastian Ludwig on 24.04.2017.
//  Copyright © 2017 Lurado. All rights reserved.
//

import UIKit
import WebKit

private let kUseWKWebView = true

class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = URLRequest(url: URL(string: "http://localhost:4567")!)
        if kUseWKWebView {
            navigationItem.title = "WKWebView"
            let configuration = WKWebViewConfiguration()
            let webView = WKWebView(frame: view.bounds, configuration: configuration)
            webView.navigationDelegate = self
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(webView)
            webView.load(request)
        } else {
            navigationItem.title = "UIWebView"
            let webView = UIWebView(frame: view.bounds)
            webView.delegate = self
            view.addSubview(webView)
            webView.loadRequest(request)
        }
        
        addButton(title: "Print 🍪", action: #selector(printCookies), y: 30);
        addButton(title: "Set 🍪", action: #selector(setCookies), y: 70);
        addButton(title: "Delete 🍪", action: #selector(deleteCookies), y: 110);
    }
    
    private func addButton(title: String, action: Selector, y: CGFloat) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        button.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: y).isActive = true
    }
    
    func deleteCookies() {
        if kUseWKWebView {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSinceReferenceDate: 0), completionHandler: {
                print("deleted")
            })
        }
    }
    
    func printCookies() {
        
        if kUseWKWebView {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records: [WKWebsiteDataRecord]) in
                print("-- WKWebsiteDataStore --")
                print(records)
                print("----------------------\n")
            })
        }
        print("-- HTTPCookieStorage --")
        let cookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieStorage.cookies {
            for cookie in cookies {
                print("\(cookie.name) = \(cookie.value), session: \(cookie.isSessionOnly), exiration: \(cookie.expiresDate?.description ?? "-"), path: \(cookie.path)")
            }
        }
        print("---------------------\n")
    }
    
    func setCookies() {
        if kUseWKWebView {
            
        } else {
            let cookieStorage = HTTPCookieStorage.shared
            var properties: [HTTPCookiePropertyKey: Any] = [.name: "app_injected_session",
                                                            .value: "app cookie",
                                                            .domain: "localhost",
                                                            .path: "/"
                                                            ]
            if let cookie = HTTPCookie(properties: properties) {
                cookieStorage.setCookie(cookie)
            } else {
                print("FAILED to set cookie")
            }
            properties = [.name: "app_injected_persistent",
                          .value: "app cookie",
                          .domain: "localhost",
                          .path: "/",
                          .maximumAge: 120
                         ]
            if let cookie = HTTPCookie(properties: properties) {
                cookieStorage.setCookie(cookie)
            } else {
                print("FAILED to set cookie")
            }
        }
        
        printCookies()
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad \(webView.request?.url?.path ?? "?")")
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard let failingUrlStr = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String  else { return }
        let failingUrl = URL(string: failingUrlStr)!
        
        if failingUrlStr.hasPrefix("mailto:") {
            if UIApplication.shared.canOpenURL(failingUrl) {
                UIApplication.shared.openURL(failingUrl)
                return
            }
        } else if failingUrlStr.hasPrefix("itms://") {
            if UIApplication.shared.canOpenURL(failingUrl) {
                UIApplication.shared.openURL(failingUrl)
                return
            }
        }
    }
}

