//
//  VideoLibraryView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/9/25.
//


import SwiftUI
import Combine

struct VideoLibraryView: View {
    @StateObject private var viewModel = VideoLibraryViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.videos) { video in
                    VideoRow(video: video)
                }
            }
            .padding()
        }
        .navigationTitle("Training Videos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct VideoRow: View {
    let video: YouTubeVideo
    @State private var showingPlayer = false
    
    var body: some View {
        Button(action: { showingPlayer = true }) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                }
                .frame(width: 120, height: 67.5)
                .clipped()
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    if let duration = video.duration {
                        Text(duration)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppConstants.Colors.primaryRed)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingPlayer) {
            YouTubePlayerSheet(video: video)
        }
    }
}

class VideoLibraryViewModel: ObservableObject {
    @Published var videos: [YouTubeVideo] = [
        YouTubeVideo(title: "RG10 Football - Our Journey", url: "https://youtu.be/TlQ8bLELCu8"),
        YouTubeVideo(title: "Training Excellence", url: "https://youtu.be/j4kj-Yrl_uU"),
        YouTubeVideo(title: "Building Champions", url: "https://youtu.be/WBqLygBUPKY")
    ]
}
