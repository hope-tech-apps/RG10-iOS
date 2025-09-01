//
//  VideoCard.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//

import SwiftUI

struct VideoCard: View {
    let video: ExploreVideoItem
    @State private var showingPlayer = false
    
    var body: some View {
        Button(action: { showingPlayer = true }) {
            ZStack {
                // Thumbnail
                AsyncImage(url: URL(string: video.thumbnailURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primaryRed))
                            )
                    }
                }
                .cornerRadius(16)
                
                // Gradient Overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(16)
                
                // Content Overlay
                VStack {
                    Spacer()
                    
                    // Play Button
                    Image(Icons.play)
                        .renderingMode(.template)
                        .iconStyle(size: 50, color: .white)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                        )
                    
                    Spacer()
                    
                    // Video Info
                    HStack(alignment: .bottom) {
                        Text(video.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if let duration = video.duration {
                            Text(duration)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(4)
                        }
                    }
                    .padding(16)
                }
            }
            .frame(height: 200)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingPlayer) {
            if let videoID = video.videoID {
                YouTubePlayerSheet(
                    video: YouTubeVideo(
                        title: video.title,
                        videoID: videoID,
                        thumbnailURL: video.thumbnailURL,
                        duration: video.duration
                    )
                )
            }
        }
    }
}
