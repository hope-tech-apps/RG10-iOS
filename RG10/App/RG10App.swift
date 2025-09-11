//
//  RG10App.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

@main
struct RG10App: App {
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showLoading = true
    @State private var showWelcome = false
    
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
                }
            }
            .preferredColorScheme(.light)
            .animation(.easeInOut(duration: 0.5), value: showLoading)
            .animation(.easeInOut(duration: 0.5), value: showWelcome)
        }
    }
}
