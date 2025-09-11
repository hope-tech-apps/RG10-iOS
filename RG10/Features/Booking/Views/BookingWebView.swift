//
//  BookingWebView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/9/25.
//


import SwiftUI
import WebKit

struct BookingWebView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: "https://www.oasyssports.com/RG10Football/global-login.cfm")!)
                .navigationTitle("Book a Session")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}