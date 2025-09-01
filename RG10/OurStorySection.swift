//
//  OurStorySection.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

// MARK: - Updated Our Story Section
struct OurStorySection: View {
    let videos: [YouTubeVideo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Our story in brief")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(videos) { video in
                        YouTubeVideoCard(video: video)
                    }
                }
            }
        }
    }
}
