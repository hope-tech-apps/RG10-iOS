//
//  StoreWebView.swift
//  RG10
//
//  A lightweight, general-purpose in-app browser used for the live Shopify
//  storefront: collection browsing, product/size selection, cart, and
//  Shopify checkout.
//
//  Unlike the old Stripe success-intercept flow, this browser does NOT impose
//  an allowed-hosts whitelist — Shopify checkout legitimately redirects across
//  many domains (shop.app, *.myshopify.com, PayPal, Apple/Google Pay, 3-D
//  Secure bank pages, etc.), so http(s) navigation is always permitted.
//  External schemes (mailto/tel/app links) are handed off to the system.
//

import SwiftUI
import WebKit

// MARK: - Store WebView

struct StoreWebView: View {
    let url: URL
    let title: String
    let onDismiss: () -> Void

    @State private var isLoading = true
    @State private var canGoBack = false
    @State private var goBackAction: (() -> Void)?

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                StoreWebViewRepresentable(
                    url: url,
                    isLoading: $isLoading,
                    canGoBack: $canGoBack,
                    goBackAction: $goBackAction
                )

                if isLoading {
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: AppConstants.Colors.primaryRed))
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onDismiss) {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppConstants.Colors.primaryRed)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { goBackAction?() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(canGoBack ? AppConstants.Colors.primaryRed : .gray)
                    }
                    .disabled(!canGoBack)
                }
            }
        }
    }
}

// MARK: - Store WebView Representable

struct StoreWebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var goBackAction: (() -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        webView.load(URLRequest(url: url))

        DispatchQueue.main.async {
            self.goBackAction = { [weak webView] in
                webView?.goBack()
            }
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed; navigation state is reported via the delegate.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: StoreWebViewRepresentable

        init(_ parent: StoreWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // Allow all standard web navigation so Shopify checkout can redirect
            // freely across domains (shop.app, *.myshopify.com, payment providers,
            // 3-D Secure pages, etc.). Hand off non-web schemes to the system.
            if let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
                decisionHandler(.allow)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
                decisionHandler(.cancel)
            }
        }
    }
}
