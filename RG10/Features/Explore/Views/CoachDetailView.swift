//
//  CoachDetailView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI
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
