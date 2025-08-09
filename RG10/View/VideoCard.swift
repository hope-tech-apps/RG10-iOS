struct VideoCard: View {
    let video: ExploreVideoItem
    
    var body: some View {
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
                Button(action: {}) {
                    Image(Icons.play)
                        .renderingMode(.template)
                        .iconStyle(size: 50, color: .white)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                        )
                }
                
                Spacer()
                
                // Video Info
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Video title in")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("brief.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(video.duration)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                }
                .padding(16)
            }
        }
        .frame(height: 200)
    }
}
