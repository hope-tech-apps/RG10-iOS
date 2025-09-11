//
//  RegisterData.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//


import Foundation

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

