//
//  YouTubeError.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import Foundation

// MARK: - YouTube Error Types
enum YouTubeError: LocalizedError, Sendable {
    case invalidURL
    case noData
    case apiError(message: String, code: Int)
    case decodingError(String)
    case networkError(Error)
    case invalidAPIKey
    case quotaExceeded
    case playlistNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid YouTube API URL"
        case .noData:
            return "No data received from YouTube API"
        case .apiError(let message, let code):
            return "YouTube API Error (\(code)): \(message)"
        case .decodingError(let details):
            return "Failed to parse YouTube response: \(details)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid or missing YouTube API key"
        case .quotaExceeded:
            return "YouTube API quota exceeded. Please try again later."
        case .playlistNotFound:
            return "YouTube playlist not found or is private"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidAPIKey:
            return "Please check your YouTube API key in Google Cloud Console"
        case .quotaExceeded:
            return "Wait for quota to reset or increase your API limits"
        case .playlistNotFound:
            return "Ensure the playlist is public and the ID is correct"
        case .apiError(_, let code) where code == 403:
            return "Check API key permissions and YouTube Data API v3 is enabled"
        default:
            return nil
        }
    }
}
