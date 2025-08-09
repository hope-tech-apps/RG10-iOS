// MARK: - Recommended Videos Section
struct RecommendedVideosSection: View {
    let videos: [ExploreVideoItem]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended for you")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            // Video Carousel
            TabView(selection: $selectedIndex) {
                ForEach(Array(videos.enumerated()), id: \.element.id) { index, video in
                    VideoCard(video: video)
                        .tag(index)
                        .padding(.horizontal, 20)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 220)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<videos.count, id: \.self) { index in
                    Circle()
                        .fill(index == selectedIndex ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: selectedIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}
