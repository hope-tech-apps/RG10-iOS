//
//  RG10App.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

/// Wrapper to make the recovery code identifiable for sheet presentation
struct PasswordResetRequest: Identifiable {
    let id = UUID()
    let code: String
}

@main
struct RG10App: App {
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartStore = CartStore.shared
    @State private var showLoading = true
    @State private var showWelcome = false
    @State private var passwordResetRequest: PasswordResetRequest?
    @State private var lastProcessedDeepLinkCode: String?
    
    init() {
        // Debug configuration for Xcode Cloud troubleshooting
        #if DEBUG
        DebugConfiguration.printConfigurationDebugInfo()
        
        // Start memory monitoring
        MemoryMonitor.shared.startMonitoring(interval: 10.0)
        MemoryMonitor.shared.logMemory("App Init")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLoading {
                    LoadingScreen(
                        showLoading: $showLoading,
                        showWelcome: $showWelcome
                    )
                    .transition(.opacity)
                } else if showWelcome {
                    WelcomeScreen(showWelcome: $showWelcome)
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .environmentObject(navigationManager)
                        .environmentObject(authManager)
                        .environmentObject(cartStore)
                        .trackMemory("MainTabView")
                }
            }
            .preferredColorScheme(.light)
            .animation(.easeInOut(duration: 0.5), value: showLoading)
            .animation(.easeInOut(duration: 0.5), value: showWelcome)
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .sheet(item: $passwordResetRequest) { request in
                ResetPasswordView(recoveryCode: request.code)
            }
        }
    }
    
    // MARK: - Deep Link Handling
    
    /// Handles incoming deep links for password reset and other flows
    /// Expected format: rg10://deep-link?code=<UUID>&type=recovery
    private func handleDeepLink(_ url: URL) {
        print("🔗 Received deep link: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ Failed to parse deep link URL")
            return
        }
        
        // Parse query parameters
        let queryItems = components.queryItems ?? []
        var params: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                params[item.name] = value
            }
        }
        
        print("🔗 Deep link parameters: \(params)")
        
        // Check for password recovery deep link
        if let code = params["code"], let type = params["type"], type == "recovery" {
            handlePasswordRecovery(code: code)
        } else if let code = params["code"] {
            // Fallback: if we have a code but no type, assume it's recovery
            handlePasswordRecovery(code: code)
        } else {
            print("⚠️ Unknown deep link type or missing parameters")
        }
    }
    
    /// Handles password recovery deep link by showing the reset password sheet
    private func handlePasswordRecovery(code: String) {
        // Prevent duplicate handling of the same code
        guard lastProcessedDeepLinkCode != code else {
            print("🔑 Ignoring duplicate deep link code")
            return
        }
        lastProcessedDeepLinkCode = code
        
        print("🔑 Handling password recovery with code: \(code.prefix(8))...")
        
        // If we're still in loading/welcome state, wait for it to finish
        if showLoading || showWelcome {
            // The sheet will be shown once the main view is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("🔑 Presenting password reset sheet (delayed)")
                self.passwordResetRequest = PasswordResetRequest(code: code)
            }
        } else {
            print("🔑 Presenting password reset sheet (immediate)")
            passwordResetRequest = PasswordResetRequest(code: code)
        }
    }
}
