//
//  YouTubePlaylistItem.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//


import Foundation
import Combine

struct YouTubePlaylistItem: Codable {
    let snippet: YouTubeSnippet
    let contentDetails: YouTubeContentDetails?
}
