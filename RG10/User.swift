//
//  User.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation

// MARK: - User Model
struct User: Codable, Equatable {
    let id: Int
    let username: String
    let email: String
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username = "user_nicename"
        case email = "user_email"
        case displayName = "user_display_name"
    }
}

// MARK: - Auth Response
struct AuthResponse: Codable {
    let token: String
    let userEmail: String
    let userNicename: String
    let userDisplayName: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case userEmail = "user_email"
        case userNicename = "user_nicename"
        case userDisplayName = "user_display_name"
    }
}

// MARK: - Register Response
struct RegisterResponse: Codable {
    let success: Bool
    let message: String
    let data: RegisterData?
}

struct RegisterData: Codable {
    let userId: Int
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case email
    }
}

// MARK: - Auth Error
enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case invalidResponse
    case registrationFailed(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .networkError:
            return "Network error. Please check your connection"
        case .invalidResponse:
            return "Invalid response from server"
        case .registrationFailed(let message):
            return message
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
