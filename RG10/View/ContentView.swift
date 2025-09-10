//
//  ContentView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showLoginSheet = false
    
    var body: some View {
        MainTabView()
            .environmentObject(navigationManager)
            .environmentObject(authManager)
            .onReceive(NotificationCenter.default.publisher(for: .showLogin)) { _ in
                if !authManager.isAuthenticated {
                    showLoginSheet = true
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView(viewModel: AuthViewModel())
            }
    }
}
