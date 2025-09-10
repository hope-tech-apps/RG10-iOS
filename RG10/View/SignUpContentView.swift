//
//  SignUpContentView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import SwiftUI
import AuthenticationServices

struct SignUpContentView<ViewModel: AuthViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var showSignUp: Bool
    @State private var isPasswordVisible = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Back to Login Button
                HStack {
                    Button(action: { showSignUp = false }) {
                        HStack(spacing: 4) {
                            IconView(iconName: Icons.chevronLeft, size: 20, color: .black)
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Header
                VStack(spacing: 8) {
                    Text("Create your Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Please fill in the details to create your account")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
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
                                .textContentType(.newPassword)
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
                
                // Sign Up Button
                Button(action: { viewModel.register() }) {
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
                .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty)
                .accessibilityIdentifier(AccessibilityIdentifiers.signUpButton)
                .padding(.horizontal, 24)
                
                // Already have an account?
                HStack {
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: { showSignUp = false }) {
                        Text("Sign In")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppConstants.Colors.primaryRed)
                    }
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.white)
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}

// MARK: - Preview
struct SignUpContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpContentView(
            viewModel: AuthViewModel(),
            showSignUp: .constant(true)
        )
    }
}
