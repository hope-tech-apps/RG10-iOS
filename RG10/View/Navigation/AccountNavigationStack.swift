//
//  AccountNavigationStack.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct AccountNavigationStack: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationManager.accountPath) {
            if authManager.isAuthenticated {
                AccountMainView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            } else {
                LoginMainView()
                    .environmentObject(authViewModel)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        authDestinationView(for: destination)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .editProfile:
            EditProfileView()
        case .myAppointments:
            MyAppointmentsView()
        case .paymentHistory:
            PaymentHistoryView()
        case .settings:
            SettingsView()
        case .support:
            SupportView()
        case .termsOfService:
            TermsOfServiceView()
        case .privacyPolicy:
            PrivacyPolicyView()
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func authDestinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .signUp:
            SignUpMainView()
                .environmentObject(authViewModel)
        case .forgotPassword:
            ForgotPasswordView()
                .environmentObject(authViewModel)
        default:
            EmptyView()
        }
    }
}

// Login Main View (NavigationStack compatible)
struct LoginMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo
                Image(AppConstants.Images.logoColor)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, 60)
                
                // Login Form
                VStack(spacing: 20) {
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                    
                    VStack(spacing: 16) {
                        // Email Field
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("Email", text: $authViewModel.email)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Password Field
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("Password", text: $authViewModel.password)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Sign In Button
                    Button(action: { authViewModel.login() }) {
                        Text("Sign In")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppConstants.Colors.primaryRed)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Links
                    HStack {
                        Button("Forgot Password?") {
                            navigationManager.navigate(to: .forgotPassword)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button("Sign Up") {
                            navigationManager.navigate(to: .signUp)
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Sign Up Main View
struct SignUpMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    // Username Field
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                        TextField("Username", text: $authViewModel.username)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Email Field
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $authViewModel.email)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Password Field
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $authViewModel.password)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Sign Up Button
                Button(action: { authViewModel.register() }) {
                    Text("Sign Up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppConstants.Colors.primaryRed)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Account Main View (Authenticated)
// AccountMainView.swift
struct AccountMainView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        List {
            // Profile Section
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        Text(authManager.currentUser?.username ?? "User")
                            .font(.headline)
                        Text(authManager.currentUser?.email ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .onTapGesture {
                    navigationManager.navigate(to: .editProfile)
                }
            }
            
            // Menu Items
            Section("Training") {
                NavigationLink(value: NavigationDestination.myAppointments) {
                    Label("My Appointments", systemImage: "calendar")
                }
                
//                NavigationLink(value: NavigationDestination.paymentHistory) {
//                    Label("Payment History", systemImage: "creditcard")
//                }
            }
            
            Section("Settings") {
                NavigationLink(value: NavigationDestination.settings) {
                    Label("Settings", systemImage: "gear")
                }
                
                NavigationLink(value: NavigationDestination.support) {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }
            }
            
            Section("Legal") {
                NavigationLink(value: NavigationDestination.termsOfService) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
                
                NavigationLink(value: NavigationDestination.privacyPolicy) {
                    Label("Privacy Policy", systemImage: "lock.doc")
                }
            }
            
            Section {
                Button(action: {
                    // Use the correct method name from AuthManager
                    authManager.logout() // or whatever the method is called
                    navigationManager.resetNavigation()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
    }
}
