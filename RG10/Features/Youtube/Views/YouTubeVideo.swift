//
//  YouTubeVideo.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/31/25.
//

import SwiftUI

// MARK: - YouTube Video Model
struct YouTubeVideo: Identifiable {
    let id = UUID()
    let title: String
    let videoID: String
    let thumbnailURL: String
    let duration: String?
    
    init(title: String, url: String, duration: String? = nil) {
        self.title = title
        self.videoID = YouTubeVideo.extractVideoID(from: url) ?? ""
        self.thumbnailURL = "https://img.youtube.com/vi/\(self.videoID)/maxresdefault.jpg"
        self.duration = duration
    }
    
    static func extractVideoID(from url: String) -> String? {
        // Handle various YouTube URL formats
        if url.contains("youtu.be/") {
            return url.components(separatedBy: "youtu.be/").last?.components(separatedBy: "?").first
        } else if url.contains("youtube.com/watch?v=") {
            return url.components(separatedBy: "v=").last?.components(separatedBy: "&").first
        } else if url.contains("youtube.com/embed/") {
            return url.components(separatedBy: "embed/").last?.components(separatedBy: "?").first
        }
        return nil
    }
}
