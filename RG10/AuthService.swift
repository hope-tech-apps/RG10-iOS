//
//  AuthService.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    func login(username: String, password: String) async throws -> AuthResponse
    func register(username: String, email: String, password: String) async throws -> RegisterResponse
}

// MARK: - Auth Service Implementation
class AuthService: AuthServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://www.rg10football.com/wp-json"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func login(username: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/jwt-auth/v1/token") else {
            throw AuthError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "username=\(username)&password=\(password)"
        request.httpBody = parameters.data(using: .utf8)
        
        do {
            let (data, _) = try await session.data(for: request)
            print(String(data: data, encoding: .utf8) ?? "No data")
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            return response
        } catch is DecodingError {
            throw AuthError.invalidResponse
        } catch {
            throw AuthError.networkError
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> RegisterResponse {
        guard let url = URL(string: "\(baseURL)/api/v1/register") else {
            throw AuthError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            throw AuthError.invalidResponse
        }
        
        do {
            let (data, _) = try await session.data(for: request)
            let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
            return response
        } catch is DecodingError {
            throw AuthError.invalidResponse
        } catch {
            throw AuthError.networkError
        }
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
}
