//
//  ContentView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

// MARK: - Main App View with Navigation
struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .loading:
                LoadingScreen()
                    .transition(.opacity)
            case .welcome:
                WelcomeScreen()
                    .transition(.opacity)
            case .home:
                HomeScreen(viewModel: homeViewModel)
                    .transition(.opacity)
            case .login, .signUp:
                EmptyView() // Handled by sheet
            }
        }
        .animation(.easeInOut(duration: 0.5), value: coordinator.currentScreen)
        .sheet(isPresented: $coordinator.showLoginSheet) {
            LoginView(viewModel: authViewModel)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
