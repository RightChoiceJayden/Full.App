//
//  WebView.swift
//  iTrayne Client
//
//  Created by Christopher on 9/18/20.
//  Copyright © 2020 iTrayne LLC. All rights reserved.
//

import SwiftUI
import Combine
import WebKit

struct WebView:UIViewRepresentable {
    var url:String
    var webView:WKWebView = WKWebView()
    
    func makeUIView(context: Context) -> some WKWebView {
        
        guard let url = URL(string:self.url) else {
            return WKWebView()
        }
        
        let request = URLRequest(url:url)

        webView.navigationDelegate = context.coordinator
        webView.load(request)
        return self.webView;
    }
    
    func updateUIView(_ uiView: WebView.UIViewType, context: UIViewRepresentableContext<WebView>) {
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        
        var parent: WebView
        let config = WKWebViewConfiguration()

        init(_ parent: WebView) {
            self.parent = parent
            self.parent.webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            //self.config.userContentController.add(self, name: "iosListener")
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}
