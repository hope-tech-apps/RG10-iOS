//
//  ResetPasswordView.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/18/26.
//

import SwiftUI

/// View for resetting password after clicking the deep link from email.
/// This is shown when the app receives `rg10://deep-link?code=<UUID>&type=recovery`
struct ResetPasswordView: View {
    let recoveryCode: String
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Password validation
    private var isPasswordValid: Bool {
        newPassword.count >= 6
    }
    
    private var doPasswordsMatch: Bool {
        newPassword == confirmPassword && !confirmPassword.isEmpty
    }
    
    private var canSubmit: Bool {
        isPasswordValid && doPasswordsMatch && !isLoading
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Password Fields
                    passwordFieldsSection
                    
                    // Password Requirements
                    passwordRequirementsSection
                    
                    // Submit Button
                    submitButton
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
        .interactiveDismissDisabled(isLoading)
        .onAppear {
            print("🔐 ResetPasswordView appeared with code: \(recoveryCode.prefix(8))...")
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 60))
                .foregroundColor(AppConstants.Colors.primaryRed)
            
            Text("Create New Password")
                .font(.system(size: 28, weight: .bold))
            
            Text("Your new password must be different from previously used passwords")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var passwordFieldsSection: some View {
        VStack(spacing: 16) {
            // New Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("New Password")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if showPassword {
                        TextField("Enter new password", text: $newPassword)
                            .autocapitalization(.none)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Enter new password", text: $newPassword)
                            .textContentType(.newPassword)
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(passwordFieldBorderColor, lineWidth: 1)
                )
            }
            
            // Confirm Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    
                    if showConfirmPassword {
                        TextField("Confirm new password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Confirm new password", text: $confirmPassword)
                            .textContentType(.newPassword)
                    }
                    
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(confirmFieldBorderColor, lineWidth: 1)
                )
            }
        }
    }
    
    private var passwordFieldBorderColor: Color {
        if newPassword.isEmpty {
            return Color.clear
        }
        return isPasswordValid ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
    }
    
    private var confirmFieldBorderColor: Color {
        if confirmPassword.isEmpty {
            return Color.clear
        }
        return doPasswordsMatch ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
    }
    
    private var passwordRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            requirementRow(
                met: newPassword.count >= 6,
                text: "At least 6 characters"
            )
            
            requirementRow(
                met: doPasswordsMatch && !confirmPassword.isEmpty,
                text: "Passwords match"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
    
    private func requirementRow(met: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundColor(met ? .green : .gray)
                .font(.system(size: 14))
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(met ? .primary : .gray)
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            Task {
                await resetPassword()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Reset Password")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSubmit ? AppConstants.Colors.primaryRed : Color.gray)
            .cornerRadius(25)
        }
        .disabled(!canSubmit)
    }
    
    // MARK: - Actions
    
    private func resetPassword() async {
        isLoading = true
        
        do {
            try await AuthManager.shared.completePasswordReset(
                code: recoveryCode,
                newPassword: newPassword
            )
            
            isSuccess = true
            alertTitle = "Success!"
            alertMessage = "Your password has been reset successfully. Please log in with your new password."
            showAlert = true
        } catch {
            isSuccess = false
            alertTitle = "Error"
            
            // Provide user-friendly error messages
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("expired") || errorMessage.contains("invalid") {
                alertMessage = "This password reset link has expired or is invalid. Please request a new password reset."
            } else if errorMessage.contains("weak") || errorMessage.contains("password") {
                alertMessage = "Password is too weak. Please choose a stronger password with at least 6 characters."
            } else {
                alertMessage = "Failed to reset password. Please try again or request a new reset link."
            }
            showAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    ResetPasswordView(recoveryCode: "test-code-123")
}
