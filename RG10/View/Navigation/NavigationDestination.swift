//
//  NavigationDestination.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI
import Combine

// MARK: - Navigation Destinations
enum NavigationDestination: Hashable {
    // Auth
    case login
    case signUp
    case forgotPassword
    
    // Main Content
    case about
    case staff(selectedIndex: Int?)
    case merchandise
    case merchandiseDetail(DBProduct)
    case termsOfService
    case privacyPolicy
    
    // Training
    case trainingPackages
    case campDetail(CampData)
    case workoutDetail(String)
    
    // Explore
    case coachProfile(Coach)
    case videoPlayer(ExploreVideoItem)
    case playerSpotlight(PlayerSpotlight)
    
    // Account
    case editProfile
    case myAppointments
    case paymentHistory
    case settings
    case support
}


class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var homePath = NavigationPath()
    @Published var trainingPath = NavigationPath()
    @Published var bookPath = NavigationPath()
    @Published var explorePath = NavigationPath()
    @Published var accountPath = NavigationPath()
    
    @Published var selectedTab: TabItem = .home
    @Published var showingSideMenu = false
    
    // Navigate to any destination from anywhere
    func navigate(to destination: NavigationDestination, in tab: TabItem? = nil) {
        let targetTab = tab ?? selectedTab
        
        // Switch to the target tab if needed
        if tab != nil {
            selectedTab = targetTab
        }
        
        // Add destination to appropriate path
        switch targetTab {
        case .home:
            homePath.append(destination)
        case .training:
            trainingPath.append(destination)
        case .book:
            bookPath.append(destination)
        case .explore:
            explorePath.append(destination)
        case .account:
            accountPath.append(destination)
        }
    }
    
    // Pop to root of current tab
    func popToRoot() {
        switch selectedTab {
        case .home:
            homePath = NavigationPath()
        case .training:
            trainingPath = NavigationPath()
        case .book:
            bookPath = NavigationPath()
        case .explore:
            explorePath = NavigationPath()
        case .account:
            accountPath = NavigationPath()
        }
    }
    
    // Reset all navigation
    func resetNavigation() {
        homePath = NavigationPath()
        trainingPath = NavigationPath()
        bookPath = NavigationPath()
        explorePath = NavigationPath()
        accountPath = NavigationPath()
        selectedTab = .home
        showingSideMenu = false
    }
}
