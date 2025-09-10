//
//  SignUpView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import SwiftUI
import AuthenticationServices

struct SignUpView<ViewModel: AuthViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Create your Account")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Please fill in the details to create your account")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Username Field
                            HStack {
                                IconView(iconName: Icons.account, size: 20, color: .gray)
                                TextField("Username", text: $viewModel.username)
                                    .autocapitalization(.none)
                                    .textContentType(.username)
                                    .accessibilityIdentifier(AccessibilityIdentifiers.usernameField)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Email Field
                            HStack {
                                IconView(iconName: Icons.mail, size: 20, color: .gray)
                                TextField("Email", text: $viewModel.email)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .accessibilityIdentifier(AccessibilityIdentifiers.emailField)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Password Field
                            HStack {
                                IconView(iconName: Icons.lock, size: 20, color: .gray)
                                SecureField("Password", text: $viewModel.password)
                                    .textContentType(.newPassword)
                                    .accessibilityIdentifier(AccessibilityIdentifiers.passwordField)
                                IconView(iconName: Icons.eye, size: 20, color: .gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        
                        // Sign Up Button
                        Button(action: { Task { await viewModel.register() } }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign Up")
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
                        .accessibilityIdentifier(AccessibilityIdentifiers.signUpButton)
                        .padding(.horizontal, 24)
                        
//                        // Or Continue With
//                        VStack(spacing: 16) {
//                            Text("or continue with")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//                                .padding(.vertical, 8)
//                            
//                            // Social Login Buttons
//                            VStack(spacing: 12) {
//                                // Google Sign In
//                                Button(action: { handleGoogleSignIn() }) {
//                                    HStack {
//                                        Image("google-icon") // You'll need to add this to assets
//                                            .resizable()
//                                            .frame(width: 20, height: 20)
//                                        Text("Continue with Google")
//                                            .font(.system(size: 16, weight: .medium))
//                                            .foregroundColor(.black)
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                    .padding(.vertical, 16)
//                                    .background(Color.white)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 25)
//                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                                    )
//                                }
//                                
//                                // Apple Sign In
//                                SignInWithAppleButton(
//                                    .signUp,
//                                    onRequest: { request in
//                                        request.requestedScopes = [.fullName, .email]
//                                    },
//                                    onCompletion: { result in
//                                        handleAppleSignIn(result)
//                                    }
//                                )
//                                .signInWithAppleButtonStyle(.black)
//                                .frame(height: 50)
//                                .cornerRadius(25)
//                            }
//                            .padding(.horizontal, 24)
//                        }
//                        
//                        Spacer(minLength: 40)
                    }
                }
                
                // Back Button
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                IconView(iconName: Icons.chevronLeft, size: 20, color: .black)
                            }
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        .padding(.leading, 16)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .accessibilityIdentifier(AccessibilityIdentifiers.signUpScreen)
            .alert("Error", isPresented: $viewModel.isShowingError) {
                Button("OK") { Task { await viewModel.clearError() } }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
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
