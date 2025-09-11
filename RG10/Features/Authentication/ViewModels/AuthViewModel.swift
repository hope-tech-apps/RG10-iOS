//
//  AuthViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Auth View Model Protocol
protocol AuthViewModelProtocol: ObservableObject {
    var username: String { get set }
    var email: String { get set }
    var password: String { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var isShowingError: Bool { get set }
    
    func login() async
    func register() async
    func clearError() async
    func openRegistration() async
}

// MARK: - Auth View Model
@MainActor
class AuthViewModel: AuthViewModelProtocol {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isShowingError = false
    
    private let authService: AuthServiceProtocol
    private let authManager: AuthManager
    let registrationURL = "https://www.rg10football.com/wp-login.php?action=lostpassword"
    
    init(authService: AuthServiceProtocol = AuthService(),
         authManager: AuthManager = .shared) {
        self.authService = authService
        self.authManager = authManager
    }
    
    // MARK: - Validation
    private var isLoginValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    private var isRegistrationValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Actions
    func openRegistration() {
        if let url = URL(string: registrationURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func login() {
        guard isLoginValid else {
            showError("Please enter username and password")
            return
        }
        
        Task {
            await performLogin()
        }
    }
    
    @MainActor
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.login(username: username, password: password)
            authManager.saveUser(from: response)
        } catch {
            showError(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func register() {
        guard isRegistrationValid else {
            if !isValidEmail(email) {
                showError("Please enter a valid email address")
            } else {
                showError("Please fill in all fields")
            }
            return
        }
        
        Task {
            await performRegistration()
        }
    }
    
    @MainActor
    private func performRegistration() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.register(username: username, email: email, password: password)
            
            if response.success, let data = response.data {
                authManager.saveUser(from: data)
                // After registration, perform login to get token
                await performLogin()
            } else {
                showError(response.message)
            }
        } catch {
            showError(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
        isShowingError = false
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
}
