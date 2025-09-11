//
//  YouTubePlaylistResponse.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//


import Foundation
import Combine

// MARK: - YouTube Models
struct YouTubePlaylistResponse: Codable {
    let items: [YouTubePlaylistItem]
    let nextPageToken: String?
    let pageInfo: YouTubePageInfo?
}
