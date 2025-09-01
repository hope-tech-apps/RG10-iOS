//
//  FullScreenYouTubePlayer.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/31/25.
//

import SwiftUI
// MARK: - Full Screen YouTube Player (Alternative)
struct FullScreenYouTubePlayer: View {
    let videoID: String
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            YouTubePlayerView(videoID: videoID)
                .ignoresSafeArea()
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
    }
}

