//
//  WebView.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/6.
//

import SwiftUI
import WebKit

struct StupidUIWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

final class StupidUIWebViewModel: ObservableObject {

    var urlString: String = ""

    let webView: WKWebView
    init() {
        webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
    }

    func loadUrl() {
        guard let url = URL(string: urlString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }

    func back() {
      webView.goBack()
    }
    func forward() {
      webView.goForward()
    }
}
