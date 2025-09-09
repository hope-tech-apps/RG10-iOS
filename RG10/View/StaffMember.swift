//
//  StaffView.swift
//  RG10
//
//  Staff page with professional design matching RG10 brand
//


import SwiftUI

import SwiftUI

struct StaffMember: Identifiable {
    let id = UUID()
    let name: String
    let position: String
    let mainImageURL: String
    let additionalImages: [String]
    let bio: [String]
    let subheading: String?
    let subContent: [String]?
    let achievements: [String]? // Added for highlighting key achievements
}

struct StaffView: View {
    var selectedIndex: Int? = nil // Pass this as parameter instead of using coordinator
    private let staffMembers: [StaffMember] = [
        StaffMember(
            name: "Rodrigo Gudino",
            position: "Head Coach & CEO",
            mainImageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/207C2DC5-1B43-48C0-BEA2-C436CCBC45F1.jpeg",
            additionalImages: [
                "https://www.rg10football.com/wp-content/uploads/2025/07/DSC9911.jpeg",
                "https://www.rg10football.com/wp-content/uploads/2025/07/P1044125-rotated.jpeg"
            ],
            bio: [
                "Rodrigo Gudino is a professional footballer and dedicated coach with a passion for player development and mentorship. Born in Mexico City and raised in North Carolina, he began his journey with NC Fusion before continuing his collegiate career at Guilford College, laying the foundation for a path defined by discipline, resilience, and growth.",
                "Rodrigo's professional career has taken him across North America, where he has played for Inter Playa del Carmen, Chicago House AC, and Grove United, while also earning opportunities with top tier clubs. In 2019, he had trials with Querétaro FC U20s, and in 2021, he spent time with FC Juárez. In 2024, Rodrigo was selected to represent the USA 7v7 National Team at the Nations League Sevens in Colombia, competing internationally and showcasing his leadership on a national stage.",
                "His exposure to different playing styles, competitive environments, and high performance systems has shaped his holistic approach to training and mentorship.",
                "As the founder of RG10 Football, Rodrigo is committed to developing the next generation of players through elite level coaching, technical training, and a mindset rooted in professionalism. His mission is to help young footballers refine their craft, understand the game on a deeper level, and unlock their full potential both on and off the pitch.",
                "Through RG10 Football, Rodrigo shares his journey and experience to ensure that every player is equipped with the tools, structure, and belief they need to grow in football and in life.",
                "Rodrigo started RG10 Football to create the opportunities he never had growing up.",
                "His purpose is to uplift his community, give young players access to real development, and build a system that focuses on purpose, excellence, and belief.",
                "RG10 is not just training. It is transformation."
            ],
            subheading: nil,
            subContent: nil,
            achievements: [
                "USA 7v7 National Team",
                "Professional Footballer",
                "RG10 Founder",
                "Elite Coach"
            ]
        ),
        StaffMember(
            name: "Aryan Kamdar",
            position: "RG10 Football Coach (Chicago)",
            mainImageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/Aryan2-683x1024.jpeg",
            additionalImages: [
                "https://www.rg10football.com/wp-content/uploads/2025/07/Aryan1-scaled.jpg"
            ],
            bio: [
                "I'm a semi-professional footballer and dedicated youth coach with a passion for helping players unlock their full potential, on and off the pitch. Born and raised in Bangalore, India and now based in Chicago, I've lived the game from the ground up. My playing journey began in the U18 I-League with Boca Juniors Academy India and continued in the U.S. with Chicago City SC, eventually earning a spot with Chicago House AC.",
                "With House, I've had the opportunity to compete against top-tier opponents, including MLS NEXT Pro sides like Chicago Fire II, USL League One clubs like Forward Madison, NCAA Division I programs (Northwestern, UIC, Marquette, DePaul), and some of the best amateur teams in the country.",
                "But my path hasn't been easy or typical. I didn't come up through elite academy systems, and I was often overlooked. That experience shaped my mentality. It taught me how to work relentlessly, stay grounded, and fight for every opportunity. That chip on my shoulder became fuel, and I bring that same hunger, intensity, and drive into every training session I lead. I coach with purpose, discipline, and deep care for each player's growth.",
                "My love for coaching began in local communities, helping younger players grow in skill and confidence. Seeing them fall in love with the game the way I did, that's when I knew coaching was more than just a side role. It became my mission. I believe in giving every player, regardless of background, the attention, mentorship, and tools they need to succeed. In a system often driven by pay-to-play, I aim to be the exception: a coach who's focused on authentic development and genuine impact."
            ],
            subheading: "Why I'm Joining RG10 Football",
            subContent: [
                "I'm joining RG10 Football because its mission aligns with everything I stand for. After speaking with Rodrigo, it was clear this is more than just another academy—it's a movement. A place built on purpose, discipline, player development, and accessibility. It's exactly the kind of environment where I want to grow, give back, and help shape the next generation of athletes.",
                "I'm excited to be part of the RG10 family and to bring the vision to life here in Chicago.",
                "Let's build.",
                "–Aryan Kamdar"
            ],
            achievements: [
                "Chicago House AC",
                "Boca Juniors Academy",
                "Youth Coach",
                "Chicago City SC"
            ]
        )
    ]
    
    @State private var currentSelectedIndex: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Header - show only if no initial selection
                if selectedIndex == nil && currentSelectedIndex == nil {
                    StaffHeroHeader()
                    // Staff Selector Tabs
                    StaffSelectorTabs(
                        staffMembers: staffMembers,
                        selectedIndex: $currentSelectedIndex
                    )
                } else {
                    // Direct to staff member if navigated from coaches
                    let index = selectedIndex ?? currentSelectedIndex ?? 0
                    if index < staffMembers.count {
                        StaffMemberDetail(
                            member: staffMembers[index]
                        )
                    }
                }
            }
        }
        .navigationTitle("Our Coaches")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Set initial selection if provided
            if let index = selectedIndex {
                currentSelectedIndex = index
            }
        }
    }
}

// MARK: - Hero Header
struct StaffHeroHeader: View {
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.black)
                .frame(height: 200)
            
            // Pattern overlay
            GeometryReader { geometry in
                ForEach(0..<5, id: \.self) { row in
                    ForEach(0..<8, id: \.self) { col in
                        Image(Icons.shield)
                            .renderingMode(.template)
                            .iconStyle(size: 30, color: .white.opacity(0.05))
                            .position(
                                x: CGFloat(col) * 60 + 30,
                                y: CGFloat(row) * 60 + 30
                            )
                    }
                }
            }
            .frame(height: 200)
            
            // Content
            VStack(spacing: 8) {
                Text("OUR TEAM")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .tracking(2)
                
                Text("Meet the Coaches")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Dedicated to Building Champions")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 40)
        }
        .frame(height: 200)
    }
}

// MARK: - Staff Selector Tabs
struct StaffSelectorTabs: View {
    let staffMembers: [StaffMember]
    @Binding var selectedIndex: Int?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(staffMembers.enumerated()), id: \.element.id) { index, member in
                    StaffTab(
                        name: member.name,
                        position: member.position,
                        isSelected: index == selectedIndex
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct StaffTab: View {
    let name: String
    let position: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(name)
                    .font(.system(size: 16, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? AppConstants.Colors.primaryRed : .black)
                
                Text(position)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? AppConstants.Colors.primaryRed.opacity(0.8) : .gray)
                    .lineLimit(1)
                
                // Selection indicator - more prominent
                Capsule()
                    .fill(AppConstants.Colors.primaryRed)
                    .frame(width: isSelected ? 40 : 0, height: 3)
                    .opacity(isSelected ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppConstants.Colors.primaryRed.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppConstants.Colors.primaryRed.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Staff Member Detail
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

// MARK: - Achievements Section
struct AchievementsSection: View {
    let achievements: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(achievements, id: \.self) { achievement in
                    AchievementBadge(text: achievement)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .background(Color.gray.opacity(0.05))
    }
}

struct AchievementBadge: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(Icons.star)
                .renderingMode(.template)
                .iconStyle(size: 16, color: AppConstants.Colors.primaryRed)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Bio Section
struct BioSection: View {
    let bio: [String]
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Biography")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 16) {
                // Show first 2 paragraphs by default, all if expanded
                ForEach(Array(bio.prefix(isExpanded ? bio.count : 2).enumerated()), id: \.offset) { index, paragraph in
                    Text(paragraph)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            if bio.count > 2 {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Text(isExpanded ? "Show Less" : "Read More")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppConstants.Colors.primaryRed)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppConstants.Colors.primaryRed)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 32)
    }
}

// MARK: - Image Gallery Section
struct ImageGallerySection: View {
    let images: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gallery")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(images, id: \.self) { imageURL in
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else if phase.error != nil {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 200, height: 250)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 200, height: 250)
                                    .overlay(ProgressView())
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - Sub Content Section
struct SubContentSection: View {
    let heading: String
    let content: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with icon
            HStack(spacing: 12) {
                Image(Icons.fire)
                    .renderingMode(.template)
                    .iconStyle(size: 24, color: AppConstants.Colors.primaryRed)
                
                Text(heading)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(content, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 32)
    }
}

// MARK: - Preview
#Preview {
    StaffView()
}
