//
//  StaffMemberDetail.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct StaffMemberDetail: View {
    let member: StaffMember
    @State private var selectedImageIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Image Section
            ZStack {
                
                // Main image
                AsyncImage(url: URL(string: member.mainImageURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 350)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    } else if phase.error != nil {
                        Color.gray
                            .frame(height: 350)
                            .cornerRadius(16)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                    } else {
                        ProgressView()
                            .frame(height: 350)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 400)
            
            // Achievements Section
            if let achievements = member.achievements {
                AchievementsSection(achievements: achievements)
            }
            
            // Bio Section
            BioSection(bio: member.bio)
            
            // Additional Images Gallery
            if !member.additionalImages.isEmpty {
                ImageGallerySection(images: member.additionalImages)
            }
            
            // Sub Content Section
            if let subheading = member.subheading, let subContent = member.subContent {
                SubContentSection(heading: subheading, content: subContent)
            }
        }
    }
}
