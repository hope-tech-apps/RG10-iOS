//
//  DownsampledAsyncImage.swift
//  RG10
//
//  Memory-efficient image loading that downsamples at decode time.
//  Prevents full-resolution images from consuming excessive memory.
//

import SwiftUI
import Combine

/// An async image view that downsamples images to the target pixel size during decoding.
/// This prevents a 4000x3000 image from using ~48MB of bitmap memory when only
/// a 130x130 thumbnail is needed (~68KB instead).
struct DownsampledAsyncImage: View {
    let url: URL?
    let targetSize: CGSize
    let contentMode: ContentMode

    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasFailed = false

    init(url: URL?, targetSize: CGSize, contentMode: ContentMode = .fill) {
        self.url = url
        self.targetSize = targetSize
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if hasFailed {
                Image(systemName: "photo")
                    .foregroundColor(.gray.opacity(0.4))
            } else {
                ProgressView()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url else {
            hasFailed = true
            isLoading = false
            return
        }

        // Check memory cache first
        if let cached = ImageDownsampler.shared.cachedImage(for: url, targetSize: targetSize) {
            self.image = cached
            self.isLoading = false
            return
        }

        // Throttle concurrent downloads
        await ImageDownsampler.shared.acquireSlot()
        defer { ImageDownsampler.shared.releaseSlot() }

        do {
            // Download to a temporary file instead of holding Data in memory
            let (tempURL, _) = try await URLSession.shared.download(from: url)

            // Downsample from the file URL on a background thread
            // The file-based approach avoids holding the full JPEG data in memory
            let size = targetSize
            let downsampledImage = await Task.detached(priority: .utility) {
                ImageDownsampler.shared.downsampleFromFile(
                    at: tempURL,
                    to: size,
                    scale: await UIScreen.main.scale,
                    cacheKey: url
                )
            }.value

            // Clean up temp file
            try? FileManager.default.removeItem(at: tempURL)

            if let downsampledImage {
                self.image = downsampledImage
            } else {
                self.hasFailed = true
            }
        } catch {
            self.hasFailed = true
        }

        self.isLoading = false
    }
}

// MARK: - Image Downsampler (with LRU cache + concurrency throttle)

/// Downsamples images at decode time using ImageIO for minimal memory usage.
/// Includes an in-memory LRU cache and limits concurrent downloads.
final class ImageDownsampler: @unchecked Sendable {
    static let shared = ImageDownsampler()

    private let cache = NSCache<NSString, UIImage>()

    /// Semaphore to limit concurrent image downloads (prevents memory spike)
    private let semaphore = DispatchSemaphore(value: 4)

    private init() {
        // Limit cache to ~20MB of decoded thumbnail images
        cache.totalCostLimit = 20 * 1024 * 1024
        cache.countLimit = 60
    }

    /// Acquire a download slot (blocks if > 4 concurrent downloads)
    func acquireSlot() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                self.semaphore.wait()
                continuation.resume()
            }
        }
    }

    /// Release a download slot
    func releaseSlot() {
        semaphore.signal()
    }

    /// Downsample from a file URL (avoids holding raw data in memory).
    func downsampleFromFile(at fileURL: URL, to pointSize: CGSize, scale: CGFloat, cacheKey: URL? = nil) -> UIImage? {
        let key = cacheKeyString(for: cacheKey, targetSize: pointSize)

        // Check cache
        if let key, let cached = cache.object(forKey: key as NSString) {
            return cached
        }

        let maxPixelSize = max(pointSize.width, pointSize.height) * scale

        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false  // Don't cache the full-res source
        ]

        guard let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, sourceOptions as CFDictionary) else {
            return nil
        }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let downsampledCGImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource, 0, downsampleOptions as CFDictionary
        ) else {
            return nil
        }

        let result = UIImage(cgImage: downsampledCGImage)

        // Cache with estimated byte cost
        if let key {
            let byteCost = downsampledCGImage.width * downsampledCGImage.height * 4
            cache.setObject(result, forKey: key as NSString, cost: byteCost)
        }

        return result
    }

    /// Downsample from in-memory data (used when data is already available).
    func downsample(data: Data, to pointSize: CGSize, scale: CGFloat, cacheKey: URL? = nil) -> UIImage? {
        let key = cacheKeyString(for: cacheKey, targetSize: pointSize)

        if let key, let cached = cache.object(forKey: key as NSString) {
            return cached
        }

        let maxPixelSize = max(pointSize.width, pointSize.height) * scale

        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
            return nil
        }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let downsampledCGImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource, 0, downsampleOptions as CFDictionary
        ) else {
            return nil
        }

        let result = UIImage(cgImage: downsampledCGImage)

        if let key {
            let byteCost = downsampledCGImage.width * downsampledCGImage.height * 4
            cache.setObject(result, forKey: key as NSString, cost: byteCost)
        }

        return result
    }

    /// Check if a downsampled version is already cached.
    func cachedImage(for url: URL, targetSize: CGSize) -> UIImage? {
        let key = cacheKeyString(for: url, targetSize: targetSize)
        guard let key else { return nil }
        return cache.object(forKey: key as NSString)
    }

    /// Clear the entire cache.
    func clearCache() {
        cache.removeAllObjects()
    }

    private func cacheKeyString(for url: URL?, targetSize: CGSize) -> String? {
        guard let url else { return nil }
        return "\(url.absoluteString)_\(Int(targetSize.width))x\(Int(targetSize.height))"
    }
}
