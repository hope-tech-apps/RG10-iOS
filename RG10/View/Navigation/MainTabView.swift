//
//  MainTabView.swift
//  RG10
//
//  Native tab bar matching custom tab bar logic
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var coordinator = AppCoordinator()
    @State private var selectedTab: TabItem = .home
    @State private var showingSideMenu = false
    @State private var sideMenuOffset: CGFloat = 0
    
    private let menuWidth = UIScreen.main.bounds.width * 0.8
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
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
                
                // Training Tab (if available)
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
                
                // Book Tab (if available)
                if availableTabs.contains(.book) {
                    NavigationStack(path: $navigationManager.bookPath) {
                        BookTabView()
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
                
                // Explore Tab (if available)
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
                if !availableTabs.contains(selectedTab) {
                    selectedTab = .home
                }
            }
            .environmentObject(navigationManager)
            
            // Side Menu Overlay with swipe support
            if showingSideMenu {
                SideMenuContainer(
                    isShowing: $showingSideMenu,
                    menuWidth: UIScreen.main.bounds.width * 0.8
                )
                .environmentObject(coordinator)
                .environmentObject(navigationManager)
            }
        }
    }
    
    private var availableTabs: [TabItem] {
        TabItem.availableTabs(isAuthenticated: authManager.isAuthenticated)
    }
}

// Home Content View (extracted for clarity)
struct HomeContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CarouselView(viewModel: viewModel)
                    .frame(height: 400)
                
                OurStorySection(videos: viewModel.videos)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            }
        }
    }
}
// MARK: - Navigation Bar Setup Extension
extension View {
    func navigationBarSetup(showingSideMenu: Binding<Bool>) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSideMenu.wrappedValue = true
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Image(AppConstants.Images.logoColor)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
            }
    }
}
