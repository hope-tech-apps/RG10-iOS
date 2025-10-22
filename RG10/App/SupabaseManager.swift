//
//  SupabaseManager.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//


import Foundation
import Supabase

// MARK: - Centralized Supabase Client
class SupabaseClientManager {
    static let shared = SupabaseClientManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: EnvironmentConfiguration.supabaseURL)!,
            supabaseKey: EnvironmentConfiguration.supabaseAnonKey,
            options: SupabaseClientOptions(db: .init(schema: "rg10"))
        )
    }
    
    // MARK: - Auth Helpers
    var currentUserEmail: String? {
        return client.auth.currentUser?.email ?? UserDefaults.standard.string(forKey: "userEmail")
    }
    
    var isAuthenticated: Bool {
        return client.auth.currentUser != nil
    }
}
