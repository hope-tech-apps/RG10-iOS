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
