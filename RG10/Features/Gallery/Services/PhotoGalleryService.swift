//
//  PhotoGalleryService.swift
//  RG10
//
//  Created by Moneeb Sayed on 2/6/26.
//

import Foundation
import Combine
import Supabase

/// Service for fetching gallery photos from Supabase
@MainActor
final class PhotoGalleryService: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var photos: [Photo] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    private let client = SupabaseClientManager.shared.client
    private var hasFetched = false

    // MARK: - Public Methods

    /// Fetch visible photos, ordered by display_order
    func fetchPhotos(forceRefresh: Bool = false) async {
        if !forceRefresh && hasFetched { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await client
                .from("photos")
                .select()
                .eq("is_visible", value: true)
                .order("display_order", ascending: true)
                .execute()

            let decoded = try JSONDecoder().decode([Photo].self, from: response.data)
            photos = decoded
            hasFetched = true

            #if DEBUG
            print("🖼️ Fetched \(decoded.count) gallery photos")
            #endif
        } catch {
            errorMessage = "Unable to load photos."
            #if DEBUG
            print("🖼️ Failed to fetch photos: \(error)")
            #endif
        }

        isLoading = false
    }

    /// Force refresh from network
    func refresh() async {
        await fetchPhotos(forceRefresh: true)
    }
}
