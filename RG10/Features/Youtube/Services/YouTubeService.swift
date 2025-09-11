//
//  YouTubeService.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/31/25.
//

import Foundation
import Combine

@MainActor
final class YouTubeService: ObservableObject {
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
    @Published var error: YouTubeError?
    @Published var debugInfo: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let decoder = JSONDecoder()
    
    private init() {
        // Configure decoder for better date handling
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
    /// Fetch videos from YouTube playlist with comprehensive error handling
    func fetchPlaylistVideos(playlistId: String) async {
        await setLoadingState(true)
        
        do {
            let videos = try await performPlaylistRequest(playlistId: playlistId)
            await updateVideos(videos)
            await logDebugInfo("Successfully loaded \(videos.count) videos from playlist")
        } catch let youtubeError as YouTubeError {
            await setError(youtubeError)
        } catch {
            await setError(.networkError(error))
        }
        
        await setLoadingState(false)
    }
    
    /// Extract playlist ID from various YouTube URL formats
    static func extractPlaylistId(from url: String) -> String? {
        // Handle different URL formats:
        // https://www.youtube.com/playlist?list=PLPzb8bYVQEQEEH4q36QMcB5JzBRKBblVA
        // https://youtube.com/playlist?list=PLPzb8bYVQEQEEH4q36QMcB5JzBRKBblVA&si=xyz
        if let range = url.range(of: "list=") {
            let listPart = String(url[range.upperBound...])
            return listPart.components(separatedBy: "&").first
        }
        return nil
    }
    
    /// Test API connection and permissions
    func testAPIConnection() async -> Bool {
        do {
            let testPlaylistId = "PLPzb8bYVQEQEEH4q36QMcB5JzBRKBblVA"
            _ = try await performPlaylistRequest(playlistId: testPlaylistId, maxResults: 1)
            await logDebugInfo("✅ API connection successful")
            return true
        } catch {
            await logDebugInfo("❌ API connection failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func performPlaylistRequest(playlistId: String, maxResults: Int = 50) async throws -> [YouTubeVideo] {
        guard !API_KEY.isEmpty else {
            throw YouTubeError.invalidAPIKey
        }
        
        let urlString = "\(baseURL)/playlistItems?part=snippet,contentDetails&maxResults=\(maxResults)&playlistId=\(playlistId)&key=\(API_KEY)"
        
        guard let url = URL(string: urlString) else {
            throw YouTubeError.invalidURL
        }
        
        await logDebugInfo("🔗 Request URL: \(urlString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Log response for debugging
        if let httpResponse = response as? HTTPURLResponse {
            await logDebugInfo("📡 HTTP Status: \(httpResponse.statusCode)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            await logDebugInfo("📥 Raw Response: \(responseString.prefix(500))...")
        }
        
        guard !data.isEmpty else {
            throw YouTubeError.noData
        }
        
        // First, try to decode as error response
        if let errorResponse = try? decoder.decode(YouTubeErrorResponse.self, from: data) {
            await logDebugInfo("❌ YouTube API Error: \(errorResponse.error.message)")
            
            let error = mapAPIError(errorResponse.error)
            throw error
        }
        
        // Then try to decode as success response
        do {
            let playlistResponse = try decoder.decode(YouTubePlaylistResponse.self, from: data)
            await logDebugInfo("✅ Successfully decoded \(playlistResponse.items.count) items")
            
            return playlistResponse.items.compactMap { item in
                convertToYouTubeVideo(from: item)
            }
        } catch {
            throw YouTubeError.decodingError(error.localizedDescription)
        }
    }
    
    private func convertToYouTubeVideo(from item: YouTubePlaylistItem) -> YouTubeVideo? {
        guard let videoId = item.snippet.resourceId?.videoId ?? item.contentDetails?.videoId else {
            return nil
        }
        
        // Get best available thumbnail
        let thumbnailURL = getBestThumbnail(from: item.snippet.thumbnails)
        
        return YouTubeVideo(
            title: item.snippet.title,
            videoID: videoId,
            thumbnailURL: thumbnailURL,
            duration: nil // Duration requires additional API call
        )
    }
    
    private func getBestThumbnail(from thumbnails: YouTubeThumbnails) -> String {
        return thumbnails.maxres?.url ??
               thumbnails.high?.url ??
               thumbnails.standard?.url ??
               thumbnails.medium?.url ??
               thumbnails.default?.url ??
               "https://img.youtube.com/vi/default/maxresdefault.jpg"
    }
    
    private func mapAPIError(_ apiError: YouTubeErrorResponse.ErrorDetail) -> YouTubeError {
        switch apiError.code {
        case 400:
            return .apiError(message: apiError.message, code: apiError.code)
        case 403:
            if apiError.message.contains("API key") {
                return .invalidAPIKey
            } else if apiError.message.contains("quota") {
                return .quotaExceeded
            } else {
                return .apiError(message: apiError.message, code: apiError.code)
            }
        case 404:
            return .playlistNotFound
        default:
            return .apiError(message: apiError.message, code: apiError.code)
        }
    }
    
    // MARK: - State Management
    
    private func setLoadingState(_ loading: Bool) async {
        isLoading = loading
        if loading {
            error = nil
        }
    }
    
    private func updateVideos(_ videos: [YouTubeVideo]) async {
        playlistVideos = videos
        error = nil
    }
    
    private func setError(_ youtubeError: YouTubeError) async {
        error = youtubeError
        await logDebugInfo("❌ Error: \(youtubeError.localizedDescription)")
    }
    
    private func logDebugInfo(_ message: String) async {
        let timestamp = DateFormatter.timeFormatter.string(from: Date())
        debugInfo += "[\(timestamp)] \(message)\n"
        print("YouTubeService: \(message)")
    }
}

// MARK: - Hardcoded Fallback
extension YouTubeService {
    /// Load hardcoded playlist data for immediate testing
    func loadHardcodedPlaylist() async {
        await setLoadingState(true)
        await logDebugInfo("🔄 Loading hardcoded playlist data...")
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let hardcodedVideos = [
            YouTubeVideo(
                title: "RG10 Football - Training Excellence",
                videoID: "TlQ8bLELCu8",
                thumbnailURL: "https://img.youtube.com/vi/TlQ8bLELCu8/maxresdefault.jpg",
                duration: "3:45"
            ),
            YouTubeVideo(
                title: "Technical Skills Development",
                videoID: "j4kj-Yrl_uU",
                thumbnailURL: "https://img.youtube.com/vi/j4kj-Yrl_uU/maxresdefault.jpg",
                duration: "5:20"
            ),
            YouTubeVideo(
                title: "Building Champions - RG10 Academy",
                videoID: "WBqLygBUPKY",
                thumbnailURL: "https://img.youtube.com/vi/WBqLygBUPKY/maxresdefault.jpg",
                duration: "2:15"
            )
        ]
        
        await updateVideos(hardcodedVideos)
        await setLoadingState(false)
        await logDebugInfo("✅ Loaded \(hardcodedVideos.count) hardcoded videos")
    }
}

// MARK: - Convenience Methods
extension YouTubeService {
    /// Clear all data and reset state
    func reset() async {
        await setLoadingState(false)
        playlistVideos = []
        error = nil
        debugInfo = ""
    }
    
    /// Get debug information as formatted string
    var formattedDebugInfo: String {
        debugInfo.isEmpty ? "No debug information available" : debugInfo
    }
}

// MARK: - Extensions
private extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
}

// MARK: - YouTube Video Model Extension
extension YouTubeVideo {
    init(title: String, videoID: String, thumbnailURL: String, duration: String?) {
        self.title = title
        self.videoID = videoID
        self.thumbnailURL = thumbnailURL
        self.duration = duration
    }
}
