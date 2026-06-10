//
//  Photo.swift
//  RG10
//
//  Created by Moneeb Sayed on 2/6/26.
//

import Foundation

/// Model for gallery photos stored in Supabase
struct Photo: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let createdAt: String
    let title: String?
    let description: String?
    let storagePath: String
    let thumbnailPath: String?
    let width: Int?
    let height: Int?
    let displayOrder: Int
    let isVisible: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case title
        case description
        case storagePath = "storage_path"
        case thumbnailPath = "thumbnail_path"
        case width
        case height
        case displayOrder = "display_order"
        case isVisible = "is_visible"
    }

    // MARK: - Supabase Image Transform URLs
    //
    // Uses Supabase Pro plan image transformations to serve optimized images.
    // Instead of downloading a 5MB original and downsampling on device,
    // the server returns a pre-resized, compressed image (~15-200KB).

    private static let basePath = "\(EnvironmentConfiguration.supabaseURL)/storage/v1"
    private static let bucket = "gallery-photos"

    /// Server-resized thumbnail for the 3-column grid (~15-30KB each)
    var thumbnailURL: URL? {
        transformURL(width: 400, height: 400, resize: "cover", quality: 70)
    }

    /// Screen-sized image for full-screen viewer (~100-200KB)
    var fullScreenURL: URL? {
        transformURL(width: 1200, height: 1200, resize: "contain", quality: 80)
    }

    /// Original full-resolution URL (only for future use like sharing/saving)
    var originalURL: URL? {
        let encoded = storagePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? storagePath
        return URL(string: "\(Self.basePath)/object/public/\(Self.bucket)/\(encoded)")
    }

    /// Builds a Supabase image transform URL
    private func transformURL(width: Int, height: Int, resize: String, quality: Int) -> URL? {
        let encoded = storagePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? storagePath
        return URL(string: "\(Self.basePath)/render/image/public/\(Self.bucket)/\(encoded)?width=\(width)&height=\(height)&resize=\(resize)&quality=\(quality)")
    }

    /// Aspect ratio for layout, defaults to square
    var aspectRatio: CGFloat {
        guard let w = width, let h = height, h > 0 else { return 1.0 }
        return CGFloat(w) / CGFloat(h)
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
