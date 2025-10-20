//
//  MerchandiseWebView.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI
import WebKit

// MARK: - Merchandise WebView

struct MerchandiseWebView: View {
    let config: MerchandiseWebViewConfig
    let onSuccessUrlDetected: ([String: String]) -> Void // All query parameters
    let onDismiss: () -> Void
    
    @State private var isLoading = true
    @State private var progress: Double = 0.0
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // WebView
                MerchandiseWebViewRepresentable(
                    url: URL(string: config.url)!,
                    isLoading: $isLoading,
                    progress: $progress,
                    onSuccessUrlDetected: { queryParams in
                        onSuccessUrlDetected(queryParams)
                    },
                    onError: { error in
                        errorMessage = error
                        showingError = true
                    },
                    allowedHosts: config.allowedHosts,
                    successUrlPattern: config.successUrlPattern
                )
                .onAppear {
                    print("🛒 Loading merchandise checkout URL: \(config.url)")
                }
                
                // Loading Overlay
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primaryRed))
                            .scaleEffect(1.5)
                        
                        Text("Loading checkout...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if progress > 0 {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: AppConstants.Colors.primaryRed))
                                .frame(width: 200)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground).opacity(0.9))
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }
}

// MARK: - Merchandise WebView Representable

struct MerchandiseWebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var progress: Double
    let onSuccessUrlDetected: ([String: String]) -> Void
    let onError: (String) -> Void
    let allowedHosts: [String]
    let successUrlPattern: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Load the URL
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: MerchandiseWebViewRepresentable
        
        init(_ parent: MerchandiseWebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.progress = 0.0
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.progress = 1.0
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                let errorMsg = "Failed to load: \(self.parent.url.absoluteString)\nError: \(error.localizedDescription)"
                self.parent.onError(errorMsg)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.onError("Navigation failed: \(error.localizedDescription)")
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            // Check if this is a success URL
            if isSuccessUrl(url) {
                let queryParams = extractAllQueryParams(from: url)
                DispatchQueue.main.async {
                    self.parent.onSuccessUrlDetected(queryParams)
                }
                decisionHandler(.cancel)
                return
            }
            
            // Check if this is an allowed host
            if !isAllowedHost(url) {
                // Block navigation to unauthorized hosts
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        private func extractAllQueryParams(from url: URL) -> [String: String] {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else { return [:] }
            
            var params: [String: String] = [:]
            for item in queryItems {
                if let value = item.value {
                    params[item.name] = value
                }
            }
            
            print("🛒 Extracted merchandise checkout parameters: \(params)")
            return params
        }
        
        private func isSuccessUrl(_ url: URL) -> Bool {
            let isSuccess = url.absoluteString.contains(parent.successUrlPattern)
            print("🛒 Checking success URL: \(url.absoluteString) -> \(isSuccess)")
            return isSuccess
        }
        
        private func isAllowedHost(_ url: URL) -> Bool {
            guard let host = url.host else { 
                print("🛒 No host found for URL: \(url.absoluteString)")
                return false 
            }
            let isAllowed = parent.allowedHosts.contains { allowedHost in
                host.contains(allowedHost)
            }
            print("🛒 Checking allowed host: \(host) -> \(isAllowed)")
            return isAllowed
        }
    }
}
