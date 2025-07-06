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
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Navigation Bar
                    CustomNavigationBar(showMenu: $showMenu)
                    
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
                    
                    // Tab Bar
                    CustomTabBar(selectedTab: $viewModel.selectedTab)
                }
                
                // Side Menu
                if showMenu {
                    SideMenu(isShowing: $showMenu)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
