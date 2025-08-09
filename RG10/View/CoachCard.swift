struct CoachCard: View {
    let coach: Coach
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    // Coach Image
                    AsyncImage(url: URL(string: coach.imageURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 170)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 170, height: 170)
                                .overlay(
                                    Image(Icons.account)
                                        .renderingMode(.template)
                                        .iconStyle(size: 40, color: .gray)
                                )
                        }
                    }
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // Coach Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(coach.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Text(coach.role)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    .padding(12)
                    .frame(width: 170, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                // Arrow indicator
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 28, height: 28)
                    )
                    .padding(12)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
