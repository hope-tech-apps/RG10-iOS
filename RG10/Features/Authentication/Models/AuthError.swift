//
//  AuthError.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import Foundation

// MARK: - Auth Error
enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case invalidResponse
    case registrationFailed(String)
    case emailNotConfirmed
    case userNotFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username/email or password"
        case .networkError:
            return "Network error. Please check your connection"
        case .invalidResponse:
            return "Invalid response from server"
        case .registrationFailed(let message):
            return message
        case .emailNotConfirmed:
            return "Please confirm your email address to continue"
        case .userNotFound:
            return "User not found. Please sign up first"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
