//
//  YouTubeVideoCard.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/31/25.
//

import SwiftUI

// MARK: - YouTube Video Card
struct YouTubeVideoCard: View {
    let video: YouTubeVideo
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
                            .frame(width: 240, height: 160)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(AppConstants.Colors.primaryRed.opacity(0.1))
                            .frame(width: 240, height: 160)
                            .overlay(
                                Image(Icons.play)
                                    .renderingMode(.template)
                                    .iconStyle(size: 30, color: AppConstants.Colors.primaryRed)
                            )
                    }
                }
                .cornerRadius(12)
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(12)
                
                // Play button overlay
                VStack {
                    Spacer()
                    
                    Image(Icons.play)
                        .renderingMode(.template)
                        .iconStyle(size: 40, color: .white)
                        .background(
                            Circle()
                                .fill(AppConstants.Colors.primaryRed)
                                .frame(width: 60, height: 60)
                        )
                    
                    Spacer()
                    
                    // Title
                    Text(video.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 240, height: 160)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingPlayer) {
            YouTubePlayerSheet(video: video)
        }
    }
}
