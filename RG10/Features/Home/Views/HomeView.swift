//
//  HomeView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showMenu = false
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {                    
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
                            ExploreView()
                        case .account:
                            AccountTabView()  // ✅ Shows inline, not as sheet
                        }
                    }
                }
                
                // Side Menu
                if showMenu {
                    SideMenuView(isShowing: $showMenu) // Cannot find 'SideMenuView' in scope
                        .environmentObject(coordinator)
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            // If user logs in while on account tab, switch to home tab
            if isAuthenticated && viewModel.selectedTab == .account {
                viewModel.selectedTab = .home
            }
        }
    }
}

