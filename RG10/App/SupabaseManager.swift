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
            supabaseURL: URL(string: "https://uwssjvqlsekveqvdkdnj.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3c3NqdnFsc2VrdmVxdmRrZG5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyMTU5OTksImV4cCI6MjA3Mjc5MTk5OX0.HG6t79U5z8w_f0Qfwgclkxs4aZOfgALbMEwXN9ZTA00",
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
