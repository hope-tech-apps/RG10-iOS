//
//  AccountMainView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

// AccountMainView.swift
struct AccountMainView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        List {
            // Profile Section
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        Text(authManager.currentUser?.username ?? "User")
                            .font(.headline)
                        Text(authManager.currentUser?.email ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
//                .onTapGesture {
//                    navigationManager.navigate(to: .editProfile)
//                }
            }
            
            // Menu Items
            Section("Training") {
                NavigationLink(value: NavigationDestination.myAppointments) {
                    Label("My Appointments", systemImage: "calendar")
                }
                
//                NavigationLink(value: NavigationDestination.paymentHistory) {
//                    Label("Payment History", systemImage: "creditcard")
//                }
            }
            
//            Section("Settings") {
//                NavigationLink(value: NavigationDestination.settings) {
//                    Label("Settings", systemImage: "gear")
//                }
//                
//                NavigationLink(value: NavigationDestination.support) {
//                    Label("Help & Support", systemImage: "questionmark.circle")
//                }
//            }
            
            Section("Legal") {
                NavigationLink(value: NavigationDestination.termsOfService) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
                
                NavigationLink(value: NavigationDestination.privacyPolicy) {
                    Label("Privacy Policy", systemImage: "lock.doc")
                }
            }
            
            Section {
                Button(action: {
                    // Use the correct method name from AuthManager
                    authManager.logout() // or whatever the method is called
                    navigationManager.resetNavigation()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
    }
}
