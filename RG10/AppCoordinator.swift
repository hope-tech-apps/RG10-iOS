//
//  AppCoordinator.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation
import Combine

class AppCoordinator: ObservableObject {
    enum Screen {
        case loading
        case welcome
        case home
        case login
        case signUp
    }
    
    @Published var currentScreen: Screen = .loading
    @Published var showLoginSheet = false
    @Published var showStaffSheet = false
    @Published var showAboutSheet = false
    @Published var selectedStaff: Int? = 0
    @Published var showExploreSheet = false
    @Published var showMerchSheet = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotifications()
        observeAuthState()
    }
    
    func navigateToWelcome() {
        currentScreen = .welcome
    }
    
    func navigateToHome() {
        currentScreen = .home
    }
    
    func showLogin() {
        showLoginSheet = true
    }
    
    func showExplore() {
        showExploreSheet = true
    }
    
    func showStaff(selectedStaff: Int?) {
        self.selectedStaff = selectedStaff
        showStaffSheet = true
    }
    
    func showAbout() {
        showAboutSheet = true
    }
    
    func showMerch() {
        showMerchSheet = true
    }
    
    func dismissLogin() {
        showLoginSheet = false
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .showLogin)
            .sink { [weak self] _ in
                self?.showLogin()
            }
            .store(in: &cancellables)
    }
    
    private func observeAuthState() {
        AuthManager.shared.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.dismissLogin()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let showLogin = Notification.Name("showLogin")
}
