//
//  User.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Supabase

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let displayName: String
    
    // For Supabase UUID compatibility
    var supabaseId: String? {
        return client.auth.currentUser?.id.uuidString
    }
    
    private var client: SupabaseClient {
        SupabaseClientManager.shared.client
    }
}
