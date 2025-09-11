//
//  YouTubeSnippet.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//


import Foundation
import Combine

struct YouTubeSnippet: Codable {
    let title: String
    let description: String
    let thumbnails: YouTubeThumbnails
    let resourceId: YouTubeResourceId?
    let publishedAt: String?
}
