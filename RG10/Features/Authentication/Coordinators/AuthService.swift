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
            // Email is the only supported sign-in identifier; username is display-only metadata
            guard username.contains("@") else {
                throw AuthError.emailSignInRequired
            }

            let session = try await client.auth.signIn(
                email: username,
                password: password
            )

            // Get the current user details
            guard let user = client.auth.currentUser else {
                throw AuthError.userNotFound
            }

            let actualEmail = user.email ?? username

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

            let actualUsername: String
            if let uname = anyJSONToString(metadata["username"]) {
                actualUsername = uname
            } else {
                actualUsername = actualEmail.components(separatedBy: "@").first ?? "User"
            }

            let displayName: String
            if let dname = anyJSONToString(metadata["display_name"]) {
                displayName = dname
            } else {
                displayName = actualUsername
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

