//
//  YouTubeService.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/31/25.
//


import Foundation
import Combine

// MARK: - YouTube Models
struct YouTubePlaylistResponse: Codable {
    let items: [YouTubePlaylistItem]
    let nextPageToken: String?
}

struct YouTubePlaylistItem: Codable {
    let snippet: YouTubeSnippet
    let contentDetails: YouTubeContentDetails?
}

struct YouTubeSnippet: Codable {
    let title: String
    let description: String
    let thumbnails: YouTubeThumbnails
    let resourceId: YouTubeResourceId?
}

struct YouTubeThumbnails: Codable {
    let high: YouTubeThumbnail
    let maxres: YouTubeThumbnail?
}

struct YouTubeThumbnail: Codable {
    let url: String
}

struct YouTubeResourceId: Codable {
    let videoId: String
}

struct YouTubeContentDetails: Codable {
    let videoId: String?
}

// MARK: - YouTube Service
class YouTubeService: ObservableObject {
    static let shared = YouTubeService()
    
    // IMPORTANT: You need to get an API key from Google Cloud Console
    // 1. Go to https://console.cloud.google.com/
    // 2. Create a new project or select existing
    // 3. Enable YouTube Data API v3
    // 4. Create credentials (API Key)
    // 5. Restrict the key to your app's bundle ID
    private let API_KEY = "AIzaSyC9PEMSZulrgO3hnMYqUbAKtfsM7jWAuYM"
    private let baseURL = "https://www.googleapis.com/youtube/v3"
    
    @Published var playlistVideos: [YouTubeVideo] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Fetch videos from playlist
    func fetchPlaylistVideos(playlistId: String) {
        isLoading = true
        error = nil
        
        let urlString = "\(baseURL)/playlistItems?part=snippet,contentDetails&maxResults=50&playlistId=\(playlistId)&key=\(API_KEY)"
        
        guard let url = URL(string: urlString) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: YouTubePlaylistResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                        print("Error fetching playlist: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.playlistVideos = response.items.compactMap { item in
                        guard let videoId = item.snippet.resourceId?.videoId ?? item.contentDetails?.videoId else {
                            return nil
                        }
                        
                        return YouTubeVideo(
                            title: item.snippet.title,
                            videoID: videoId,
                            thumbnailURL: item.snippet.thumbnails.maxres?.url ?? item.snippet.thumbnails.high.url,
                            duration: nil // Duration requires additional API call
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // Extract playlist ID from URL
    static func extractPlaylistId(from url: String) -> String? {
        if url.contains("list=") {
            return url.components(separatedBy: "list=").last?.components(separatedBy: "&").first
        }
        return nil
    }
}

// MARK: - Hardcoded Playlist Data (Immediate Solution)
extension YouTubeService {
    // Use this while setting up API key
    func loadHardcodedPlaylist() {
        playlistVideos = [
            YouTubeVideo(
                title: "RG10 Football - Training Session #1",
                videoID: "dQw4w9WgXcQ", // Replace with actual video IDs from your playlist
                thumbnailURL: "https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
                duration: "3:45"
            ),
            YouTubeVideo(
                title: "Technical Skills Development",
                videoID: "videoID2",
                thumbnailURL: "https://img.youtube.com/vi/videoID2/maxresdefault.jpg",
                duration: "5:20"
            ),
            YouTubeVideo(
                title: "Match Highlights - RG10 Academy",
                videoID: "videoID3",
                thumbnailURL: "https://img.youtube.com/vi/videoID3/maxresdefault.jpg",
                duration: "2:15"
            )
        ]
    }
}

// MARK: - Updated YouTube Video Model
extension YouTubeVideo {
    init(title: String, videoID: String, thumbnailURL: String, duration: String?) {
        self.title = title
        self.videoID = videoID
        self.thumbnailURL = thumbnailURL
        self.duration = duration
    }
}

//// MARK: - Explore View Model with YouTube Integration
//extension ExploreViewModel {
//    func loadYouTubePlaylist() {
//        // Extract playlist ID from the URL
//        let playlistURL = "https://www.youtube.com/playlist?list=PLPzb8bYVQEQEEH4q36QMcB5JzBRKBblVA"
//        
//        if let playlistId = YouTubeService.extractPlaylistId(from: playlistURL) {
//            // For production: Use API
//            // YouTubeService.shared.fetchPlaylistVideos(playlistId: playlistId)
//            
//            // For now: Use hardcoded data
//            YouTubeService.shared.loadHardcodedPlaylist()
//            
//            // Observe changes
//            YouTubeService.shared.$playlistVideos
//                .sink { [weak self] videos in
//                    self?.recommendedVideos = videos.map { video in
//                        ExploreVideoItem(
//                            title: video.title,
//                            thumbnailURL: video.thumbnailURL,
//                            duration: video.duration ?? "N/A",
//                            views: nil
//                        )
//                    }
//                }
//                .store(in: &cancellables)
//        }
//    }
//    
//}
