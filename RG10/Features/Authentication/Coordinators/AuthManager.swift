//
//  AuthManager.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import Foundation
import Combine

// MARK: - Auth Manager
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let tokenKey = "authToken"
    private let userKey = "currentUser"
    
    static let shared = AuthManager()
    
    private init() {
        loadStoredAuth()
    }
    
    // MARK: - Token Management
    var authToken: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
            isAuthenticated = newValue != nil
        }
    }
    
    // MARK: - User Management
    func saveUser(from authResponse: AuthResponse) {
        let user = User(
            id: 0, // We don't get ID from login response
            username: authResponse.userNicename,
            email: authResponse.userEmail,
            displayName: authResponse.userDisplayName
        )
        
        currentUser = user
        authToken = authResponse.token
        
        // Persist user data
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    func saveUser(from registerData: RegisterData) {
        let user = User(
            id: registerData.userId,
            username: registerData.username,
            email: registerData.email,
            displayName: registerData.username
        )
        
        currentUser = user
        
        // Persist user data
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    // MARK: - Auth State
    private func loadStoredAuth() {
        if let token = authToken, !token.isEmpty {
            isAuthenticated = true
            
            // Load stored user
            if let userData = UserDefaults.standard.data(forKey: userKey),
               let user = try? JSONDecoder().decode(User.self, from: userData) {
                currentUser = user
            }
        }
    }
    
    func logout() {
        authToken = nil
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userKey)
        isAuthenticated = false
    }
}
