//
//  SideMenu.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

// MARK: - Side Menu
struct SideMenu: View {
    @Binding var isShowing: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    #if DEBUG
    @State private var showDevelopmentInfo = false
    #endif
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Image(AppConstants.Images.logoColor)
                            .resizable()
                            .scaledToFit()
                            .frame(height: AppConstants.Sizes.logoSideMenuHeight)
                        
                        Spacer()
                        
                        #if DEBUG
                        Button(action: { showDevelopmentInfo.toggle() }) {
                            Image(systemName: Icons.hammer)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                        #endif
                        
                        Button(action: { isShowing = false }) {
                            Image(systemName: Icons.xmark)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    // Alert Banner
                    if showAlert {
                        HStack(spacing: 12) {
                            Image(systemName: Icons.exclamationMark)
                                .font(.system(size: 16))
                                .foregroundColor(AppConstants.Colors.primaryRed)
                            
                            Text(alertMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .lineLimit(2)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppConstants.Colors.alertBackground)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Main Menu Items
                            MenuRow(title: LocalizedStrings.signInMenuItem, icon: Icons.signIn, iconColor: AppConstants.Colors.primaryRed) {
                                // Handle sign in
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.createAccountMenuItem, icon: Icons.createAccount) {
                                // Handle create account
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.exploreTrainingsMenuItem, icon: Icons.exploreTrainings) {
                                // Handle explore trainings
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.watchVideosMenuItem, icon: Icons.watchVideos) {
                                // Handle watch videos
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.ourCoachesMenuItem, icon: Icons.ourCoaches) {
                                // Handle our coaches
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.playerSpotlightsMenuItem, icon: Icons.playerSpotlights) {
                                // Handle player spotlights
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.merchStoreMenuItem, icon: Icons.merchStore) {
                                // Handle merch store
                                isShowing = false
                            }
                            
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                            
                            // User Actions (Disabled until signed in)
                            MenuRow(title: LocalizedStrings.bookSessionMenuItem, icon: Icons.bookSession, isDisabled: true) {
                                alertMessage = LocalizedStrings.signInRequiredAlert
                                showAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showAlert = false
                                }
                            }
                            
                            MenuRow(title: LocalizedStrings.myAppointmentsMenuItem, icon: Icons.myAppointments, isDisabled: true) {
                                alertMessage = LocalizedStrings.signInRequiredAlert
                                showAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showAlert = false
                                }
                            }
                            
                            MenuRow(title: LocalizedStrings.myPlansMenuItem, icon: Icons.myPlans, isDisabled: true) {
                                alertMessage = LocalizedStrings.signInRequiredAlert
                                showAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showAlert = false
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                            
                            // Footer Items
                            MenuRow(title: LocalizedStrings.aboutRG10MenuItem, icon: Icons.aboutRG10) {
                                // Handle about
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.termsOfServiceMenuItem, icon: Icons.termsOfService) {
                                // Handle terms
                                isShowing = false
                            }
                            
                            MenuRow(title: LocalizedStrings.privacyPolicyMenuItem, icon: Icons.privacyPolicy) {
                                // Handle privacy
                                isShowing = false
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .background(Color.white)
                
                Spacer()
            }
            
            #if DEBUG
            // Development Info Overlay
            if showDevelopmentInfo {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Development")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { showDevelopmentInfo = false }) {
                            Image(systemName: Icons.xmarkCircleFill)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Text("The notification appears when the user clicks on a closed section before logging in/registering.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Corner radius")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                            Text("10px")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Component")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Unclearred: 0.97...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Status")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Status=Error, Component=Alert")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(16)
                .background(AppConstants.Colors.developmentOverlay)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .offset(y: -100)
            }
            #endif
        }
        .transition(.move(edge: .leading))
        .animation(.easeInOut(duration: 0.3), value: isShowing)
    }
}
