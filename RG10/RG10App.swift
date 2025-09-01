//
//  RG10App.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

@main
struct RG10App: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(authManager)
                .preferredColorScheme(.light)
        }
    }
}
