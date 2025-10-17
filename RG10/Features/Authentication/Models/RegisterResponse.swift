//
//  RegisterResponse.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import Foundation

// MARK: - Register Response
struct RegisterResponse: Codable {
    let success: Bool
    let message: String
    let data: RegisterData?
}
