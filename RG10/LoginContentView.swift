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
                            .accessibilityIdentifier(AccessibilityIdentifiers.usernameField)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Password Field
                    HStack {
                        IconView(iconName: Icons.lock, size: 20, color: .gray)
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.password)
                            .accessibilityIdentifier(AccessibilityIdentifiers.passwordField)
                        IconView(iconName: Icons.eye, size: 20, color: .gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                // Sign In Button
                Button(action: { viewModel.login() }) {
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
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier(AccessibilityIdentifiers.signInButton)
                .padding(.horizontal, 24)
                
                // Forgot Password
                Button(action: { showForgotPassword = true }) {
                    Text("Forgot the password?")
                        .font(.system(size: 14))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
                
                // Sign Up Button
                Button(action: { showSignUp = true }) {
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
                
                // Or Continue With
                VStack(spacing: 16) {
                    Text("or continue with")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                    
                    // Social Login Buttons
                    VStack(spacing: 12) {
                        // Google Sign In
                        Button(action: { handleGoogleSignIn() }) {
                            HStack {
                                Image("google-icon") // You'll need to add this to assets
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Apple Sign In
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.white)
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Social Login Handlers
    private func handleGoogleSignIn() {
        // TODO: Implement Google Sign In
        print("Google Sign In tapped")
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            // TODO: Handle Apple Sign In authorization
            print("Apple Sign In successful")
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
            viewModel.isShowingError = true
        }
    }
}
