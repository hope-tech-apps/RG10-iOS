//
//  PlayerSpotlightCard.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//


import SwiftUI

struct PlayerSpotlightCard: View {
    let spotlight: PlayerSpotlight
    
    var body: some View {
        HStack(spacing: 16) {
            // Player Image
            AsyncImage(url: URL(string: spotlight.imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(Icons.account)
                                .renderingMode(.template)
                                .iconStyle(size: 30, color: .gray)
                        )
                }
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 6) {
                Text(spotlight.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(spotlight.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {}) {
                    Text("See more")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.black)
    }
}