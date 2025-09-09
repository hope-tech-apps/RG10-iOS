//
//  SideMenuView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var authManager = AuthManager.shared
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack {
            // Background overlay
            if isShowing {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
            }
            
            // Side Menu
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Image(AppConstants.Images.logoColor)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                        
                        if authManager.isAuthenticated {
                            Text("Welcome back!")
                                .font(.system(size: 18, weight: .semibold))
                            Text(authManager.currentUser?.email ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            // Sign In / Account
                            if !authManager.isAuthenticated {
                                MenuRowView(
                                    title: LocalizedStrings.signInMenuItem,
                                    icon: Icons.account,
                                    action: {
                                        isShowing = false
                                        coordinator.showLoginSheet = true
                                    }
                                )
                            } else {
                                MenuRowView(
                                    title: "My Account",
                                    icon: Icons.account,
                                    action: {
                                        isShowing = false
                                        // Navigate to account
                                    }
                                )
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // About
                            MenuRowView(
                                title: LocalizedStrings.aboutRG10MenuItem,
                                icon: Icons.infoCircle,
                                action: {
                                    isShowing = false
                                    coordinator.showAboutSheet = true
                                }
                            )
                            
                            // Our Coaches
                            MenuRowView(
                                title: LocalizedStrings.ourTeamTitle,
                                icon: Icons.account,
                                action: {
                                    isShowing = false
                                    coordinator.showStaffSheet = true
                                }
                            )
                            
                            // Merchandise
                            MenuRowView(
                                title: LocalizedStrings.merchStoreMenuItem,
                                icon: Icons.bag1,
                                action: {
                                    isShowing = false
                                    coordinator.showMerchSheet = true
                                }
                            )
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Explore
                            MenuRowView(
                                title: "Explore",
                                icon: Icons.search,
                                action: {
                                    isShowing = false
                                    coordinator.showExploreSheet = true
                                }
                            )
                            
                            // Training
                            MenuRowView(
                                title: "Training",
                                icon: Icons.fire,
                                isDisabled: !authManager.isAuthenticated,
                                action: {
                                    if authManager.isAuthenticated {
                                        isShowing = false
                                        // Navigate to training
                                    }
                                }
                            )
                            
                            // Book Session
                            MenuRowView(
                                title: "Book Session",
                                icon: Icons.bookSession,
                                isDisabled: !authManager.isAuthenticated,
                                action: {
                                    if authManager.isAuthenticated {
                                        isShowing = false
                                        // Navigate to booking
                                    }
                                }
                            )
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Legal
                            MenuRowView(
                                title: "Terms of Service",
                                icon: Icons.termsOfService,
                                action: {
                                    isShowing = false
                                    navigationManager.navigate(to: .termsOfService, in: .home)
                                }
                            )
                            
                            MenuRowView(
                                title: "Privacy Policy",
                                icon: Icons.shield,
                                action: {
                                    isShowing = false
                                    navigationManager.navigate(to: .privacyPolicy, in: .home)
                                }
                            )
                            
                            // Sign Out (if authenticated)
                            if authManager.isAuthenticated {
                                Divider()
                                    .padding(.vertical, 8)
                                
                                MenuRowView(
                                    title: "Sign Out",
                                    icon: Icons.signOut,
                                    iconColor: .red,
                                    action: {
                                        authManager.logout()
                                        isShowing = false
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .background(Color.white)
                .offset(x: isShowing ? 0 : -UIScreen.main.bounds.width)
                .animation(.easeInOut(duration: 0.3), value: isShowing)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}
