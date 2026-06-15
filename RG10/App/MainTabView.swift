//
//  MainTabView.swift
//  RG10
//
//  Native tab bar matching custom tab bar logic
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var coordinator = AppCoordinator()
    @State private var showingSideMenu = false
    @State private var sideMenuOffset: CGFloat = 0
    
    private let menuWidth = UIScreen.main.bounds.width * 0.8
    
    var body: some View {
        ZStack {
            // Use navigationManager.selectedTab as the binding
            TabView(selection: $navigationManager.selectedTab) {  // Changed here
                // Home Tab
                NavigationStack(path: $navigationManager.homePath) {
                    HomeContentView()
                        .navigationBarSetup(showingSideMenu: $showingSideMenu)
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            NavigationDestinationView(destination: destination)
                                .environmentObject(coordinator)
                        }
                }
                .tabItem {
                    VStack {
                        Image(TabItem.home.icon)
                        Text(TabItem.home.title)
                    }
                }
                .tag(TabItem.home)
                
                // Training Tab
                if availableTabs.contains(.training) {
                    NavigationStack(path: $navigationManager.trainingPath) {
                        TrainingTabView()
                            .navigationBarSetup(showingSideMenu: $showingSideMenu)
                            .navigationDestination(for: NavigationDestination.self) { destination in
                                NavigationDestinationView(destination: destination)
                                    .environmentObject(coordinator)
                            }
                    }
                    .tabItem {
                        VStack {
                            Image(TabItem.training.icon)
                            Text(TabItem.training.title)
                        }
                    }
                    .tag(TabItem.training)
                }
                
                // Book Tab
                if availableTabs.contains(.book) {
                    NavigationStack(path: $navigationManager.bookPath) {
                        CombinedBookingView()
                            .navigationBarSetup(showingSideMenu: $showingSideMenu)
                            .navigationDestination(for: NavigationDestination.self) { destination in
                                NavigationDestinationView(destination: destination)
                                    .environmentObject(coordinator)
                            }
                    }
                    .tabItem {
                        VStack {
                            Image(TabItem.book.icon)
                            Text(TabItem.book.title)
                        }
                    }
                    .tag(TabItem.book)
                }
                
                // Explore Tab
                if availableTabs.contains(.explore) {
                    NavigationStack(path: $navigationManager.explorePath) {
                        ExploreView()
                            .environmentObject(coordinator)
                            .navigationBarSetup(showingSideMenu: $showingSideMenu)
                            .navigationDestination(for: NavigationDestination.self) { destination in
                                NavigationDestinationView(destination: destination)
                                    .environmentObject(coordinator)
                            }
                    }
                    .tabItem {
                        VStack {
                            Image(TabItem.explore.icon)
                            Text(TabItem.explore.title)
                        }
                    }
                    .tag(TabItem.explore)
                }
                
                // Account Tab
                NavigationStack(path: $navigationManager.accountPath) {
                    Group {
                        if authManager.isAuthenticated {
                            AccountMainView()
                        } else {
                            AccountTabView()
                        }
                    }
                    .navigationBarSetup(showingSideMenu: $showingSideMenu)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationDestinationView(destination: destination)
                            .environmentObject(coordinator)
                    }
                }
                .tabItem {
                    VStack {
                        Image(TabItem.account.icon)
                        Text(TabItem.account.title)
                    }
                }
                .tag(TabItem.account)
            }
            .tint(AppConstants.Colors.primaryRed)
            .onChange(of: authManager.isAuthenticated) { _ in
                if !availableTabs.contains(navigationManager.selectedTab) {  // Changed here
                    navigationManager.selectedTab = .home
                }
            }
            .environmentObject(navigationManager)
            
                // Side Menu Overlay
                if showingSideMenu {
                    SideMenuContainer(isShowing: $showingSideMenu)
                        .environmentObject(navigationManager)
                        .environmentObject(authManager)
                }
            }
            .onAppear {
                MemoryMonitor.shared.logMemory("MainTabView appeared")
            }
        }
    
    private var availableTabs: [TabItem] {
        TabItem.availableTabs(isAuthenticated: authManager.isAuthenticated)
    }
}

// HomeContentView
struct HomeContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CarouselView(viewModel: viewModel)
                    .environmentObject(navigationManager)
                    .environmentObject(authManager)
                    .frame(height: 400)

                // TST 2026 spotlight
                TSTSpotlightCard {
                    navigationManager.navigate(to: .tstSpotlight, in: .home)
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)

                OurStorySection(videos: viewModel.videos)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            }
        }
    }
}
