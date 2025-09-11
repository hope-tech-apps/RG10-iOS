//
//  ExploreViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//

import SwiftUI
import Combine

@MainActor
// MARK: - View Model
class ExploreViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    @Published var coaches: [Coach] = [
        Coach(
            name: "Rodrigo Gudino",
            role: "Head Coach & CEO",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/207C2DC5-1B43-48C0-BEA2-C436CCBC45F1.jpeg",
            cardImageURL: nil
        ),
        Coach(
            name: "Aryan Kamdar",
            role: "RG10 Coach (Chicago)",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/Aryan2-683x1024.jpeg",
            cardImageURL: nil
        )
    ]
    
    @Published var recommendedVideos: [ExploreVideoItem] = []

    @Published var playerSpotlights: [PlayerSpotlight] = [
        PlayerSpotlight(
            name: "Player's name",
            description: "A brief about. A rising star known for his unmatched speed and precision on the field. His dedication and discipline have made him a role model for aspiring players around the world.",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/IMG_5462-scaled.jpeg"
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
    
    init() {
        loadYouTubePlaylist()
    }
    
    func loadYouTubePlaylist() {
        Task {
            await YouTubeService.shared
                .fetchPlaylistVideos(
                    playlistId: "PLPzb8bYVQEQEEH4q36QMcB5JzBRKBblVA"
                )
            
            YouTubeService.shared.$playlistVideos
                .sink { [weak self] videos in
                    self?.recommendedVideos = videos.map { video in
                        ExploreVideoItem(
                            title: video.title,
                            thumbnailURL: video.thumbnailURL,
                            duration: video.duration,
                            views: nil,
                            videoID: video.videoID
                        )
                    }
                }
                .store(in: &cancellables)
        }
    }
}
