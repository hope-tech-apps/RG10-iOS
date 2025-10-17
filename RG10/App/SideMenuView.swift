//
//  SideMenuView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @ObservedObject var authManager = AuthManager.shared
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showingBookingWebView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Image(AppConstants.Images.logoColor)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                if authManager.isAuthenticated {
                    Text("Hello \(authManager.currentUser?.username ?? "")!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppConstants.Colors.primaryRed)
                    Text(authManager.currentUser?.email ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemGray6))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Account Section
                    if !authManager.isAuthenticated {
                        Group {
                            MenuRowView(
                                title: "Sign In",
                                icon: Icons.signIn,
                                iconColor: AppConstants.Colors.primaryRed,
                                action: {
                                    isShowing = false
                                    navigationManager.selectedTab = .account
                                }
                            )
                            
//                            MenuRowView(
//                                title: "Create Account",
//                                icon: Icons.createAccount,
//                                action: {
//                                    isShowing = false
//                                    navigationManager.selectedTab = .account
//                                }
//                            )
                        }
                        
                        SectionDivider()
                    }
                    
                    // Explore Section
                    Group {
                        MenuRowView(
                            title: "Explore Trainings",
                            icon: Icons.compass,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .trainingPackages, in: .home)
                            }
                        )
                        
                        MenuRowView(
                            title: "Watch Videos",
                            icon: Icons.play,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .videoLibrary, in: .home)
                            }
                        )
                        
                        MenuRowView(
                            title: "Our Coaches",
                            icon: Icons.ourCoaches,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .staff(selectedIndex: nil), in: .home)
                            }
                        )
                        
//                        MenuRowView(
//                            title: "Player Spotlights",
//                            icon: Icons.playerSpotlights,
//                            action: {
//                                isShowing = false
//                                navigationManager.navigate(to: .playerSpotlights, in: .home)
//                            }
//                        )
                        
                        MenuRowView(
                            title: "Merch Store",
                            icon: Icons.cart,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .merchandise, in: .home)
                            }
                        )
                    }
                    
                    // User Section (if authenticated)
                    if authManager.isAuthenticated {
                        SectionDivider()
                        
                        MenuRowView(
                            title: "Book a Session",
                            icon: Icons.bookmark,
                            action: {
                                isShowing = false
                                showingBookingWebView = true
                            }
                        )
                        
                        MenuRowView(
                            title: "My Appointments",
                            icon: Icons.myAppointments,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .myAppointments, in: .account)
                            }
                        )
                        
                        MenuRowView(
                            title: "My Plans",
                            icon: Icons.rocket,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .myPlans, in: .account)
                            }
                        )
                    }
                    
                    SectionDivider()
                    
                    // About Section
                    Group {
                        MenuRowView(
                            title: "About RG10",
                            icon: Icons.aboutRG10,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .about, in: .home)
                            }
                        )
                        
                        MenuRowView(
                            title: "Terms of Service",
                            icon: Icons.shield,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .termsOfService, in: .home)
                            }
                        )
                        
                        MenuRowView(
                            title: "Privacy Policy",
                            icon: Icons.privacyPolicy,
                            action: {
                                isShowing = false
                                navigationManager.navigate(to: .privacyPolicy, in: .home)
                            }
                        )
                    }
                    
                    // Sign Out (if authenticated)
                    if authManager.isAuthenticated {
                        SectionDivider()
                        
                        MenuRowView(
                            title: "Sign Out",
                            icon: Icons.signOut,
                            iconColor: .red,
                            action: {
                                authManager.logout()
                                navigationManager.resetNavigation()
                                isShowing = false
                            }
                        )
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .sheet(isPresented: $showingBookingWebView) {
            BookingView()
        }
    }
}

struct SectionDivider: View {
    var body: some View {
        Divider()
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
    }
}
