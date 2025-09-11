//
//  EditProfileView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

// EditProfileView.swift
struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Form {
            Section("Profile Information") {
                TextField("Name", text: .constant(""))
                TextField("Email", text: .constant(""))
                TextField("Phone", text: .constant(""))
            }
            
            Section("Preferences") {
                Toggle("Email Notifications", isOn: .constant(true))
                Toggle("Push Notifications", isOn: .constant(true))
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MyAppointmentsView.swift
struct MyAppointmentsView: View {
    var body: some View {
        List {
            Text("No appointments scheduled")
                .foregroundColor(.gray)
        }
        .navigationTitle("My Appointments")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// PaymentHistoryView.swift
struct PaymentHistoryView: View {
    var body: some View {
        List {
            Text("No payment history")
                .foregroundColor(.gray)
        }
        .navigationTitle("Payment History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// SettingsView.swift
struct SettingsView: View {
    var body: some View {
        Form {
            Section("Account") {
                Label("Change Password", systemImage: "lock")
                Label("Notification Settings", systemImage: "bell")
            }
            
            Section("App") {
                Label("Language", systemImage: "globe")
                Label("App Version: 1.0", systemImage: "info.circle")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// SupportView.swift
struct SupportView: View {
    var body: some View {
        List {
            Section("Contact Us") {
                Label("Email: support@rg10football.com", systemImage: "envelope")
                Label("Phone: (555) 123-4567", systemImage: "phone")
            }
            
            Section("Resources") {
                Label("FAQ", systemImage: "questionmark.circle")
                Label("Training Guides", systemImage: "book")
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ForgotPasswordView.swift
struct ForgotPasswordView: View {
    @State private var email = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Reset Password")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)
            
            Text("Enter your email and we'll send you a link to reset your password")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            
            Button(action: {}) {
                Text("Send Reset Link")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}
