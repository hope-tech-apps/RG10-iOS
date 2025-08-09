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
    let duration: String
    let views: String?
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
                    // Custom Navigation Bar
                    ExploreNavigationBar()
                    
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


// MARK: - Coaches Section
struct CoachesSection: View {
    let coaches: [Coach]
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meet the Coaches")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(coaches) { coach in
                        CoachCard(coach: coach) {
                            coordinator.showStaff()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct CoachCard: View {
    let coach: Coach
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    // Coach Image
                    AsyncImage(url: URL(string: coach.imageURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 170)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 170, height: 170)
                                .overlay(
                                    Image(Icons.account)
                                        .renderingMode(.template)
                                        .iconStyle(size: 40, color: .gray)
                                )
                        }
                    }
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // Coach Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(coach.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Text(coach.role)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    .padding(12)
                    .frame(width: 170, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                // Arrow indicator
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 28, height: 28)
                    )
                    .padding(12)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recommended Videos Section
struct RecommendedVideosSection: View {
    let videos: [ExploreVideoItem]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended for you")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            // Video Carousel
            TabView(selection: $selectedIndex) {
                ForEach(Array(videos.enumerated()), id: \.element.id) { index, video in
                    VideoCard(video: video)
                        .tag(index)
                        .padding(.horizontal, 20)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 220)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<videos.count, id: \.self) { index in
                    Circle()
                        .fill(index == selectedIndex ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: selectedIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}

struct VideoCard: View {
    let video: ExploreVideoItem
    
    var body: some View {
        ZStack {
            // Thumbnail
            AsyncImage(url: URL(string: video.thumbnailURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                }
            }
            .cornerRadius(16)
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)
            
            // Content Overlay
            VStack {
                Spacer()
                
                // Play Button
                Button(action: {}) {
                    Image(Icons.play)
                        .renderingMode(.template)
                        .iconStyle(size: 50, color: .white)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                        )
                }
                
                Spacer()
                
                // Video Info
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Video title in")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("brief.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(video.duration)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                }
                .padding(16)
            }
        }
        .frame(height: 200)
    }
}

// MARK: - Player Spotlights Section
struct PlayerSpotlightsSection: View {
    let spotlights: [PlayerSpotlight]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Carousel
            TabView(selection: $selectedIndex) {
                ForEach(Array(spotlights.enumerated()), id: \.element.id) { index, spotlight in
                    PlayerSpotlightCard(spotlight: spotlight)
                        .tag(index)
                        .padding(.horizontal, 20)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 140)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<spotlights.count, id: \.self) { index in
                    Circle()
                        .fill(index == selectedIndex ? Color.black : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: selectedIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.black)
        }
        .background(Color.black)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

struct PlayerSpotlightCard: View {
    let spotlight: PlayerSpotlight
    
    var body: some View {
        HStack(spacing: 16) {
            // Player Image
            AsyncImage(url: URL(string: spotlight.imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(Icons.account)
                                .renderingMode(.template)
                                .iconStyle(size: 30, color: .gray)
                        )
                }
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 6) {
                Text(spotlight.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(spotlight.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {}) {
                    Text("See more")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.black)
    }
}

// MARK: - View Model
class ExploreViewModel: ObservableObject {
    @Published var coaches: [Coach] = [
        Coach(
            name: "Rodrigo Gudino",
            role: "Head Coach & CEO",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/207C2DC5-1B43-48C0-BEA2-C436CCBC45F1.jpeg",
            cardImageURL: nil
        ),
        Coach(
            name: "Rodrigo Gudino",
            role: "Head Coach & CEO",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/DSC9911.jpeg",
            cardImageURL: nil
        ),
        Coach(
            name: "Aryan Kamdar",
            role: "RG10 Coach (Chicago)",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/IMG_5462-scaled.jpeg",
            cardImageURL: nil
        )
    ]
    
    @Published var recommendedVideos: [ExploreVideoItem] = [
        ExploreVideoItem(
            title: "Video title in brief",
            thumbnailURL: "",
            duration: "0:5M",
            views: nil
        ),
        ExploreVideoItem(
            title: "Video title in brief",
            thumbnailURL: "",
            duration: "1:5M",
            views: nil
        ),
        ExploreVideoItem(
            title: "Training Session Highlights",
            thumbnailURL: "",
            duration: "2:30M",
            views: nil
        )
    ]
    
    @Published var playerSpotlights: [PlayerSpotlight] = [
        PlayerSpotlight(
            name: "Player's name",
            description: "A brief about. A rising star known for his unmatched speed and precision on the field. His dedication and discipline have made him a role model for aspiring players around the world.",
            imageURL: ""
        ),
        PlayerSpotlight(
            name: "Another Player",
            description: "Exceptional midfielder with vision and technical skills that set him apart. Leading by example both on and off the pitch.",
            imageURL: ""
        ),
        PlayerSpotlight(
            name: "Featured Player",
            description: "Young talent making waves in the academy. Combines natural ability with relentless work ethic.",
            imageURL: ""
        )
    ]
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
