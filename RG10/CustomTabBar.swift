//
//  CustomTabBar.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

//struct CustomTabBar: View {
//    @Binding var selectedTab: TabItem
//    @ObservedObject var authManager = AuthManager.shared
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            ForEach(availableTabs, id: \.self) { tab in
//                TabBarItem(
//                    tab: tab,
//                    isSelected: selectedTab == tab,
//                    action: {
//                        selectedTab = tab  // ✅ Just set tab, no notifications
//                    }
//                )
//            }
//        }
//        .padding(.top, 8)
//        .background(Color.white)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
//    }
//    
//    private var availableTabs: [TabItem] {
//        TabItem.availableTabs(isAuthenticated: authManager.isAuthenticated)
//    }
//}

// MARK: - Notification Names
extension Notification.Name {
    static let showLogin = Notification.Name("showLogin")
}
