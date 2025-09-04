//
//  TrainingTabView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/31/25.
//

import SwiftUI

struct TrainingTabView: View {
    @AppStorage("isPremium") private var isPremium = false
    @State private var showUpgradeSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    HStack(spacing: 12) {
                        Image("user_avatar") // Assuming you have user avatar
                            .resizable()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                        
                        Image(AppConstants.Images.logoColor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 28)
                    }
                    
                    Spacer()
                    
                    if !isPremium {
                        Button(action: { showUpgradeSheet = true }) {
                            Text("Premium")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.white)
                
                // Content
                ScrollView(showsIndicators: false) {
                    if isPremium {
                        PremiumTrainingContent()
                    } else {
                        NonPremiumTrainingContent(showUpgradeSheet: $showUpgradeSheet)
                    }
                }
                .background(Color(UIColor.systemGray6))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showUpgradeSheet) {
            PremiumUpgradeSheet()
        }
    }
}

// MARK: - Non-Premium Content
struct NonPremiumTrainingContent: View {
    @Binding var showUpgradeSheet: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Unlock Premium Section
            VStack(spacing: 20) {
                // Exercise Illustration
                Image("training_illustration") // Use your actual illustration
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .padding(.top, 40)
                
                Text("Subscribe to unlock full training plans &\nprogress tracking!")
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                
                Button(action: { showUpgradeSheet = true }) {
                    Text("Upgrade to Premium")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                        .frame(width: 200)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppConstants.Colors.primaryRed, lineWidth: 1.5)
                        )
                }
                .padding(.bottom, 20)
            }
            .background(Color.white)
            
            // Camps & Clinics Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Camps & Clinics Section")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CampCard(
                            image: "camp_soccer_ball",
                            title: "2025 Spring Break\nSoccer Camp",
                            dates: "April 14th - 18th, 2025",
                            hasCheckmark: false
                        )
                        
                        CampCard(
                            image: "camp_player",
                            title: "2025 Spring Break\nSoccer Camp",
                            dates: "April 14th - 18th, 2025",
                            hasCheckmark: false
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Page Indicators
                HStack(spacing: 6) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index == 0 ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.3))
                            .frame(width: index == 0 ? 20 : 6, height: 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            
            // Starter Package
            VStack(spacing: 0) {
                // Just For You! Header
                HStack {
                    Text("Just For You!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppConstants.Colors.primaryRed.opacity(0.95))
                
                // Package Content
                ZStack {
                    // Background with player silhouette
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Starter Package")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Foundation Skills Training")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.95))
                            
                            HStack(spacing: 6) {
                                Text("$330")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .strikethrough()
                                
                                Text("300$/month")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 14)
                        
                        Spacer()
                        
                        // Soccer player illustration
                        Image("soccer_player_silhouette")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 80)
                            .opacity(0.5)
                    }
                    .padding(.vertical, 20)
                }
                .background(AppConstants.Colors.primaryRed)
                
                // Browse All Plans Button
                Button(action: {}) {
                    HStack {
                        Text("Browse All Plans")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                }
            }
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Premium Content
struct PremiumTrainingContent: View {
    var body: some View {
        VStack(spacing: 24) {
            // Camps & Clinics Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Camps & Clinics Section")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CampCard(
                            image: "camp_soccer_ball",
                            title: "2025 Spring Break\nSoccer Camp",
                            dates: "April 14th - 18th, 2025",
                            hasCheckmark: true
                        )
                        
                        CampCard(
                            image: "camp_player",
                            title: "2025 Spring Break\nSoccer Camp",
                            dates: "April 14th - 18th, 2025",
                            hasCheckmark: false
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Page Indicators
                HStack(spacing: 6) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == 0 ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            
            // Coach Promotion Card
            VStack(spacing: 0) {
                // Coach Image
                ZStack(alignment: .bottom) {
                    Image("coaches_photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                    
                    // Gradient Overlay
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                
                // Content Overlay
                VStack(spacing: 12) {
                    Text("Ready to take your game to the next level?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Book a private session with our top coaches today 🔥")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button(action: {}) {
                        Text("Book a Private Session")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppConstants.Colors.primaryRed)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Camp Card Component
struct CampCard: View {
    let image: String
    let title: String
    let dates: String
    let hasCheckmark: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 110)
                    .clipped()
                
                if hasCheckmark {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(dates)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(width: 160, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Premium Upgrade Sheet
struct PremiumUpgradeSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // Implementation remains the same as before
        Text("Premium Upgrade")
    }
}

// MARK: - Preview
struct TrainingTabView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingTabView()
    }
}
