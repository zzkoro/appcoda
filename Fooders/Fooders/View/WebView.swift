//
//  WebView.swift
//  Fooders
//
//  Created by junemp on 2022/01/23.
//

import UIKit
import WebKit
import SwiftUI
import Combine

class WebViewScriptHandler: NSObject, WKScriptMessageHandler {
    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON 데이터가 웹으로부터 옴: \(value)")
    }
    
    func receivedStringValueFromWebView(value: String) {
        print("String 데이터가 웹으로부터 옴: \(value)")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "MyBridge", let body = message.body as? [String: Any] {
            self.receivedJsonValueFromWebView(value: body)
        } else if let body = message.body as? String {
            self.receivedStringValueFromWebView(value: body)
        }
    }
}

struct WebView: UIViewRepresentable {
    var url: URL
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        
        print("makeUIView called ")
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false // JavaScript가 사용자 상호 작용없이 창을 열 수 있는지 여부
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        //Javascript -> Native 간의 데이터 전송을 위한 Bridge 설정
        configuration.userContentController.add(WebViewScriptHandler(), name: "MyBridge");
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator // 웹보기의 탐색 동작을 관리하는 데 사용하는 개체
        webView.allowsBackForwardNavigationGestures = true // 가로로 스와이프 동작이 페이지 탐색을 앞뒤로 트리거하는지 여부
        webView.scrollView.isScrollEnabled = true // 웹보기와 관련된 스크롤보기에서 스크롤 가능 여부
        
        webView.load(URLRequest(url: url)) // 지정된 URL 요청 개체에서 참조하는 웹 콘텐츠를로드하고 탐색
        
        return webView
        
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
        print("updateUIView called ")
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        
        print("makeCoordinator called ")
        
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var foo: AnyCancellable? = nil
        
        init(_ uiWebView: WebView) {
            self.parent = uiWebView
        }
        
        deinit {
            foo?.cancel()
        }
        
        // 지정된 기본 설정 및 작업 정보를 기반으로 새 콘텐츠를 탐색 할 수있는 권한을 대리인에게 요청
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let host = navigationAction.request.url?.host {
                print("host: \(host)")
                
//                if host != "velog.io" {
//                    print("host: \(host)")
//                    return decisionHandler(.cancel)
//                }
            }
            
            parent.viewModel.bar.send(false)
            
            self.foo = self.parent.viewModel.foo.receive(on: RunLoop.main)
                .sink(receiveValue: { value in
                    print(value)
                    
                    webView.evaluateJavaScript("changeTotal('\("Hi, JavaScript")')", completionHandler: { result, error in
                        if let anError = error {
                            print("Error \(anError.localizedDescription)")
                        }
                        print("Result: \(result ?? "")")
                        
                    })
                })
            
            return decisionHandler(.allow)
            
        }
        
        // 기본 프레임에서 탐색이 시작되었음
        func webView(_ webView: WKWebView,
                       didStartProvisionalNavigation navigation: WKNavigation!) {
            print("기본 프레임에서 탐색이 시작되었음")
        }
        
        // 웹보기가 기본 프레임에 대한 내용을 수신하기 시작했음
        func webView(_ webView: WKWebView,
                       didCommit navigation: WKNavigation!) {
            print("내용을 수신하기 시작");
        }
        
        // 탐색이 완료 되었음
        func webView(_ webview: WKWebView,
                       didFinish: WKNavigation!) {
            print("탐색이 완료")
        }
        
        // 초기 탐색 프로세스 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                       didFailProvisionalNavigation: WKNavigation!,
                       withError: Error) {
            print("초기 탐색 프로세스 중에 오류가 발생했음")
        }
        
        // 탐색 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                       didFail navigation: WKNavigation!,
                       withError error: Error) {
            print("탐색 중에 오류가 발생했음")
        }
    }
}
    

        
    
