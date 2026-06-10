//
//  AuthManager.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Combine
import Supabase

// MARK: - Auth Manager (Supabase)
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var session: Session?
    
    static let shared = AuthManager()
    private let client = SupabaseClientManager.shared.client
    private var authStateChangeListener: Task<Void, Never>?
    
    private init() {
        setupAuthListener()
        checkCurrentSession()
    }
    
    deinit {
        authStateChangeListener?.cancel()
    }
    
    // MARK: - Auth State Listener
    private func setupAuthListener() {
        authStateChangeListener = Task {
            for await (event, session) in client.auth.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        self.session = session
                        self.isAuthenticated = true
                        self.loadUserProfile()
                        
                    case .signedOut:
                        self.session = nil
                        self.currentUser = nil
                        self.isAuthenticated = false
                        UserDefaults.standard.removeObject(forKey: "userEmail")
                        
                    case .tokenRefreshed:
                        self.session = session
                        
                    case .userUpdated:
                        self.loadUserProfile()
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Session Management
    private func checkCurrentSession() {
        Task {
            do {
                let session = try await client.auth.session
                await MainActor.run {
                    self.session = session
                    self.isAuthenticated = true
                    self.loadUserProfile()
                }
            } catch {
                await MainActor.run {
                    self.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - User Profile
    private func loadUserProfile() {
        guard let supabaseUser = client.auth.currentUser else { return }
        
        // Store email for booking service
        if let email = supabaseUser.email {
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
        
        // Extract username from metadata
        var username = supabaseUser.email?.components(separatedBy: "@").first ?? "User"
        var displayName = username

        if let metadata = supabaseUser.userMetadata as? [String: AnyJSON] {
            if case let .string(uname) = metadata["username"] {
                username = uname
            }
            if case let .string(dname) = metadata["display_name"] {
                displayName = dname
            }
        }
        
        // Convert Supabase User to our User model
        currentUser = User(
            id: supabaseUser.id.uuidString.hashValue, // Convert UUID to Int for compatibility
            username: username,
            email: supabaseUser.email ?? "",
            displayName: displayName
        )
    }
    
    // MARK: - Auth Methods
    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        await MainActor.run {
            self.session = session
            self.isAuthenticated = true
            self.loadUserProfile()
        }
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "username": AnyJSON.string(username),
                "display_name": AnyJSON.string(username)
            ]
        )
        
        if let session = response.session {
            await MainActor.run {
                self.session = session
                self.isAuthenticated = true
                self.loadUserProfile()
            }
        }
        
        // Note: Depending on your Supabase settings, user might need to confirm email
        // Check response.user?.confirmedAt to see if email confirmation is required
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        
        await MainActor.run {
            self.session = nil
            self.currentUser = nil
            self.isAuthenticated = false
            UserDefaults.standard.removeObject(forKey: "userEmail")
        }
    }
    
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    // MARK: - Password Reset Flow (Deep Link)
    
    /// Exchange the recovery code from deep link for a valid session
    /// Call this after receiving `rg10://deep-link?code=<UUID>&type=recovery`
    func exchangeCodeForSession(_ code: String) async throws {
        let session = try await client.auth.exchangeCodeForSession(authCode: code)
        
        await MainActor.run {
            self.session = session
            self.isAuthenticated = true
            self.loadUserProfile()
        }
    }
    
    /// Update the user's password after validating session via recovery code
    func updateUserPassword(newPassword: String) async throws {
        try await client.auth.update(user: UserAttributes(password: newPassword))
    }
    
    /// Complete password reset flow: exchange code and update password
    func completePasswordReset(code: String, newPassword: String) async throws {
        // Step 1: Exchange code for session
        try await exchangeCodeForSession(code)
        
        // Step 2: Update password
        try await updateUserPassword(newPassword: newPassword)
        
        // Step 3: Sign out so user can log in with new password
        try await signOut()
    }
    
    // Alternative method if you want to remove password update functionality entirely:
    // Just comment out this method and handle password changes through the reset flow
    
    // MARK: - Compatibility Methods (for existing code)
    func logout() {
        Task {
            try? await signOut()
        }
    }
}

