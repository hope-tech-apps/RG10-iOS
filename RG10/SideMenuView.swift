//
//  SideMenuView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

// MARK: - Side Menu
struct SideMenuView: View {
    @Binding var isShowing: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var authManager = AuthManager.shared
    @EnvironmentObject var coordinator: AppCoordinator
    
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
                            IconView(iconName: Icons.hammer, size: 16, color: .gray)
                        }
                        .padding(.trailing, 8)
                        #endif
                        
                        Button(action: { isShowing = false }) {
                            IconView(iconName: Icons.xmark, size: 16, color: .gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    // Alert Banner
                    if showAlert {
                        HStack(spacing: 12) {
                            IconView(iconName: Icons.exclamationMark, size: 16, color: AppConstants.Colors.primaryRed)
                            
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
                            // Auth Menu Items
                            if authManager.isAuthenticated {
                                // User info
                                if let user = authManager.currentUser {
                                    HStack(spacing: 16) {
                                        IconView(iconName: Icons.account, size: 24, color: AppConstants.Colors.primaryRed)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(user.displayName ?? user.username)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.black)
                                            Text(user.email)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    
                                    Divider()
                                        .padding(.horizontal, 24)
                                        .padding(.bottom, 16)
                                }
                                
                                // Logout
                                MenuRowView(title: "Sign Out", icon: Icons.signOut, iconColor: AppConstants.Colors.primaryRed) {
                                    authManager.logout()
                                    isShowing = false
                                }
                            } else {
                                // Sign In / Create Account
                                MenuRowView(title: LocalizedStrings.signInMenuItem, icon: Icons.signIn, iconColor: AppConstants.Colors.primaryRed) {
                                    isShowing = false
                                    coordinator.showLogin()
                                }
                                
                                MenuRowView(title: LocalizedStrings.createAccountMenuItem, icon: Icons.createAccount) {
                                    isShowing = false
                                    coordinator.showLogin()
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                            
                            // Main Menu Items
                            MenuRowView(title: LocalizedStrings.exploreTrainingsMenuItem, icon: Icons.exploreTrainings) {
                                isShowing = false
                            }
                            
                            MenuRowView(title: LocalizedStrings.watchVideosMenuItem, icon: Icons.watchVideos) {
                                isShowing = false
                            }
                            
                            MenuRowView(title: LocalizedStrings.ourCoachesMenuItem, icon: Icons.ourCoaches) {
                                isShowing = false
                            }
                            
                            MenuRowView(title: LocalizedStrings.playerSpotlightsMenuItem, icon: Icons.playerSpotlights) {
                                isShowing = false
                            }
                            
                            MenuRowView(title: LocalizedStrings.merchStoreMenuItem, icon: Icons.merchStore) {
                                isShowing = false
                            }
                            
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                            
                            // User Actions
                            MenuRowView(title: LocalizedStrings.bookSessionMenuItem, icon: Icons.bookSession, isDisabled: !authManager.isAuthenticated) {
                                if authManager.isAuthenticated {
                                    isShowing = false
                                    // Navigate to book session
                                } else {
                                    alertMessage = LocalizedStrings.signInRequiredAlert
                                    showAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showAlert = false
                                    }
                                }
                            }
                            
                            MenuRowView(title: LocalizedStrings.myAppointmentsMenuItem, icon: Icons.myAppointments, isDisabled: !authManager.isAuthenticated) {
                                if authManager.isAuthenticated {
                                    isShowing = false
                                    // Navigate to appointments
                                } else {
                                    alertMessage = LocalizedStrings.signInRequiredAlert
                                    showAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showAlert = false
                                    }
                                }
                            }
                            
                            MenuRowView(title: LocalizedStrings.myPlansMenuItem, icon: Icons.myPlans, isDisabled: !authManager.isAuthenticated) {
                                if authManager.isAuthenticated {
                                    isShowing = false
                                    // Navigate to plans
                                } else {
                                    alertMessage = LocalizedStrings.signInRequiredAlert
                                    showAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showAlert = false
                                    }
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                            
                            // Footer Items
                            MenuRowView(title: LocalizedStrings.aboutRG10MenuItem, icon: Icons.aboutRG10) {
                                isShowing = false
                            }
                            
                            MenuRowView(title: LocalizedStrings.termsOfServiceMenuItem, icon: Icons.termsOfService) {
                                isShowing = false
                            }
                            
                            MenuRowView(title: LocalizedStrings.privacyPolicyMenuItem, icon: Icons.privacyPolicy) {
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
                            IconView(iconName: Icons.xmarkCircleFill, size: 20, color: .white.opacity(0.8))
                        }
                    }
                    
                    Text("Auth Status: \(authManager.isAuthenticated ? "Authenticated" : "Not Authenticated")")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                    
                    if let user = authManager.currentUser {
                        Text("User: \(user.username)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
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
