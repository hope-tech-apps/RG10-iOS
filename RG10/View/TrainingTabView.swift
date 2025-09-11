//
//  TrainingTabView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/31/25.
//

import SwiftUI

struct TrainingTabView: View {
    @StateObject private var viewModel = TrainingViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                if viewModel.isPremium {
                    PremiumTrainingContent()
                        .environmentObject(viewModel)
                } else {
                    NonPremiumTrainingContent()
                        .environmentObject(viewModel)
                }
            }
            .background(Color(UIColor.systemGray6))
        }
        .sheet(isPresented: $viewModel.showUpgradeSheet) {
            PremiumUpgradeSheet()
                .environmentObject(viewModel)
        }
    }
}

// Update NonPremiumTrainingContent - remove fullScreenCover
struct NonPremiumTrainingContent: View {
    @EnvironmentObject var viewModel: TrainingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Unlock Premium Section
            VStack(spacing: 20) {
                Image("training_illustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .padding(.top, 40)
                
                Text("Register to unlock full training plans!")
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                
                Button(action: viewModel.openRegistration) {
                    Text("Sign up for Training!")
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
            .background(Color.white.ignoresSafeArea())
            
            // Camps & Clinics Section
            CampsAndClinicsSection(camps: viewModel.availableCamps)
                .environmentObject(viewModel)
            
            // Starter Package
            StarterPackageView()
                .environmentObject(viewModel)
            
            // Training Footer
            TrainingFooterView()
                .environmentObject(viewModel)
        }
        // Removed fullScreenCover - navigation now handled by NavigationManager
    }
}
// MARK: - Premium Content View
struct PremiumTrainingContent: View {
    @EnvironmentObject var viewModel: TrainingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Camps & Clinics Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Camps & Clinics Section")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    EmptyCampsView()
                    //                    HStack(spacing: 12) {
//                        CampCard(
//                            image: "camp_soccer_ball",
//                            title: "2025 Spring Break\nSoccer Camp",
//                            dates: "April 14th - 18th, 2025",
//                            hasCheckmark: true
//                        )
//                        
//                        CampCard(
//                            image: "camp_player",
//                            title: "2025 Spring Break\nSoccer Camp",
//                            dates: "April 14th - 18th, 2025",
//                            hasCheckmark: false
//                        )
//                    }
//                    .padding(.horizontal)
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
            CoachPromotionCard()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Camps & Clinics Section
struct CampsAndClinicsSection: View {
    let camps: [CampData]
    @EnvironmentObject var viewModel: TrainingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Camps & Clinics Section")
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal)
            
            if camps.isEmpty {
                // Empty State
                EmptyCampsView()
                    .environmentObject(viewModel)
            } else {
                // Camps Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(camps) { camp in
                            CampCard(
                                image: camp.image,
                                title: camp.title,
                                dates: camp.dates,
                                hasCheckmark: camp.hasCheckmark
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Page Indicators
                HStack(spacing: 6) {
                    ForEach(0..<min(4, camps.count)) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index == 0 ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.3))
                            .frame(width: index == 0 ? 20 : 6, height: 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Empty Camps View
struct EmptyCampsView: View {
    @EnvironmentObject var viewModel: TrainingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Soccer ball icon with animation
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "soccerball")
                    .font(.system(size: 40))
                    .foregroundColor(AppConstants.Colors.primaryRed.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Camps Coming Soon!")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("We're preparing exciting soccer camps for you.\nCheck back soon for updates!")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
//            // Notification button
//            Button(action: viewModel.requestCampNotification) {
//                HStack {
//                    Image(systemName: "bell")
//                        .font(.system(size: 14))
//                    Text("Notify Me")
//                        .font(.system(size: 14, weight: .medium))
//                }
//                .foregroundColor(AppConstants.Colors.primaryRed)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 10)
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(AppConstants.Colors.primaryRed, lineWidth: 1)
//                )
//            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
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
                ZStack(alignment: .bottomLeading) {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 220, height: 274)
                        .clipped()
                        .cornerRadius(13)
                    
                    // Text overlay at bottom
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .background {
                                Color.black.opacity(0.3).blur(radius: 5)
                            }
                        
                        Text(dates)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .background {
                                Color.black.opacity(0.3).blur(radius: 5)
                                    .frame(maxWidth: .infinity)
                            }
                    }
                    .padding()
                }
                
                // Checkmark overlay
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
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Starter Package Component
struct StarterPackageView: View {
    @EnvironmentObject var viewModel: TrainingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Just For You!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(AppConstants.Colors.primaryRed.opacity(0.95))
            
            ZStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Starter Package")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Foundation Skills Training")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.95))
                        
                        Text("$330/month")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 14)
                    
                    Spacer()
                    
                    Image("soccer_player_silhouette")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 143, height: 109)
                        .padding(.trailing, 14)
                }
                .padding(.vertical, 20)
            }
            .background(AppConstants.Colors.primaryRed)
            
            Button(action: viewModel.openTrainingPackages) {
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
    }
}

// MARK: - Training Footer Component
struct TrainingFooterView: View {
    @EnvironmentObject var viewModel: TrainingViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(AppConstants.Images.trainingFooter)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack(spacing: 8) {
                Text("Ready to take your game to the next level?")
                    .font(Font.custom("SF Pro Display", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .stroke(color: .black)
                
                Text("Book a private session with our top coaches today ⚽🔥")
                    .font(
                        Font.custom("SF Pro Display", size: 13)
                            .weight(.semibold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .stroke(color: .black)
                
                Button(action: viewModel.openRegistration) {
                    Text("Book a Private Session")
                        .font(
                            Font.custom("SF Pro Display", size: 13)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 17)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppConstants.Colors.primaryRed)
                        )
                }
                .padding(.bottom, 20)
            }
            .background {
                Color.white.opacity(0.3).blur(radius: 100)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Coach Promotion Card
struct CoachPromotionCard: View {
    @EnvironmentObject var viewModel: TrainingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image("coaches_photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            
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
                
                Button(action: viewModel.openRegistration) {
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

// MARK: - Premium Upgrade Sheet
struct PremiumUpgradeSheet: View {
    @EnvironmentObject var viewModel: TrainingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Crown Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .padding(.top, 60)
                
                // Title & Subtitle
                VStack(spacing: 8) {
                    Text("Go Premium")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Unlock all features and content")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited training plans", color: .green)
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Progress tracking", color: .blue)
                    FeatureRow(icon: "calendar", text: "Priority booking", color: .purple)
                    FeatureRow(icon: "play.rectangle.fill", text: "Exclusive content", color: .orange)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Price & CTA
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("$19.99")
                            .font(.system(size: 36, weight: .bold))
                        Text("per month")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        viewModel.togglePremium()
                        dismiss()
                    }) {
                        Text("Start 7-Day Free Trial")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppConstants.Colors.primaryRed)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 24)
                    
                    Text("Cancel anytime")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                    }
                }
            }
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 16))
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct TrainingTabView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingTabView()
    }
}
