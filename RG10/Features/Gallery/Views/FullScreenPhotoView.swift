//
//  FullScreenPhotoView.swift
//  RG10
//
//  Created by Moneeb Sayed on 2/6/26.
//

import SwiftUI

/// Full-screen photo viewer with pinch-to-zoom and swipe between photos.
/// Uses Supabase server-side transforms so each image is only ~100-200KB.
struct FullScreenPhotoView: View {
    let photo: Photo
    let photos: [Photo]

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // With server transforms each image is ~100-200KB,
            // so 19 images ≈ 2-4MB total — safe to load all pages.
            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, item in
                    ZoomablePhotoPage(photo: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Overlay: close button + caption + page indicator
            VStack {
                // Top bar
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }

                Spacer()

                // Bottom: caption + counter
                VStack(spacing: 8) {
                    if let title = photos[safe: currentIndex]?.title, !title.isEmpty {
                        Text(title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }

                    if let desc = photos[safe: currentIndex]?.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .shadow(radius: 4)
                    }

                    Text("\(currentIndex + 1) / \(photos.count)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .statusBarHidden()
        .onAppear {
            if let idx = photos.firstIndex(where: { $0.id == photo.id }) {
                currentIndex = idx
            }
        }
    }
}

// MARK: - Zoomable Photo Page

/// A single photo page with pinch-to-zoom and double-tap-to-zoom.
/// Uses a custom image loader that retries on failure (AsyncImage doesn't).
private struct ZoomablePhotoPage: View {
    let photo: Photo

    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadAttempt: Int = 0

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(pinchGesture)
                        .gesture(doubleTapGesture)
                        .gesture(panGesture)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    // Error state with tap-to-retry
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Tap to retry")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .onTapGesture {
                        loadAttempt += 1
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .task(id: loadAttempt) {
            await loadImage()
        }
        .onAppear {
            // Auto-retry if a previous load was cancelled mid-swipe
            if image == nil && !isLoading {
                loadAttempt += 1
            }
        }
    }

    private func loadImage() async {
        guard image == nil, let url = photo.fullScreenURL else { return }

        isLoading = true

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                self.image = uiImage
            }
        } catch is CancellationError {
            // Swipe cancelled the task — onAppear will retry
        } catch {
            // Network error — user can tap to retry
        }

        isLoading = false
    }

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let proposed = lastScale * value
                scale = min(max(proposed, minScale), maxScale)
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    if scale < minScale {
                        scale = minScale
                        offset = .zero
                    }
                }
                lastScale = scale
                if scale == minScale {
                    lastOffset = .zero
                }
            }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if scale > minScale {
                        scale = minScale
                        lastScale = minScale
                        offset = .zero
                        lastOffset = .zero
                    } else {
                        scale = 3.0
                        lastScale = 3.0
                    }
                }
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > minScale else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    FullScreenPhotoView(
        photo: Photo(
            id: "1",
            createdAt: "2026-01-01T00:00:00Z",
            title: "Training Day",
            description: "The team at practice",
            storagePath: "gallery/test.jpg",
            thumbnailPath: nil,
            width: 1920,
            height: 1080,
            displayOrder: 1,
            isVisible: true
        ),
        photos: []
    )
}
