//
//  YouTubeThumbnails.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//


import Foundation
import Combine

struct YouTubeThumbnails: Codable {
    let `default`: YouTubeThumbnail?
    let medium: YouTubeThumbnail?
    let high: YouTubeThumbnail?
    let standard: YouTubeThumbnail?
    let maxres: YouTubeThumbnail?
}
