//
//  AuthService.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Combine

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    func login(username: String, password: String) -> AnyPublisher<AuthResponse, AuthError>
    func register(username: String, email: String, password: String) -> AnyPublisher<RegisterResponse, AuthError>
}

// MARK: - Auth Service Implementation
class AuthService: AuthServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://www.rg10football.com/wp-json"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func login(username: String, password: String) -> AnyPublisher<AuthResponse, AuthError> {
        guard let url = URL(string: "\(baseURL)/jwt-auth/v1/token") else {
            return Fail(error: AuthError.invalidResponse)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "username=\(username)&password=\(password)"
        request.httpBody = parameters.data(using: .utf8)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return AuthError.invalidResponse
                } else {
                    return AuthError.networkError
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<RegisterResponse, AuthError> {
        guard let url = URL(string: "\(baseURL)/api/v1/register") else {
            return Fail(error: AuthError.invalidResponse)
                .eraseToAnyPublisher()
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
            return Fail(error: AuthError.invalidResponse)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: RegisterResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return AuthError.invalidResponse
                } else {
                    return AuthError.networkError
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock Auth Service for Testing
class MockAuthService: AuthServiceProtocol {
    var shouldSucceed = true
    var loginCallCount = 0
    var registerCallCount = 0
    
    func login(username: String, password: String) -> AnyPublisher<AuthResponse, AuthError> {
        loginCallCount += 1
        
        if shouldSucceed {
            let response = AuthResponse(
                token: "mock_token",
                userEmail: "test@example.com",
                userNicename: username,
                userDisplayName: "Test User"
            )
            return Just(response)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: AuthError.invalidCredentials)
                .eraseToAnyPublisher()
        }
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<RegisterResponse, AuthError> {
        registerCallCount += 1
        
        if shouldSucceed {
            let response = RegisterResponse(
                success: true,
                message: "Registration successful",
                data: RegisterData(userId: 1, username: username, email: email)
            )
            return Just(response)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: AuthError.registrationFailed("Username already exists"))
                .eraseToAnyPublisher()
        }
    }
}
