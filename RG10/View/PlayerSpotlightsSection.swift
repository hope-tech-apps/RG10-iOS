// MARK: - Player Spotlights Section
struct PlayerSpotlightsSection: View {
    let spotlights: [PlayerSpotlight]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Carousel
            TabView(selection: $selectedIndex) {
                ForEach(Array(spotlights.enumerated()), id: \.element.id) { index, spotlight in
                    PlayerSpotlightCard(spotlight: spotlight)
                        .tag(index)
                        .padding(.horizontal, 20)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 140)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<spotlights.count, id: \.self) { index in
                    Circle()
                        .fill(index == selectedIndex ? Color.black : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: selectedIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.black)
        }
        .background(Color.black)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}
