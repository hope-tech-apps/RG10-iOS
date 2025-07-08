//
//  HomeScreen.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct HomeScreen<ViewModel: HomeViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showMenu = false
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Navigation Bar
                    CustomNavigationBar(showMenu: $showMenu)
                    
                    // Tab Content
                    Group {
                        // Tab Content - Account tab shows inline content
                        switch viewModel.selectedTab {
                        case .home:
                            ScrollView {
                                VStack(spacing: 24) {
                                    // Carousel
                                    CarouselView(viewModel: viewModel)
                                        .frame(height: 400)
                                    
                                    // Our Story Section
                                    OurStorySection(videos: viewModel.videos)
                                        .padding(.horizontal, 16)
                                }
                            }
                        case .training:
                            TrainingTabView()
                        case .book:
                            BookTabView()
                        case .explore:
                            ExploreTabView()
                        case .account:
                            AccountTabView()  // ✅ Shows inline, not as sheet
                        }
                    }
                    
                    // Tab Bar
                    CustomTabBar(selectedTab: $viewModel.selectedTab)
                }
                
                // Side Menu
                if showMenu {
                    SideMenu(isShowing: $showMenu)
                        .environmentObject(coordinator)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            // If user logs in while on account tab, switch to home tab
            if isAuthenticated && viewModel.selectedTab == .account {
                viewModel.selectedTab = .home
            }
        }
    }
}

// MARK: - Placeholder Tab Views
struct TrainingTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Training")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.gray)
            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.6))
            Spacer()
        }
    }
}

struct BookTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Book")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.gray)
            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.6))
            Spacer()
        }
    }
}

struct ExploreTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Explore")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.gray)
            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.6))
            Spacer()
        }
    }
}
