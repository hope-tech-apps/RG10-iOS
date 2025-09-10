//
//  LoginContentView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/23/25.
//

import SwiftUI
import AuthenticationServices

struct LoginContentView<ViewModel: AuthViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var showSignUp: Bool
    @State private var showForgotPassword = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Login")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Please sign in to your existing account")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Form Fields
                VStack(spacing: 16) {
                    // Email/Username Field
                    HStack {
                        IconView(iconName: Icons.mail, size: 20, color: .gray)
                        TextField("Email", text: $viewModel.username)
                            .autocapitalization(.none)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .accessibilityIdentifier(AccessibilityIdentifiers.usernameField)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Password Field with visibility toggle
                    HStack {
                        IconView(iconName: Icons.lock, size: 20, color: .gray)
                        
                        if isPasswordVisible {
                            TextField("Password", text: $viewModel.password)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                                .textContentType(.oneTimeCode)
                                .accessibilityIdentifier(AccessibilityIdentifiers.passwordField)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                                .accessibilityIdentifier(AccessibilityIdentifiers.passwordField)
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            IconView(
                                iconName: isPasswordVisible ? Icons.eye : Icons.hide,
                                size: 20,
                                color: .gray
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                // Sign In Button
                Button(action: { Task { await viewModel.login() }}) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(25)
                }
                .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.password.isEmpty)
                .accessibilityIdentifier(AccessibilityIdentifiers.signInButton)
                .padding(.horizontal, 24)
                
                // Forgot Password
                Button(action: {
                    showForgotPassword = true
                }) {
                    Text("Forgot the password?")
                        .font(.system(size: 14))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
                
                // Sign Up Button
                Button(action: {
                    showSignUp = true
                }) {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.signUpButton)
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.white)
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {
                Task { await viewModel.clearError() }
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

// MARK: - Preview
struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginContentView(
            viewModel: AuthViewModel(),
            showSignUp: .constant(false)
        )
    }
}
