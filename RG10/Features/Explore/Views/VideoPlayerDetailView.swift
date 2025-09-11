//
//  VideoPlayerDetailView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct VideoPlayerDetailView: View {
    let video: ExploreVideoItem
    
    var body: some View {
        VStack {
            if let videoID = video.videoID {
                YouTubePlayerView(videoID: videoID)
                    .aspectRatio(16/9, contentMode: .fit)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(video.title)
                    .font(.system(size: 20, weight: .bold))
                
                if let duration = video.duration {
                    Label(duration, systemImage: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .navigationTitle("Video")
        .navigationBarTitleDisplayMode(.inline)
    }
}
