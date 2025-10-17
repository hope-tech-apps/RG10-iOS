//
//  AuthViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Auth View Model Protocol (unchanged)
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

// MARK: - Auth View Model (Supabase)
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
    func openRegistration() async {
        // For Supabase, we can trigger password reset
        if isValidEmail(username) {
            do {
                try await authService.resetPassword(email: username)
                showError("Password reset link sent to your email")
            } catch {
                showError("Failed to send password reset email")
            }
        } else if let url = URL(string: registrationURL) {
            await MainActor.run {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func login() async {
        guard isLoginValid else {
            showError("Please enter username/email and password")
            return
        }
        
        await performLogin()
    }
    
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // If username contains @, treat it as email, otherwise try username-based login
            let loginIdentifier = username.contains("@") ? username : username
            
            // Use the auth service for compatibility with existing code
            let response = try await authService.login(username: loginIdentifier, password: password)
            
            // The AuthManager will be updated automatically through auth state listener
            // But we can also manually trigger if needed
            if !username.contains("@") {
                // If logging in with username, we might need to sign in again with the actual email
                try await authManager.signIn(email: response.userEmail, password: password)
            } else {
                try await authManager.signIn(email: username, password: password)
            }
            
            clearFields()
        } catch {
            showError(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func register() async {
        guard isRegistrationValid else {
            if !isValidEmail(email) {
                showError("Please enter a valid email address")
            } else {
                showError("Please fill in all fields")
            }
            return
        }
        
        await performRegistration()
    }
    
    private func performRegistration() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.register(
                username: username,
                email: email,
                password: password
            )
            
            if response.success {
                // For Supabase, we might need to wait for email confirmation
                if response.message.contains("confirm") {
                    showError(response.message)
                    clearFields()
                } else {
                    // Auto-login after successful registration
                    try await authManager.signIn(email: email, password: password)
                    clearFields()
                }
            } else {
                showError(response.message)
            }
        } catch {
            showError(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func clearError() async {
        errorMessage = nil
        isShowingError = false
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
    
    private func clearFields() {
        username = ""
        email = ""
        password = ""
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Reset Password")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Enter your email address and we'll send you a link to reset your password")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Button(action: {
                    Task {
                        await resetPassword()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Reset Link")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppConstants.Colors.primaryRed)
                .cornerRadius(25)
                .padding(.horizontal, 24)
                .disabled(email.isEmpty || isLoading)
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .alert("Password Reset", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("sent") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func resetPassword() async {
        isLoading = true
        
        do {
            try await AuthManager.shared.resetPassword(email: email)
            alertMessage = "Password reset link has been sent to your email"
            showAlert = true
        } catch {
            alertMessage = "Failed to send reset link. Please check your email address."
            showAlert = true
        }
        
        isLoading = false
    }
}
