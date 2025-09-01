//
//  YouTubePlayerSheet.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/31/25.
//

import SwiftUI

// MARK: - YouTube Player Sheet
struct YouTubePlayerSheet: View {
    let video: YouTubeVideo
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Player
                    YouTubePlayerView(videoID: video.videoID)
                        .aspectRatio(16/9, contentMode: .fit)
                        .background(Color.black)
                    
                    // Video info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(video.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(AppConstants.Images.logoColor)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text("RG10 FOOTBALL")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.primaryRed)
                }
            }
        }
    }
}
