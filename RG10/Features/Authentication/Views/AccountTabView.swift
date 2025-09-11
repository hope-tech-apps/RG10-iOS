//
//  AccountTabView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/23/25.
//

import SwiftUI

struct AccountTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @ObservedObject var authManager = AuthManager.shared
    @State private var showSignUp = false
    
    var body: some View {
        Group {
            // Account tab is only visible when not authenticated
            // so we only need to show login/signup views
            if showSignUp {
                SignUpContentView(
                    viewModel: authViewModel,
                    showSignUp: $showSignUp
                )
            } else {
                LoginContentView(
                    viewModel: authViewModel,
                    showSignUp: $showSignUp
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSignUp)
    }
}
