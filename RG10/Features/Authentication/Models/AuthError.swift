//
//  AuthError.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import Foundation

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
