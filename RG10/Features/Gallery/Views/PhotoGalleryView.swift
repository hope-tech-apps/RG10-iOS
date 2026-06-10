//
//  PhotoGalleryView.swift
//  RG10
//
//  Created by Moneeb Sayed on 2/6/26.
//

import SwiftUI
import Combine

/// A 3-column photo gallery grid.
/// Tapping a photo opens a full-screen viewer with pinch-to-zoom.
struct PhotoGalleryView: View {
    @StateObject private var service = PhotoGalleryService()
    @State private var selectedPhoto: Photo?
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 2),
        count: 3
    )

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            Group {
                if service.isLoading && service.photos.isEmpty {
                    loadingView
                } else if let error = service.errorMessage, service.photos.isEmpty {
                    errorView(error)
                } else if service.photos.isEmpty {
                    emptyView
                } else {
                    galleryGrid
                }
            }
        }
        .navigationTitle("Photo Gallery")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await service.fetchPhotos()
        }
        .refreshable {
            await service.refresh()
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            FullScreenPhotoView(
                photo: photo,
                photos: service.photos
            )
        }
    }

    // MARK: - Gallery Grid

    private var galleryGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(service.photos) { photo in
                    PhotoThumbnail(photo: photo)
                        .onTapGesture {
                            selectedPhoto = photo
                        }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading photos...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await service.refresh() }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppConstants.Colors.primaryRed)
        }
        .padding(40)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            Text("No Photos Yet")
                .font(.title3.weight(.semibold))
            Text("Check back soon for updates!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }
}

// MARK: - Photo Thumbnail Cell

private struct PhotoThumbnail: View {
    let photo: Photo

    var body: some View {
        // Uses Supabase server-side transform: 400x400 cover crop at 70% quality (~15-30KB)
        AsyncImage(url: photo.thumbnailURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .contentShape(Rectangle())
            case .failure:
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.4))
                    }
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .overlay { ProgressView() }
            @unknown default:
                Rectangle().fill(Color.gray.opacity(0.15))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PhotoGalleryView()
    }
}
