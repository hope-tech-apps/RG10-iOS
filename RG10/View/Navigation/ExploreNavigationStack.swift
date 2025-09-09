//
//  ExploreNavigationStack.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct ExploreNavigationStack: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = ExploreViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationManager.explorePath) {
            ExploreMainView()
                .environmentObject(viewModel)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
                .navigationDestination(for: Coach.self) { coach in
                    CoachDetailView(coach: coach)
                }
                .navigationDestination(for: ExploreVideoItem.self) { video in
                    VideoPlayerDetailView(video: video)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .coachProfile(let coach):
            CoachDetailView(coach: coach)
        case .videoPlayer(let video):
            VideoPlayerDetailView(video: video)
        case .playerSpotlight(let spotlight):
            PlayerSpotlightDetailView(spotlight: spotlight)
        default:
            EmptyView()
        }
    }
}

struct ExploreMainView: View {
    @EnvironmentObject var viewModel: ExploreViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var selectedVideoIndex = 0
    @State private var selectedSpotlightIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Coaches Section with Navigation
                VStack(alignment: .leading, spacing: 16) {
                    Text("Meet the Coaches")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.coaches) { coach in
                                NavigationLink(value: coach) {
                                    CoachCard(coach: coach) { }
                                        .allowsHitTesting(false)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Videos Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Training Videos")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.recommendedVideos) { video in
                                NavigationLink(value: video) {
                                    VideoThumbnailCard(video: video)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Player Spotlights
                PlayerSpotlightsSection(
                    spotlights: viewModel.playerSpotlights,
                    selectedIndex: $selectedSpotlightIndex
                )
            }
            .padding(.vertical)
        }
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.large)
    }
}

// Video Thumbnail Card
struct VideoThumbnailCard: View {
    let video: ExploreVideoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fill)
                    .overlay(ProgressView())
            }
            .frame(width: 280, height: 157)
            .clipped()
            .cornerRadius(12)
            .overlay(
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            )
            
            Text(video.title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
                .foregroundColor(.black)
            
            if let duration = video.duration {
                Text(duration)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 280)
    }
}

// Detail Views
struct CoachDetailView: View {
    let coach: Coach
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: coach.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(ProgressView())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(coach.name)
                        .font(.system(size: 28, weight: .bold))
                    
                    Text(coach.role)
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    Text("Professional coach with years of experience in developing young talent.")
                        .font(.system(size: 16))
                        .lineSpacing(4)
                        .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle("Coach Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VideoPlayerDetailView: View {
    let video: ExploreVideoItem
    
    var body: some View {
        VStack {
            if let videoID = video.videoID {
                YouTubePlayerView(videoID: videoID)
                    .aspectRatio(16/9, contentMode: .fit)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(video.title)
                    .font(.system(size: 20, weight: .bold))
                
                if let duration = video.duration {
                    Label(duration, systemImage: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .navigationTitle("Video")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlayerSpotlightDetailView: View {
    let spotlight: PlayerSpotlight
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: spotlight.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(ProgressView())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(spotlight.name)
                        .font(.system(size: 28, weight: .bold))
                    
                    Text(spotlight.description)
                        .font(.system(size: 16))
                        .lineSpacing(4)
                }
                .padding()
            }
        }
        .navigationTitle("Player Spotlight")
        .navigationBarTitleDisplayMode(.inline)
    }
}
