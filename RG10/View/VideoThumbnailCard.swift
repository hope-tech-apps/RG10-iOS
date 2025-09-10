//
//  VideoThumbnailCard.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

// Video Thumbnail Card
struct VideoThumbnailCard: View {
    let video: ExploreVideoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fill)
                    .overlay(ProgressView())
            }
            .frame(width: 280, height: 157)
            .clipped()
            .cornerRadius(12)
            .overlay(
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            )
            
            Text(video.title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
                .foregroundColor(.black)
            
            if let duration = video.duration {
                Text(duration)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 280)
    }
}

// Detail Views
struct CoachDetailView: View {
    let coach: Coach
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: coach.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(ProgressView())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(coach.name)
                        .font(.system(size: 28, weight: .bold))
                    
                    Text(coach.role)
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    Text("Professional coach with years of experience in developing young talent.")
                        .font(.system(size: 16))
                        .lineSpacing(4)
                        .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle("Coach Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

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

struct PlayerSpotlightDetailView: View {
    let spotlight: PlayerSpotlight
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: spotlight.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(ProgressView())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(spotlight.name)
                        .font(.system(size: 28, weight: .bold))
                    
                    Text(spotlight.description)
                        .font(.system(size: 16))
                        .lineSpacing(4)
                }
                .padding()
            }
        }
        .navigationTitle("Player Spotlight")
        .navigationBarTitleDisplayMode(.inline)
    }
}
