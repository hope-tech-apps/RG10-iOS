//
//  ExploreView.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//  Explore tab with coaches, videos, and player spotlights
//

import SwiftUI

// MARK: - Models
struct Coach: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let imageURL: String
    let cardImageURL: String? // Optional different image for card display
}

struct ExploreVideoItem: Identifiable {
    let id = UUID()
    let title: String
    let thumbnailURL: String
    let duration: String?
    let views: String?
    let videoID: String? // Add video ID for playback
}

struct PlayerSpotlight: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageURL: String
}

// MARK: - Main Explore View
struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var selectedVideoIndex = 0
    @State private var selectedSpotlightIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Meet the Coaches Section
                    CoachesSection(coaches: viewModel.coaches)
                        .padding(.top, 20)
                    
                    // Recommended Videos Section
                    RecommendedVideosSection(
                        videos: viewModel.recommendedVideos,
                        selectedIndex: $selectedVideoIndex
                    )
                    .padding(.top, 32)
                    
                    // Player Spotlights Section
                    PlayerSpotlightsSection(
                        spotlights: viewModel.playerSpotlights,
                        selectedIndex: $selectedSpotlightIndex
                    )
                    .padding(.top, 32)
                    
                    // Bottom padding for tab bar
                    Color.clear.frame(height: 100)
                }
            }
            .navigationBarHidden(true)
            .background(Color.white)
        }
    }
}

// MARK: - Preview
#Preview {
    ExploreView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthManager.shared)
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    ExploreView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthManager.shared)
}
