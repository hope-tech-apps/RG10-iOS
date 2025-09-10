//
//  AboutView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/31/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    private let pillars = [
        (icon: "Shield", title: "Technical Excellence", description: "Professional-level training methodology"),
        (icon: "Lightning", title: "Mental Discipline", description: "Building champions mindset"),
        (icon: "Heart", title: "Character Development", description: "Faith-centered mentorship"),
        (icon: "Star", title: "Real Opportunities", description: "Exposure to professional pathways")
    ]
    
    private let appFeatures = [
        (icon: "Play", title: "Exclusive Training", subtitle: "Access professional programs"),
        (icon: "Chart", title: "Development Plans", subtitle: "Track your progress"),
        (icon: "Users", title: "Pro Advice", subtitle: "Learn from the best"),
        (icon: "Video", title: "Behind the Scenes", subtitle: "Academy insights"),
        (icon: "Location", title: "Global Access", subtitle: "Train from anywhere")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    HeroSection()
                    
                    // Mission Section
                    MissionSection()
                        .padding(.top, -50)
                    
                    // Pillars Section
                    PillarsSection(pillars: pillars)
                    
                    // Stats Section
                    StatsSection()
                    
//                    // App Preview Section
//                    AppPreviewSection(features: appFeatures)
                    
                    // TST Section
                    TSTSection()
                    
                    // Future Section
                    FutureSection()
                    
                    // CTA Section
                    CTASection()
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background Image
            Image(AppConstants.Images.soccerBackground)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack {
                VStack(spacing: 8) {
                    Text("ABOUT")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                    
                    Text("RG10 FOOTBALL")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Building Champions On & Off the Pitch")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Mission Section
struct MissionSection: View {
    var body: some View {
        VStack(spacing: 20) {
            // Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(AppConstants.Images.logoColor)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                    
                    Spacer()
                    
                    Text("EST. 2024")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
                
                Text("Our Mission")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Text("We're building more than just players — we're building people. Founded by professional footballer Rodrigo Gudino, RG10 FC was born from a clear vision: to create a purpose-driven academy where discipline meets character.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
                
                // Highlight Box
                HStack {
                    Image(Icons.fire)
                        .renderingMode(.template)
                        .iconStyle(size: 24, color: AppConstants.Colors.primaryRed)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Year Success")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("50+ players trained • U10 team launched")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Pillars Section
struct PillarsSection: View {
    let pillars: [(icon: String, title: String, description: String)]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Four Pillars of Development")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(pillars, id: \.title) { pillar in
                        PillarCard(
                            icon: pillar.icon,
                            title: pillar.title,
                            description: pillar.description
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 32)
    }
}

struct PillarCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(icon)
                .renderingMode(.template)
                .iconStyle(size: 32, color: .white)
                .padding(16)
                .background(AppConstants.Colors.primaryRed)
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 160)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    var body: some View {
        HStack(spacing: 0) {
            StatItem(number: "50+", label: "Players\nTrained", isHighlighted: true)
            StatItem(number: "4", label: "Development\nPillars", isHighlighted: false)
            StatItem(number: "2026", label: "TST\nTournament", isHighlighted: true)
        }
        .background(Color.black)
    }
}

struct StatItem: View {
    let number: String
    let label: String
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(number)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(isHighlighted ? AppConstants.Colors.primaryRed : .white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(isHighlighted ? Color.white.opacity(0.05) : Color.clear)
    }
}

// MARK: - App Preview Section
struct AppPreviewSection: View {
    let features: [(icon: String, title: String, subtitle: String)]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("RG10 APP")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .tracking(1)
                
                Text("Coming Soon")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Bringing the RG10 experience to players worldwide")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Features Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(features.prefix(4), id: \.title) { feature in
                    FeatureCard(
                        icon: feature.icon,
                        title: feature.title,
                        subtitle: feature.subtitle
                    )
                }
            }
            .padding(.horizontal)
            
            // Coming Soon Badge
            HStack {
                Image("Rocket")
                    .renderingMode(.template)
                    .iconStyle(size: 20, color: .white)
                
                Text("PHASE 1 IN DEVELOPMENT")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .tracking(1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppConstants.Colors.primaryRed)
            .cornerRadius(20)
        }
        .padding(.vertical, 40)
        .background(Color.gray.opacity(0.05))
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(icon)
                .renderingMode(.template)
                .iconStyle(size: 24, color: AppConstants.Colors.primaryRed)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - TST Section
struct TSTSection: View {
    var body: some View {
        VStack(spacing: 0) {
            // Image
            ZStack {
                Rectangle()
                    .fill(AppConstants.Colors.primaryRed)
                    .frame(height: 200)
                
                VStack(spacing: 12) {
                    Text("TST 2026")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("WE'RE COMING")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(2)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                Text("The Soccer Tournament")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("We've officially applied to compete in TST 2026, one of the world's premier 7-v-7 events. This is our chance to showcase RG10 values on a global stage.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
                
                HStack(spacing: 16) {
                    InfoBadge(icon: "Flag", text: "Global Event")
                    InfoBadge(icon: "Star", text: "Elite Competition")
                }
            }
            .padding(24)
            .background(Color.white)
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(icon)
                .renderingMode(.template)
                .iconStyle(size: 16, color: AppConstants.Colors.primaryRed)
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(20)
    }
}

// MARK: - Future Section
struct FutureSection: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("Location")
                .renderingMode(.template)
                .iconStyle(size: 40, color: AppConstants.Colors.primaryRed)
            
            Text("Building Our Future")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Text("Our next goal is a permanent home — a full training facility that reflects the standard we're building.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            ProgressBar(progress: 0.35)
                .padding(.top, 8)
            
            Text("35% towards our goal")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppConstants.Colors.primaryRed)
        }
        .padding(32)
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(AppConstants.Colors.primaryRed)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .cornerRadius(4)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - CTA Section
struct CTASection: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("We're not just here to play the game.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Text("We're here to change it.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryRed)
            }
            
            Text("RG10 Football")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)

            Text("BUILT FOR PURPOSE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .tracking(2)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    AboutView()
}

//
//  ImageExtensions.swift
//  RG10
//
//  Helper extensions for SVG and image handling
//

import SwiftUI

// MARK: - Custom Image Extension for SVGs
extension Image {
    init(icon: String) {
        // Check if it's an SF Symbol (contains dots or specific keywords)
        if icon.contains(".") || icon.contains("figure.run") {
            self.init(systemName: icon)
        } else {
            // It's a custom SVG
            self.init(icon)
        }
    }
}

extension Image {
    func iconStyle(size: CGFloat = 20, color: Color? = nil) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
}
