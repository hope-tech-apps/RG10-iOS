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
