//
//  AuthResponse.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI
import Foundation

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
