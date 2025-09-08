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
    @StateObject private var exploreViewModel = ExploreViewModel()
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
                HomeView(viewModel: homeViewModel)
                    .transition(.opacity)
            case .login, .signUp:
                EmptyView() // Handled by sheet
            }
        }
        .animation(.easeInOut(duration: 0.5), value: coordinator.currentScreen)
        .sheet(isPresented: $coordinator.showLoginSheet) {
            LoginView(viewModel: authViewModel)
        }
        .sheet(isPresented: $coordinator.showAboutSheet) {
            AboutView()
        }
        .sheet(isPresented: $coordinator.showMerchSheet) {
            SupabaseMerchandiseView()
        }
        .sheet(isPresented: $coordinator.showExploreSheet) {
            ExploreView()
                .environmentObject(coordinator)
        }
        .sheet(isPresented: $coordinator.showStaffSheet) {
            StaffView()
                .environmentObject(coordinator)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
