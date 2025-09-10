//
//  AuthViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Combine
import UIKit

// MARK: - Auth View Model Protocol
protocol AuthViewModelProtocol: ObservableObject {
    var username: String { get set }
    var email: String { get set }
    var password: String { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var isShowingError: Bool { get set }
    
    func login()
    func register()
    func clearError()
    func openRegistration()
}

// MARK: - Auth View Model
class AuthViewModel: AuthViewModelProtocol {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isShowingError = false
    
    private let authService: AuthServiceProtocol
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()
    let registrationURL = "https://www.oasyssports.com/RG10Football/global-login.cfm"

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
        
        isLoading = true
        errorMessage = nil
        
        authService.login(username: username, password: password)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.showError(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.authManager.saveUser(from: response)
                }
            )
            .store(in: &cancellables)
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
        
        isLoading = true
        errorMessage = nil
        
        authService.register(username: username, email: email, password: password)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.showError(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] response in
                    if response.success, let data = response.data {
                        self?.authManager.saveUser(from: data)
                        // After registration, perform login to get token
                        self?.login()
                    } else {
                        self?.showError(response.message)
                    }
                }
            )
            .store(in: &cancellables)
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
