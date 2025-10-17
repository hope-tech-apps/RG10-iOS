//
//  AuthService.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Supabase

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    func login(username: String, password: String) async throws -> AuthResponse
    func register(username: String, email: String, password: String) async throws -> RegisterResponse
    func resetPassword(email: String) async throws
}

// MARK: - Auth Service Implementation (Supabase)
class AuthService: AuthServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func login(username: String, password: String) async throws -> AuthResponse {
        do {
            let session: Session
            let actualEmail: String
            let actualUsername: String
            let displayName: String
            
            // Check if username is an email or actual username
            if username.contains("@") {
                // Direct email login
                session = try await client.auth.signIn(
                    email: username,
                    password: password
                )
                
                // Get the current user details
                guard let user = client.auth.currentUser else {
                    throw AuthError.userNotFound
                }
                
                actualEmail = user.email ?? username

                // Extract username and display name from user metadata (Supabase stores `[String: AnyJSON]`)
                let metadata = user.userMetadata

                func anyJSONToString(_ value: AnyJSON?) -> String? {
                    guard let value else { return nil }
                    switch value {
                    case .string(let s):
                        return s
                    case .bool(let b):
                        return String(b)
                    case .null:
                        return nil
                    case .array, .object:
                        return nil
                    @unknown default:
                        // Fallback: stringify any other representable values
                        return String(describing: value)
                    }
                }

                if let uname = anyJSONToString(metadata["username"]) {
                    actualUsername = uname
                } else {
                    actualUsername = actualEmail.components(separatedBy: "@").first ?? "User"
                }

                if let dname = anyJSONToString(metadata["display_name"]) {
                    displayName = dname
                } else {
                    displayName = actualUsername
                }
            } else {
                // Username-based login - need to find email first
                let profiles: [ProfileData] = try await client
                    .from("profiles")
                    .select()
                    .eq("username", value: username)
                    .execute()
                    .value
                
                guard let profile = profiles.first,
                      let email = profile.email else {
                    throw AuthError.userNotFound
                }
                
                // Sign in with the found email
                session = try await client.auth.signIn(
                    email: email,
                    password: password
                )
                
                actualEmail = email
                actualUsername = profile.username ?? username
                displayName = profile.displayName ?? username
            }
            
            return AuthResponse(
                token: session.accessToken,
                userEmail: actualEmail,
                userNicename: actualUsername,
                userDisplayName: displayName
            )
        } catch let error as AuthError {
            throw error
        } catch {
            // Convert Supabase errors to our AuthError types
            if error.localizedDescription.contains("Invalid login") {
                throw AuthError.invalidCredentials
            } else {
                throw AuthError.networkError
            }
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> RegisterResponse {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "username": .string(username),
                    "display_name": .string(username)
                ]
            )
            
            let requiresConfirmation = response.user.confirmedAt == nil
            
            // Create profile entry in profiles table
            // This will be handled automatically by the trigger we created
            // but we can also do it manually if needed
            if let userId = Optional(response.user.id) {
                // The trigger should handle this, but we can try to insert manually as backup
                do {
                    let profile = ProfileData(
                        id: userId.uuidString,
                        username: username,
                        email: email,
                        displayName: username
                    )
                    
                    try await client
                        .from("profiles")
                        .insert(profile)
                        .execute()
                } catch {
                    // Profile might already exist from trigger, that's okay
                    print("Profile creation handled by trigger or already exists")
                }
            }
            
            let message = requiresConfirmation
                ? "Registration successful! Please check your email to confirm your account."
                : "Registration successful!"
            
            return RegisterResponse(
                success: true,
                message: message,
                data: RegisterData(
                    userId: response.user.id.uuidString.hashValue,
                    username: username,
                    email: email
                )
            )
        } catch {
            // Handle specific Supabase errors
            if error.localizedDescription.contains("already registered") {
                throw AuthError.registrationFailed("An account with this email already exists")
            } else if error.localizedDescription.contains("Password") {
                throw AuthError.registrationFailed("Password must be at least 6 characters")
            } else {
                throw AuthError.registrationFailed(error.localizedDescription)
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
}

// MARK: - Mock Auth Service for Testing
class MockAuthService: AuthServiceProtocol {
    var shouldSucceed = true
    var loginCallCount = 0
    var registerCallCount = 0
    
    func login(username: String, password: String) async throws -> AuthResponse {
        loginCallCount += 1
        
        if shouldSucceed {
            return AuthResponse(
                token: "mock_token",
                userEmail: "test@example.com",
                userNicename: username,
                userDisplayName: "Test User"
            )
        } else {
            throw AuthError.invalidCredentials
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> RegisterResponse {
        registerCallCount += 1
        
        if shouldSucceed {
            return RegisterResponse(
                success: true,
                message: "Registration successful",
                data: RegisterData(userId: 1, username: username, email: email)
            )
        } else {
            throw AuthError.registrationFailed("Username already exists")
        }
    }
    
    func resetPassword(email: String) async throws {
        // Mock implementation
        if !shouldSucceed {
            throw AuthError.networkError
        }
    }
}

// MARK: - Profile Data Model (for Supabase profiles table)
nonisolated(unsafe) struct ProfileData: Codable, Sendable {
    let id: String
    let username: String?
    let email: String?
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case displayName = "display_name"
    }

    init(id: String, username: String?, email: String?, displayName: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.displayName = displayName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(displayName, forKey: .displayName)
    }
}

