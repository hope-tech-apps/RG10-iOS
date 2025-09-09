//
//  SideMenuOverlay.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct SideMenuOverlay: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        navigationManager.showingSideMenu = false
                    }
                }
            
            // Side Menu
            HStack {
                SideMenuContent()
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .background(Color.white)
                    .transition(.move(edge: .leading))
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: navigationManager.showingSideMenu)
    }
}

struct SideMenuContent: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
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
                    // Main Menu Items
                    MenuSection(title: "Main") {
                        SideMenuItem(
                            icon: "house",
                            title: "Home",
                            action: {
                                navigationManager.selectedTab = .home
                                navigationManager.popToRoot()
                                navigationManager.showingSideMenu = false
                            }
                        )
                        
                        SideMenuItem(
                            icon: "figure.run",
                            title: "Training",
                            action: {
                                navigationManager.selectedTab = .training
                                navigationManager.showingSideMenu = false
                            }
                        )
                        
                        SideMenuItem(
                            icon: "calendar",
                            title: "Book Session",
                            action: {
                                navigationManager.selectedTab = .book
                                navigationManager.showingSideMenu = false
                            }
                        )
                        
                        SideMenuItem(
                            icon: "magnifyingglass",
                            title: "Explore",
                            action: {
                                navigationManager.selectedTab = .explore
                                navigationManager.showingSideMenu = false
                            }
                        )
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // About Section
                    MenuSection(title: "About") {
                        SideMenuItem(
                            icon: "info.circle",
                            title: "About RG10",
                            action: {
                                navigationManager.showingSideMenu = false
                                navigationManager.navigate(to: .about, in: .home)
                            }
                        )
                        
                        SideMenuItem(
                            icon: "person.2",
                            title: "Our Coaches",
                            action: {
                                navigationManager.showingSideMenu = false
                                navigationManager.navigate(to: .staff(selectedIndex: nil), in: .home)
                            }
                        )
                        
                        SideMenuItem(
                            icon: "bag",
                            title: "Merchandise",
                            action: {
                                navigationManager.showingSideMenu = false
                                navigationManager.navigate(to: .merchandise, in: .home)
                            }
                        )
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Account Section
                    MenuSection(title: "Account") {
                        if authManager.isAuthenticated {
                            SideMenuItem(
                                icon: "person.circle",
                                title: "My Profile",
                                action: {
                                    navigationManager.showingSideMenu = false
                                    navigationManager.selectedTab = .account
                                }
                            )
                            
                            SideMenuItem(
                                icon: "arrow.right.square",
                                title: "Sign Out",
                                action: {
                                    authManager.logout()
                                    navigationManager.resetNavigation()
                                }
                            )
                        } else {
                            SideMenuItem(
                                icon: "person.badge.plus",
                                title: "Sign In",
                                action: {
                                    navigationManager.showingSideMenu = false
                                    navigationManager.navigate(to: .login, in: .account)
                                }
                            )
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Legal
                    MenuSection(title: "Legal") {
                        SideMenuItem(
                            icon: "doc.text",
                            title: "Terms of Service",
                            action: {
                                navigationManager.showingSideMenu = false
                                navigationManager.navigate(to: .termsOfService, in: .home)
                            }
                        )
                        
                        SideMenuItem(
                            icon: "lock.doc",
                            title: "Privacy Policy",
                            action: {
                                navigationManager.showingSideMenu = false
                                navigationManager.navigate(to: .privacyPolicy, in: .home)
                            }
                        )
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 24)
            
            content
        }
    }
}

struct SideMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
