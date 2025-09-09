//
//  BookNavigationStack.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//


//
//  BookNavigationStack.swift
//  RG10
//
//  Booking tab navigation stack
//

import SwiftUI

struct BookNavigationStack: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        NavigationStack(path: $navigationManager.bookPath) {
            BookingMainView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    EmptyView() // Add booking destinations as needed
                }
        }
    }
}

struct BookingMainView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Booking")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.gray)
                .padding(.top)
            
            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.6))
            
            Spacer()
        }
        .navigationTitle("Book Session")
        .navigationBarTitleDisplayMode(.large)
    }
}