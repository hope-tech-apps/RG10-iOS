//
//  HomeNavigationStack.swift
//  RG10
//
//  Home tab navigation stack
//

import SwiftUI

struct HomeNavigationStack: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $navigationManager.homePath) {
            // Use your existing HomeView directly, just wrap it
            HomeView(viewModel: viewModel)
                .environmentObject(coordinator)
                .navigationBarHidden(true)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .about:
            AboutView()
        case .staff(let index):
            StaffView()
                .environmentObject(coordinator)
                .onAppear {
                    coordinator.selectedStaff = index
                }
        case .merchandise:
            SupabaseMerchandiseView()
        case .merchandiseDetail(let product):
            SupabaseProductDetailView(product: product)
        case .termsOfService:
            TermsOfServiceView()
        case .privacyPolicy:
            PrivacyPolicyView()
        case .videoPlayer(let video):
            if let videoID = video.videoID {
                YouTubePlayerSheet(
                    video: YouTubeVideo(
                        title: video.title,
                        videoID: videoID,
                        thumbnailURL: video.thumbnailURL,
                        duration: video.duration
                    )
                )
            }
        default:
            EmptyView()
        }
    }
}

// If you need a simplified HomeMainView for NavigationStack (alternative approach)
struct HomeMainViewSimple: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var showMenu = false
    
    // Provide a local list of coaches to satisfy CoachesSection([Coach])
    private let coaches: [Coach] = [
        Coach(
            name: "Rodrigo Gudino",
            role: "Head Coach & CEO",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/207C2DC5-1B43-48C0-BEA2-C436CCBC45F1.jpeg",
            cardImageURL: nil
        ),
        Coach(
            name: "Aryan Kamdar",
            role: "Coach (Chicago)",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/Aryan2-683x1024.jpeg",
            cardImageURL: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Carousel - use existing CarouselView
                CarouselView(viewModel: viewModel)
                    .frame(height: 400)
                
                // Our Story Section - use existing
                OurStorySection(videos: viewModel.videos)
                    .padding(.horizontal, 16)
                
                // Coaches Section
                CoachesSection(coaches: coaches)
                
                // Quick Actions
                QuickActionsSection()
            }
        }
        .navigationTitle("RG10 Football")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navigationManager.showingSideMenu.toggle()
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

// Quick Actions Section that works with your navigation
struct QuickActionsSection: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickActionButton(
                        icon: "calendar",
                        title: "Book Session",
                        color: AppConstants.Colors.primaryRed
                    ) {
                        navigationManager.selectedTab = .book
                    }
                    
                    QuickActionButton(
                        icon: "figure.run",
                        title: "Training",
                        color: .blue
                    ) {
                        navigationManager.selectedTab = .training
                    }
                    
                    QuickActionButton(
                        icon: "bag",
                        title: "Shop",
                        color: .green
                    ) {
                        navigationManager.navigate(to: .merchandise)
                    }
                    
                    QuickActionButton(
                        icon: "person.2",
                        title: "Coaches",
                        color: .orange
                    ) {
                        navigationManager.navigate(to: .staff(selectedIndex: nil))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(color)
            .cornerRadius(12)
        }
    }
}
